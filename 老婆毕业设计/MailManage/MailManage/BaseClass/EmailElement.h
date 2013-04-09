//
//  EmailElement.h
//  MailManage
//
//  Created by 韩 帅 on 13-2-28.
//  Copyright (c) 2013年 韩 帅. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EmailElement : NSObject
{
    NSString *uidl;
    NSInteger emailid;
    NSInteger emailsize;
    BOOL isreceived;
}

@property (nonatomic ,copy) NSString *uidl;
@property (nonatomic ,assign) NSInteger emailid;
@property (nonatomic ,assign) BOOL isreceived;
@property (nonatomic, assign) NSInteger emailsize;

@end
