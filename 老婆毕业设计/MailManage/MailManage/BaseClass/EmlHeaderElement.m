//
//  EmlHeaderElement.m
//  MailManage
//
//  Created by 韩 帅 on 13-3-2.
//  Copyright (c) 2013年 韩 帅. All rights reserved.
//

#import "EmlHeaderElement.h"

@implementation EmlHeaderElement

@synthesize received;//传输路径 各级邮件服务器添加
@synthesize return_path;//回复地址 目标邮件服务器添加
@synthesize delivered_to;//发送地址 目标邮件服务器添加

//以下由邮件的创建者添加
@synthesize reply_to;//回复地址
@synthesize from;//发件人地址
@synthesize to;//收件人地址
@synthesize cc;//抄送地址
@synthesize bcc;//暗送地址
@synthesize date;//日期和时间
@synthesize subject;//主题
@synthesize message_id;//消息ID
@synthesize mime_version;//MIME版本
@synthesize content_type;//内容类型
@synthesize content_transfer_encoding;//内容的传输编码方式

- (void)dealloc
{
    self.received = nil;
    self.return_path = nil;
    self.delivered_to = nil;
    self.reply_to = nil;
    self.from = nil;
    self.to = nil;
    self.cc = nil;
    self.bcc = nil;
    self.date = nil;
    self.subject = nil;
    self.message_id = nil;
    self.mime_version = nil;
    self.content_type = nil;
    self.content_transfer_encoding = nil;
    
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (!self) {
        self.received = nil;
        self.return_path = nil;
        self.delivered_to = nil;
        self.reply_to = nil;
        self.from = nil;
        self.to = nil;
        self.cc = nil;
        self.bcc = nil;
        self.date = nil;
        self.subject = nil;
        self.message_id = nil;
        self.mime_version = nil;
        self.content_type = nil;
        self.content_transfer_encoding = nil;
    }
    return self;
}

@end
