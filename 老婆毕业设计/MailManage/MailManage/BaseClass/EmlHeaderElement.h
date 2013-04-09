//
//  EmlHeaderElement.h
//  MailManage
//
//  Created by 韩 帅 on 13-3-2.
//  Copyright (c) 2013年 韩 帅. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EmlHeaderElement : NSObject

@property (nonatomic, copy) NSString *received;//传输路径 各级邮件服务器添加
@property (nonatomic, copy) NSString *return_path;//回复地址 目标邮件服务器添加
@property (nonatomic, copy) NSString *delivered_to;//发送地址 目标邮件服务器添加

//以下由邮件的创建者添加
@property (nonatomic, copy) NSString *reply_to;//回复地址
@property (nonatomic, copy) NSString *from;//发件人地址
@property (nonatomic, copy) NSString *to;//收件人地址
@property (nonatomic, copy) NSString *cc;//抄送地址
@property (nonatomic, copy) NSString *bcc;//暗送地址
@property (nonatomic, copy) NSString *date;//日期和时间
@property (nonatomic, copy) NSString *subject;//主题
@property (nonatomic, copy) NSString *message_id;//消息ID
@property (nonatomic, copy) NSString *mime_version;//MIME版本
@property (nonatomic, copy) NSString *content_type;//内容类型
@property (nonatomic, copy) NSString *content_transfer_encoding;//内容的传输编码方式

@end
