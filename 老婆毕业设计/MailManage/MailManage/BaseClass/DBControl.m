//
//  MRDBControl.m
//  Player
//
//  Created by 韩 帅 on 12-9-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DBControl.h"
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"
#import "FMDatabasePool.h"
#import "FMDatabaseQueue.h"
#import "EmailElement.h"
#import "ListElement.h"

static DBControl *dbControll = nil;

@implementation DBControl
@synthesize dbQueue;

+(DBControl *)shareDBControl
{
    @synchronized(self)
    {
        if (dbControll == nil)
			dbControll = [[DBControl alloc] init];
    }
    return dbControll;
}

+(void)DBControlRelease
{
    MMRelease(dbControll);
}

- (void)dealloc
{
    MMRelease(dbQueue);
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self)
    {
        NSString* docsdir = [NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        NSString* dbpath = [docsdir stringByAppendingPathComponent:@"maildb.db"];
        self.dbQueue = [FMDatabaseQueue databaseQueueWithPath:dbpath];
        [self createTables];
    }
    return  self;
}

- (void)createTables
{
    [self.dbQueue inDatabase:^(FMDatabase *db)   {
        [db open];
        //邮件uidl表
        //ROWID INTEGER自增型||UIDL TEXT 邮件唯一标识符号||ISRECEIVED BOOLEAN是否接收过||EMAILID INTEGER邮件ID||EMAILSIZE INTEGER邮件大小||CONTENTJSON TEXT邮件原文解析后json||ISANALYZED BOOLEAN是否解析过
        NSString *emailuidltbsql = @"CREATE TABLE IF NOT EXISTS emailuidltb(ROWID INTEGER PRIMARY KEY AUTOINCREMENT,UIDL TEXT,ISRECEIVED BOOLEAN,EMAILID INTEGER, EMAILSIZE INTEGER,CONTENTJSON TEXT,ISANALYZED BOOLEAN DEFAULT NO)";
        [db executeUpdate:emailuidltbsql];
        [db close];
    }];
}

- (void)getUidlElement:(EmailElement *)uidlElement
{
    //如果不存在则插入,如果需要更新则更新
    if (![self isUidlElementExist:uidlElement]) {
        [self insertIntoEmailuidltbWithUidlElement:uidlElement];
    }
    else
    {
        if ([self isNeedToUpdateUidlElement:uidlElement]) {
            [self updateEmailuidltbWithUidlElement:uidlElement];
        }
        else
        {
            return;
        }
    }
}

//将获取的uidl及emailid信息插入emailuidltb表中
- (void)insertIntoEmailuidltbWithUidlElement:(EmailElement *)uidlElement
{
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        [db open];
        NSString *sql = @"insert into emailuidltb(UIDL,ISRECEIVED,EMAILID,EMAILSIZE) values(?,?,?,?)";
        [db executeUpdate:sql,uidlElement.uidl,[NSNumber numberWithBool:uidlElement.isreceived],[NSNumber numberWithInteger:uidlElement.emailid],[NSNumber numberWithInteger:uidlElement.emailsize]];
        [db close];
    }]; 
}

//更新uidl
- (void)updateEmailuidltbWithUidlElement:(EmailElement *)uidlElement
{
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        [db open];
        NSString *sql = @"update emailuidltb set ISRECEIVED = ?,EMAILID = ? where UIDL = ?";
        [db executeUpdate:sql,[NSNumber numberWithBool:uidlElement.isreceived],[NSNumber numberWithInteger:uidlElement.emailid],uidlElement.uidl];
        [db close];
    }];
}

//该uidl是否存在
- (BOOL)isUidlElementExist:(EmailElement *)uidlElement
{
    __block BOOL exist = NO;
    [self.dbQueue inDatabase:^(FMDatabase *db)   {
        [db open];
        NSString *sql = [NSString stringWithFormat:@"select * from emailuidltb where UIDL = ?"];
        FMResultSet *rs = [db executeQuery:sql,uidlElement.uidl];
        while ([rs next]) {
            NSInteger emailid = [rs intForColumn:@"EMAILID"];
            if (emailid) {
                exist = YES;
            }
        }
        [db close];
    }];
    return exist;

}

//是否需要更新UidlElement
- (BOOL)isNeedToUpdateUidlElement:(EmailElement *)uidlElement
{
    __block BOOL needToUpdate = NO;
    [self.dbQueue inDatabase:^(FMDatabase *db)   {
        [db open];
        NSString *sql = [NSString stringWithFormat:@"select * from emailuidltb where UIDL = ? and ISRECEIVED = NO"];
        FMResultSet *rs = [db executeQuery:sql,uidlElement.uidl];
        while ([rs next]) {
            NSInteger emailid = [rs intForColumn:@"EMAILID"];
            if (emailid) {
                needToUpdate = YES;
            }
        }
        [db close];
    }];
    return needToUpdate;
}

- (NSMutableArray *)selectUidlElementWithIsUnreceived
{
    __block NSMutableArray *uidlElements = [[NSMutableArray alloc] init];
    [self.dbQueue inDatabase:^(FMDatabase *db)   {
        [db open];
        NSString *sql = [NSString stringWithFormat:@"select * from emailuidltb where ISRECEIVED = ?"];
        FMResultSet *rs = [db executeQuery:sql,[NSNumber numberWithBool:NO]];
        while ([rs next]) {
            EmailElement *uidlElement = [[EmailElement alloc] init];
            uidlElement.uidl = [rs stringForColumn:@"UIDL"];
            uidlElement.emailid = [rs intForColumn:@"EMAILID"];
            uidlElement.isreceived = [rs boolForColumn:@"ISRECEIVED"];
            uidlElement.emailsize = [rs intForColumn:@"EMAILSIZE"];
            [uidlElements addObject:uidlElement];
            [uidlElement release];
        }
        [db close];
    }];
    return [uidlElements autorelease];;
}

- (void)updateEmailSize:(ListElement *)listElement
{
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        [db open];
        NSString *sql = @"update emailuidltb set EMAILSIZE = ? where EMAILID = ?";
        [db executeUpdate:sql, [NSNumber numberWithInteger:listElement.emailsize], [NSNumber numberWithInteger:listElement.emailid]];
        [db close];
    }];
}

- (void)insertEmailContentJson:(NSString *)contentJson uidl:(NSString *)uidl
{
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        [db open];
        NSString *sql = @"update emailuidltb set CONTENTJSON = ?,ISANALYZED = ? where UIDL = ?";
        [db executeUpdate:sql,contentJson,[NSNumber numberWithBool:YES],uidl];
        [db close];
    }];
}

- (BOOL)emlIsAnalyzed:(NSString *)uidl
{
    __block BOOL isAnalyzed = NO;
    [self.dbQueue inDatabase:^(FMDatabase *db)   {
        [db open];
        NSString *sql = [NSString stringWithFormat:@"select ISANALYZED from emailuidltb where UIDL = ?"];
        FMResultSet *rs = [db executeQuery:sql,uidl];
        while ([rs next]) {
            BOOL tag = [rs boolForColumn:@"ISANALYZED"];
            isAnalyzed = tag;
        }
        [db close];
    }];
    return isAnalyzed;
}

- (NSMutableArray *)selectUidl
{
    __block NSMutableArray *uidlArr = [[NSMutableArray alloc] init];
    [self.dbQueue inDatabase:^(FMDatabase *db)   {
        [db open];
        NSString *sql = [NSString stringWithFormat:@"select UIDL from emailuidltb where ISRECEIVED = ?"];
        FMResultSet *rs = [db executeQuery:sql,[NSNumber numberWithBool:YES]];
        while ([rs next]) {
            [uidlArr addObject:[rs stringForColumn:@"UIDL"]];
        }
        [db close];
    }];
    return [uidlArr autorelease];

}
@end
