//
//  ListElement.m
//  MailManage
//
//  Created by 韩 帅 on 13-2-26.
//  Copyright (c) 2013年 韩 帅. All rights reserved.
//

#import "ListElement.h"

@implementation ListElement
@synthesize emailid;
@synthesize emailsize;

- (void)dealloc
{
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (!self) {
        self.emailid = -1;
        self.emailsize = -1;
    }
    return self;
}

@end
