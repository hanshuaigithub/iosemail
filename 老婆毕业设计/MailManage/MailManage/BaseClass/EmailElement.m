//
//  EmailElement.m
//  MailManage
//
//  Created by 韩 帅 on 13-2-28.
//  Copyright (c) 2013年 韩 帅. All rights reserved.
//

#import "EmailElement.h"

@implementation EmailElement
@synthesize uidl;
@synthesize emailid;
@synthesize isreceived;
@synthesize emailsize;

- (void)dealloc
{
    self.uidl = nil;
    emailid = -1;
    emailsize = -1;
    isreceived = NO;
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self) {
        isreceived = NO;
        emailid = -1;
        emailsize = -1;
    }
    return self;
}

@end
