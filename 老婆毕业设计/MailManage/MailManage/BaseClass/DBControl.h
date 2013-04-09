//
//  MRDBControl.h
//  Player
//
//  Created by 韩 帅 on 12-9-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
@class FMDatabaseQueue;
@class EmailElement;
@class ListElement;

@interface DBControl : NSObject

@property (nonatomic, retain) FMDatabaseQueue *dbQueue;

+(DBControl *)shareDBControl;
+(void)DBControlRelease;

//建表
- (void)createTables;
//获取到一个uidl时对数据库的操作
- (void)getUidlElement:(EmailElement *)uidlElement;
//获取需要下载的uidlElement
- (NSMutableArray *)selectUidlElementWithIsUnreceived;
//更新邮件信息
- (void)updateEmailuidltbWithUidlElement:(EmailElement *)uidlElement;
//更新邮件大小
- (void)updateEmailSize:(ListElement *)listElement;
//是否需要被解析
- (BOOL)emlIsAnalyzed:(NSString *)uidl;
//插入邮件原文解析信息
- (void)insertEmailContentJson:(NSString *)contentJson uidl:(NSString *)uidl;
//
- (NSMutableArray *)selectUidl;
@end
