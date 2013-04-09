//
//  EmlHeaderAnalyze.m
//  MailManage
//
//  Created by 韩 帅 on 13-3-2.
//  Copyright (c) 2013年 韩 帅. All rights reserved.
//

#import "EmlHeaderAnalyze.h"
#import "EmlHeaderElement.h"

@implementation EmlHeaderAnalyze

- (void)analyzeEmlHeaderWith:(NSString *)emlStr
{
    EmlHeaderElement *emlHeaderElement = [[EmlHeaderElement alloc] init];
    emlHeaderElement.from = [self searchWithSourceStr:emlStr andReg:@"From:.*"];
    emlHeaderElement.to = [self searchWithSourceStr:emlStr andReg:@"To:.*"];
    emlHeaderElement.cc = [self searchWithSourceStr:emlStr andReg:@"Cc:.*"];
    emlHeaderElement.bcc = [self searchWithSourceStr:emlStr andReg:@"Bcc:.*"];
    emlHeaderElement.date = [self searchWithSourceStr:emlStr andReg:@"Date:.*"];
    emlHeaderElement.content_type = [self searchWithSourceStr:emlStr andReg:@"Content-Type: multipart/.*\r\n.*boundary=.*|Content-Type: multipart/.*\r\n.*charset=.*"];
    if ([self isMultipartEmail:emlStr]) {
        NSString *boundaryMark = [self boundaryMark:emlHeaderElement.content_type];
        NSArray *contentsArray = [emlStr componentsSeparatedByString:[NSString stringWithFormat:@"--%@",boundaryMark]];
//        NSLog(@"%@",contentsArray);
        for (int i = 1; i<contentsArray.count-1; i++) {
            NSLog(@"==%@",[contentsArray objectAtIndex:i]);
            if ([self isMultipartEmail:[contentsArray objectAtIndex:i]]) {
                NSLog(@"Yes");
            }
            else
            {
                NSLog(@"No");
            }
        }
    }
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

- (BOOL)isMultipartEmail:(NSString *)emlStr
{
    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"boundary=" options:0 error:&error];
    
    if (regex != nil) {
        NSTextCheckingResult *firstMatch=[regex firstMatchInString:emlStr options:0 range:NSMakeRange(0, [emlStr length])];
        
        if (firstMatch) {
            return YES;
        }
    }
    return NO;

}

- (NSString *)boundaryMark:(NSString *)emlStr
{
    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"--.*" options:0 error:&error];
    
    if (regex != nil) {
        NSTextCheckingResult *firstMatch=[regex firstMatchInString:emlStr options:0 range:NSMakeRange(0, [emlStr length])];
        
        if (firstMatch) {
            NSRange resultRange = [firstMatch rangeAtIndex:0];
            
            NSString *result=[emlStr substringWithRange:resultRange];
            result = [result stringByReplacingOccurrencesOfString:@"\"" withString:@""];
            //输出结果
            NSLog(@"%@",result);
            return result;
        }
    }
    return nil;

}

@end
