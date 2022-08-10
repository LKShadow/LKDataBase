//
//  LKDataBase.h
//  LKDataBase
//
//  Created by 李考 on 2022/8/9.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LKDataBase : NSObject

/**
 创建数据库单例
 (目前只支持创建一个数据库，支持创建多个表)
 */
+ (instancetype)shareDataBase;

/**
 开启日志输出, 默认关闭
 */
+ (void)openLog;
/**
 关闭日志输入
 */
+ (void)closeLog;

/**
 创建数据库 DB, 后面创建的表都在 该数据库下
 @Param dbName 数据库名称，以 db为后缀，例如 "User.db"
 */
- (void)createDB:(NSString *)dbName;
/**
 删除数据库
 @Param dbName 数据库名称
 */
- (void)deleteDataBase:(NSString *)dbName;
/**
 在对应数据库内创建表单
 @Param tableName 在数据库中要建的 表 的名称
 */
- (void)createTableName:(NSString *)tableName;
/**
 在表中插入/ 修改 新值
 */
- (void)tableName:(NSString *)tableName putObject:(id<NSSecureCoding>)object ForKey:(NSString *)key;
/**
 删除表中的数据
 */
- (void)tableName:(NSString *)tableName removeObjectForKey:(NSString *)key;
/**
 查询
 */
- (id<NSSecureCoding>)tableName:(NSString *)tableName objectForKey:(NSString *)key;
/**
 查询表中所有数据
 */
- (id)selectedAllDataWithTableName:(NSString *)tableName ;
/**
 删除表中所有数据
 */
- (void)deleteAllDataWithTableName:(NSString *)tableName;

@end

NS_ASSUME_NONNULL_END
