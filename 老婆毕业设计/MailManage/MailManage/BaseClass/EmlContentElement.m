//
//  EmlContentElement.m
//  MailManage
//
//  Created by 韩 帅 on 13-3-9.
//  Copyright (c) 2013年 韩 帅. All rights reserved.
//

#import "EmlContentElement.h"

@implementation EmlContentElement
@synthesize content_type;
@synthesize content_transfer_encoding;
@synthesize contentStr;

- (void)dealloc
{
    self.content_type = nil;
    self.content_transfer_encoding = nil;
    self.contentStr = nil;
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self) {
        self.content_type = nil;
        self.content_transfer_encoding = nil;
        self.contentStr = nil;
    }
    return self;
}

@end
