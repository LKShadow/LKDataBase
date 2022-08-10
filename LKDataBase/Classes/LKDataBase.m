//
//  LKDataBase.m
//  LKDataBase
//
//  Created by 李考 on 2022/8/9.
//

#import "LKDataBase.h"
#import <FMDB/FMDB.h>
#import <sqlite3.h>

#ifdef DEBUG // 开发阶段-DEBUG阶段:使用NSLog
#define BLog(fmt,...) NSLog((@"%s [Line %d] " fmt),__PRETTY_FUNCTION__,__LINE__,##__VA_ARGS__)
#else // 发布阶段-上线阶段:在Edit Scheme设置Build Configuration为Release
#define BLog(...)

#endif

static BOOL _openLog; // 是否开启日志

// 创建数据库 表
static NSString * const CREATE_TABLE_SQL =
@"CREATE TABLE IF NOT EXISTS %@ ( \
key TEXT NOT NULL PRIMARY KEY, \
value BLOB NOT NULL, \
createTime TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP, \
updateTime TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP) \
";
// 数据插入
static NSString * const REPLACE_ITEM_SQL = @"replace into %@ (key, value, createTime) values (?, ?, (select createTime from %@ where key = key))";
// 查询
static NSString * const SELECT_ITEM_SQL = @"select value from %@ where key = ? Limit 1";
// 删除特定值对应的数据
static NSString * const DELETE_ITEM_SQL = @"delete from %@ where key = ?";
// 查询表中所有数据
static NSString * const SELECT_DATA_ALLITEM_SQL = @"select * from %@";
//删除表中所有数据
static NSString * const DELETE_Table_SQL = @"delete from %@";


@interface LKDataBase ()

@property (strong, nonatomic) FMDatabaseQueue * dbQueue;

@end

@implementation LKDataBase

+ (instancetype)shareDataBase {
    static LKDataBase *dataBase = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dataBase = [[LKDataBase alloc] init];
    });
    return dataBase;
}

- (void)createDB:(NSString *)dbName {
    if (self.dbQueue) {
        [self.dbQueue close];
    }
    // 定义 db在沙盒中的存储路径
    NSString *dbPath = [self getDbFilePathWithName:dbName];
    // 判断当前是否存在该文件，若没有则进行创建
    NSString *filePath = [self createFile:dbPath];
    NSAssert(filePath.length, @"文件路径不能为空,未知错误");
    self.dbQueue = [FMDatabaseQueue databaseQueueWithPath:filePath];
}

- (void)deleteDataBase:(NSString *)dbName {
    NSAssert(dbName.length, @"数据库名称不能为空");
    NSString *dbPath = [self getDbFilePathWithName:dbName];
    [self close];
    
    NSFileManager *manager = [NSFileManager defaultManager];
    if ([manager isDeletableFileAtPath:dbPath]) {
        NSError *error;
        [manager removeItemAtPath:dbPath error:&error];
        if (error) {
            if (_openLog) BLog(@"数据库%@--删除失败:%@",dbName, error);
        } else {
            if (_openLog) BLog(@"删除数据库成功:%@😄😄",dbName);
        }
    }
}

- (void)createTableName:(NSString *)tableName {
    NSString *sqlString = [self SQL_createTableSQLForTableName:tableName];
    __block BOOL result;
    [_dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        result = [db executeUpdate:sqlString];
        if (!result) {
            if (_openLog) BLog(@"初始化表失败...");
        } else {
            if (_openLog) BLog(@"初始化表成功😄😄");
        }
    }];
    
}
- (void)tableName:(NSString *)tableName putObject:(id<NSSecureCoding>)object ForKey:(NSString *)key {
    if (!tableName) {
        return;
    }
    NSString *sql = [self SQL_replaceSQLForTableName:tableName];
    __block BOOL result;
    [_dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        result = [db executeUpdate:sql, key, object];
        if (result) {
            if (_openLog) BLog(@"数据插入成功😄😄");
        } else {
            if (_openLog) BLog(@"数据插入失败:\n key:%@ \nvalue:%@",key, object);
        }
    }];
}
- (void)tableName:(NSString *)tableName removeObjectForKey:(nonnull NSString *)key {
    NSAssert(tableName.length, @"数据库表名称不能为空");
    if (!key) {
        return;
    }
    NSString *sql = [self SQL_deleteSQLForTableName:tableName];
    __block BOOL result;
    [_dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        result = [db executeUpdate:sql,key];
    }];
    if (result) {
        if (_openLog) BLog(@"数据库表：%@ --- %@移除成功😄😄",tableName, key);
    } else {
        if (_openLog) BLog(@"数据库表：%@ --- %@移除失败!!!",tableName, key);
    }
}

- (id<NSSecureCoding>)tableName:(NSString *)tableName objectForKey:(NSString *)key {
    NSAssert(key.length, @"key 不能为空");
    NSAssert(tableName.length, @"数据库表名不能为空");
    
    NSString *sql = [self SQL_selectSQLForTableName:tableName];
    __block NSData *value = nil;
    [_dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *rs = [db executeQuery:sql, key];
        if ([rs next]) {
            value = [rs dataForColumn:@"value"];
        }
        [rs close];
    }];
    if (!value) {
        return nil;
    }
    return value;
}

- (id)selectedAllDataWithTableName:(NSString *)tableName {
    NSString *sql = [self SQL_selectedAllDataForTableName:tableName];
    __block NSMutableArray <NSDictionary *>*tempArray = [NSMutableArray array];
    [_dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *rs = [db executeQuery:sql];
        while ([rs next]) {
            [tempArray addObject:[rs resultDictionary]];
        }
    }];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [tempArray enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *key = [obj valueForKey:@"key"];
        NSString *value = [obj valueForKey:@"value"];
        [dict setObject:value forKey:key];
    }];
    return dict;
    
}
- (void)deleteAllDataWithTableName:(NSString *)tableName {
    NSString *sql = [self SQL_deletedAllDataForTableName:tableName];
    __block BOOL result;
    [_dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        result = [db executeUpdate:sql];
    }];
    if (result) {
        if (_openLog) BLog(@"数据库表：%@ 删除成功😄😄",tableName);
    } else {
        if (_openLog) BLog(@"数据库表：%@ 删除失败!!!",tableName);
    }
}

#pragma mark method

- (void)close {
    [self.dbQueue close];
    
    self.dbQueue = nil;
}
// 通过db名称 获取存储路径
- (NSString *)getDbFilePathWithName:(NSString *)dbName {
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    // 定义 db在沙盒中的存储路径
    NSString *dbPath = [documentPath stringByAppendingPathComponent:dbName];
    return dbPath;
}
// 根据路径，创建对应文件路径文件夹，并返回文件路径，若返回空字符串，表示创建失败
- (NSString *)createFile:(NSString *)filePath {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    // 判断当前文件存储路径的文件夹是否存在，若没有会进行创建文件夹
    if (![fileManager fileExistsAtPath:[filePath stringByDeletingLastPathComponent]]) {
        NSError *createError;
        [fileManager createDirectoryAtPath:[filePath stringByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nil error:&createError];
        if (createError) {
            if (_openLog) BLog(@"创建数据库存储路径文件夹错误：%@", createError);
            return @"";
        }
    }
    if (_openLog) NSLog(@"数据存储路径:\n%@",filePath);
    return filePath;
}

+ (void)openLog {
    _openLog = YES;
}

+ (void)closeLog {
    _openLog = NO;
}

#pragma mark - Private Function
#pragma mark SQL
- (NSString *)SQL_replaceSQLForTableName:(NSString *)tableName {
    return [NSString stringWithFormat:REPLACE_ITEM_SQL , tableName, tableName];
}

- (NSString *)SQL_createTableSQLForTableName:(NSString *)tableName {
    return [NSString stringWithFormat:CREATE_TABLE_SQL, tableName];
}

- (NSString *)SQL_selectSQLForTableName:(NSString *)tableName {
    return [NSString stringWithFormat:SELECT_ITEM_SQL, tableName];;
}

- (NSString *)SQL_deleteSQLForTableName:(NSString *)tableName {
    return [NSString stringWithFormat:DELETE_ITEM_SQL, tableName];
}

- (NSString *)SQL_selectedAllDataForTableName:(NSString *)tableName {
    return [NSString stringWithFormat:SELECT_DATA_ALLITEM_SQL, tableName];
}

- (NSString *)SQL_deletedAllDataForTableName:(NSString *)tableName {
    return [NSString stringWithFormat:DELETE_Table_SQL, tableName];
}

@end
