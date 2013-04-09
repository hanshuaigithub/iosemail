//
//  EmlListAnalyze.h
//  MailManage
//
//  Created by 韩 帅 on 13-4-9.
//  Copyright (c) 2013年 韩 帅. All rights reserved.
//

#import <Foundation/Foundation.h>

@class EmlListInfoElement;
@interface EmlListAnalyze : NSObject

- (EmlListInfoElement *)analyzeEmlListWith:(NSString *)emlStr uidl:(NSString *)uidl;

@end
