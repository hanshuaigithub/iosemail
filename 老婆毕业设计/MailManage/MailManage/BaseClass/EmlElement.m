//
//  EmlElement.m
//  MailManage
//
//  Created by 韩 帅 on 13-3-2.
//  Copyright (c) 2013年 韩 帅. All rights reserved.
//

#import "EmlElement.h"

@implementation EmlElement
@synthesize emlHeaderElement;

- (void)dealloc
{
    self.emlHeaderElement = nil;
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (!self) {
        self.emlHeaderElement = nil;
    }
    return self;
}

@end
