//
//  LKViewController.m
//  LKDataBase
//
//  Created by 李考 on 08/09/2022.
//  Copyright (c) 2022 李考. All rights reserved.
//

#import "LKViewController.h"
#import <LKDataBase/LKDataBase.h>

@interface LKViewController ()

@end

@implementation LKViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [LKDataBase openLog];
    
    UIButton *btn = [[UIButton alloc] init];
    [btn setTitle:@"创建数据库" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn setBackgroundColor:[UIColor blueColor]];
    btn.frame = CGRectMake(100, 100, 120, 40);
    [btn addTarget:self action:@selector(createDB) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    UIButton *btn1 = [[UIButton alloc] init];
    [btn1 setTitle:@"创建表单1" forState:UIControlStateNormal];
    [btn1 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn1 setBackgroundColor:[UIColor blueColor]];
    btn1.frame = CGRectMake(50, 180, 150, 40);
    [btn1 addTarget:self action:@selector(createTable) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn1];
    UIButton *btn12 = [[UIButton alloc] init];
    [btn12 setTitle:@"创建表单2" forState:UIControlStateNormal];
    [btn12 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn12 setBackgroundColor:[UIColor blueColor]];
    btn12.frame = CGRectMake(200, 180, 150, 40);
    [btn12 addTarget:self action:@selector(createTable2) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn12];
    
    
    UIButton *btn2 = [[UIButton alloc] init];
    [btn2 setTitle:@"数据存储" forState:UIControlStateNormal];
    [btn2 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn2 setBackgroundColor:[UIColor blueColor]];
    btn2.frame = CGRectMake(50, 260, 120, 40);
    [btn2 addTarget:self action:@selector(putObject) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn2];
    UIButton *btn21 = [[UIButton alloc] init];
    [btn21 setTitle:@"表1 数据更新" forState:UIControlStateNormal];
    [btn21 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn21 setBackgroundColor:[UIColor blueColor]];
    btn21.frame = CGRectMake(200, 260, 120, 40);
    [btn21 addTarget:self action:@selector(table1Update) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn21];
    
    UIButton *btn31 = [[UIButton alloc] init];
    [btn31 setTitle:@"数据存储2" forState:UIControlStateNormal];
    [btn31 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn31 setBackgroundColor:[UIColor blueColor]];
    btn31.frame = CGRectMake(50, 310, 120, 40);
    [btn31 addTarget:self action:@selector(putData2) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn31];
    
    UIButton *btn4 = [[UIButton alloc] init];
    [btn4 setTitle:@"删除数据库" forState:UIControlStateNormal];
    [btn4 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn4 setBackgroundColor:[UIColor blueColor]];
    btn4.frame = CGRectMake(50, 360, 120, 40);
    [btn4 addTarget:self action:@selector(deleteDB) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn4];
    
    UIButton *btn41 = [[UIButton alloc] init];
    [btn41 setTitle:@"查询表1" forState:UIControlStateNormal];
    [btn41 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn41 setBackgroundColor:[UIColor blueColor]];
    btn41.frame = CGRectMake(200, 360, 120, 40);
    [btn41 addTarget:self action:@selector(selectedAll) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn41];
}
// 创建数据库
- (void)createDB {
    [[LKDataBase shareDataBase] createDB:@"user.db"];
}
// 数据库中创建表
- (void)createTable {
    NSLog(@"创建表 ta1");
    [[LKDataBase shareDataBase] createTableName:@"ta1"];
}
- (void)createTable2 {
    NSLog(@"创建表 ta2");
    [[LKDataBase shareDataBase] createTableName:@"ta2"];
}

- (void)putObject {
    NSLog(@"数据存储1");
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{
        @"name" : @"京东方1",
        @"age" : @"1年",
        @"address" : @"北京大兴1"
    }];
    
    for (NSString *key in [dict allKeys]) {
        NSString *value = [dict objectForKey:key];
        [[LKDataBase shareDataBase] tableName:@"ta1" putObject:value ForKey:key];
    }
}
- (void)table1Update {
    [[LKDataBase shareDataBase] tableName:@"ta1" putObject:@"京东方1更新" ForKey:@"name"];
}

- (void)putData2 {
    NSLog(@"数据存储2");
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{
        @"name" : @"222",
        @"age" : @"2年",
        @"address" : @"北京大兴22"
    }];
    
    for (NSString *key in [dict allKeys]) {
        NSString *value = [dict objectForKey:key];
        [[LKDataBase shareDataBase] tableName:@"ta2" putObject:value ForKey:key];
    }
}
// 删除数据库
- (void)deleteDB {
    [[LKDataBase shareDataBase] deleteDataBase:@"user.db"];
}
// 查询表1 所有数据
- (void)selectedAll {
    NSDictionary *dict = [[LKDataBase shareDataBase] selectedAllDataWithTableName:@"ta1"];
    NSLog(@"表1 所有数据:%@",dict);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
