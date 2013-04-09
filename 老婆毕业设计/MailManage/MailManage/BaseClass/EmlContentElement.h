//
//  EmlContentElement.h
//  MailManage
//
//  Created by 韩 帅 on 13-3-9.
//  Copyright (c) 2013年 韩 帅. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EmlContentElement : NSObject

@property (nonatomic, copy) NSString *content_type;//内容类型
@property (nonatomic, copy) NSString *content_transfer_encoding;//内容的传输编码方式
@property (nonatomic, copy) NSString *contentStr;//正文内容

@end
