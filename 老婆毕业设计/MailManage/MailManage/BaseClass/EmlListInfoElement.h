//
//  EmlListInfoElement.h
//  MailManage
//
//  Created by 韩 帅 on 13-4-9.
//  Copyright (c) 2013年 韩 帅. All rights reserved.
//

#import <Foundation/Foundation.h>
@class FromElement;

@interface EmlListInfoElement : NSObject
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *eml;
@property (nonatomic, copy) NSString *subject;
@property (nonatomic, copy) NSString *uidl;
@end
