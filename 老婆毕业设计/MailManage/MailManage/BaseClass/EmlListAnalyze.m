//
//  EmlListAnalyze.m
//  MailManage
//
//  Created by 韩 帅 on 13-4-9.
//  Copyright (c) 2013年 韩 帅. All rights reserved.
//

#import "EmlListAnalyze.h"
#import "EmlListInfoElement.h"
#import "GTMBase64.h"

@implementation EmlListAnalyze

- (EmlListInfoElement *)analyzeEmlListWith:(NSString *)emlStr uidl:(NSString *)uidl
{
    //From:=?gb2312?B?UVHNxbm6?=<newsletter-noreply@qq.com>
    //Subject:=?gb2312?B?UVHNxbm6w7/W3MnMxrexrL/uvK0gLSDDv9bctde821dPV83FubqjoaG+usPA9tPRxcmhv6G+trO4ycT7w8rGrKG/ob7C88u5zqy2+6G/ob69+L/aQU9DvLa4ybrsob8=?=

    EmlListInfoElement *emlListInfoElement = [[EmlListInfoElement alloc] init];
    NSString *fromStr = [self searchWithSourceStr:emlStr andReg:@"From.*"];
    NSString *subjectStr = [self searchWithSourceStr:emlStr andReg:@"Subject.*"];
    
    NSArray *fromInfoArr = [fromStr componentsSeparatedByString:@"?"];
    NSArray *subjectInfoArr = [subjectStr componentsSeparatedByString:@"?"];

    if (fromInfoArr.count == 1) {
        emlListInfoElement.name = [fromInfoArr objectAtIndex:0];
        emlListInfoElement.eml= emlListInfoElement.name;
    }
    else
    {
        emlListInfoElement.name = [self decode:[fromInfoArr objectAtIndex:3] type:[fromInfoArr objectAtIndex:2] charset:[fromInfoArr objectAtIndex:1]];
        emlListInfoElement.eml = [fromInfoArr objectAtIndex:4];
    }
    if (subjectInfoArr.count == 1) {
        emlListInfoElement.subject = [subjectInfoArr objectAtIndex:0];
    }
    else
    {
        emlListInfoElement.subject = [self decode:[subjectInfoArr objectAtIndex:3] type:[subjectInfoArr objectAtIndex:2] charset:[subjectInfoArr objectAtIndex:1]];
    }
    
    emlListInfoElement.uidl = uidl;
    
    return [emlListInfoElement autorelease];
}

- (NSString *)searchWithSourceStr:(NSString *)emlStr andReg:(NSString *)reg
{
    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:reg options:0 error:&error];
    
    if (regex != nil) {
        NSTextCheckingResult *firstMatch=[regex firstMatchInString:emlStr options:0 range:NSMakeRange(0, [emlStr length])];
        
        if (firstMatch) {
            NSRange resultRange = [firstMatch rangeAtIndex:0];
            
            NSString *result=[emlStr substringWithRange:resultRange];
            //输出结果
            NSLog(@"%@",result);
            return result;
        }
    }
    return nil;
}

- (NSString *)decode:(NSString *)str type:(NSString *)type charset:(NSString *)charset
{
    if ([self searchWithSourceStr:type andReg:@"B"] != nil||[self searchWithSourceStr:type andReg:@"b"] != nil) {//base64
        NSData *decodeData = [GTMBase64 decodeString:str];
        if (decodeData == nil) {
            return nil;
        }
        NSString *decodeStr;
        if ([charset isEqualToString:@"gb2312"]) {
            decodeStr = [[NSString alloc] initWithData:decodeData encoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000)];
        }
        else if ([charset isEqualToString:@"utf-8"]||[charset isEqualToString:@"UTF-8"])
        {
            decodeStr = [[NSString alloc] initWithData:decodeData encoding:NSUTF8StringEncoding];
        }
        else
        {
            decodeStr = [[NSString alloc] initWithData:decodeData encoding:NSUTF8StringEncoding];
        }
        return [decodeStr autorelease];
    }
    else
    {
        return str;
    }
}

@end
