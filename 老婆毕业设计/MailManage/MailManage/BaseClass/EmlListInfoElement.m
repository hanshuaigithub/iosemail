//
//  EmlListInfoElement.m
//  MailManage
//
//  Created by 韩 帅 on 13-4-9.
//  Copyright (c) 2013年 韩 帅. All rights reserved.
//

#import "EmlListInfoElement.h"

@implementation EmlListInfoElement
@synthesize name;
@synthesize eml;
@synthesize subject;

- (void)dealloc
{
    self.name = nil;
    self.eml = nil;
    self.subject = nil;
    [super dealloc];
}

@end
