//
//  ListElement.h
//  MailManage
//
//  Created by 韩 帅 on 13-2-26.
//  Copyright (c) 2013年 韩 帅. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ListElement : NSObject
{
    NSInteger emailid;
    NSInteger emailsize;
}
@property (nonatomic, assign) NSInteger emailid;
@property (nonatomic, assign) NSInteger emailsize;

@end
