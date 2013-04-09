//
//  EmlAnalyze.m
//  MailManage
//
//  Created by 韩 帅 on 13-3-2.
//  Copyright (c) 2013年 韩 帅. All rights reserved.
//

#import "EmlAnalyze.h"
#import "EmlHeaderAnalyze.h"
#import "EmlHeaderElement.h"
#import "EmlContentElement.h"
#import "SBJson.h"
#import "DBControl.h"
#import "GTMBase64.h"

@implementation EmlAnalyze

- (void)analyzeEmlFileWith:(NSString *)emlStr uidl:(NSString *)uidl
{
    if ([[DBControl shareDBControl] emlIsAnalyzed:uidl]) {
//        return;
    }
    NSString *emlContentFilesDirPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"emlContentFiles"];
    NSString *emlContentFileDirPath = [emlContentFilesDirPath stringByAppendingPathComponent:uidl];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:emlContentFilesDirPath isDirectory:NO]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:emlContentFilesDirPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    if (![[NSFileManager defaultManager] fileExistsAtPath:emlContentFileDirPath isDirectory:NO]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:emlContentFileDirPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSMutableDictionary *contentDic = [NSMutableDictionary dictionary];
    NSDictionary *emlJsonDic = [NSDictionary dictionaryWithObjectsAndKeys:contentDic,@"emlJson", nil];
    
    EmlHeaderElement *emlHeaderElement = [[EmlHeaderElement alloc] init];
    emlHeaderElement.from = [self searchWithSourceStr:emlStr andReg:@"From:.*"];
    emlHeaderElement.to = [self searchWithSourceStr:emlStr andReg:@"To:.*"];
    emlHeaderElement.cc = [self searchWithSourceStr:emlStr andReg:@"Cc:.*"];
    emlHeaderElement.bcc = [self searchWithSourceStr:emlStr andReg:@"Bcc:.*"];
    emlHeaderElement.date = [self searchWithSourceStr:emlStr andReg:@"Date:.*"];
    
    [contentDic setObject:emlHeaderElement.from forKey:@"from"];
    //    [contentDic setObject:emlHeaderElement.to forKey:@"to"];
    //    [contentDic setObject:emlHeaderElement.cc forKey:@"cc"];
    //    [contentDic setObject:emlHeaderElement.bcc forKey:@"bcc"];
    [contentDic setObject:emlHeaderElement.date forKey:@"date"];
    
    
    emlHeaderElement.content_type = [self searchWithSourceStr:emlStr andReg:content_type_reg];
    emlHeaderElement.content_transfer_encoding = [self searchWithSourceStr:emlStr andReg:@"Content-Transfer-Encoding:.*\r\n"];
    if ([self isMultipartEmail:emlHeaderElement.content_type]) {
        NSString *boundaryMark = [self boundaryMark:emlHeaderElement.content_type];
        NSArray *contentsArray = [emlStr componentsSeparatedByString:[NSString stringWithFormat:@"--%@",boundaryMark]];
        for (int i = 1; i<contentsArray.count-1; i++) {
            //            NSLog(@"==contentsArray:%@\n=======================",[contentsArray objectAtIndex:i]);
            NSString *contentStr = [contentsArray objectAtIndex:i];
            if ([self isMultipartEmail:[contentsArray objectAtIndex:i]]) {
                NSLog(@"子content也是multipart类型");
                //Content-Type解析
                NSString *childContentType = [self searchWithSourceStr:contentStr andReg:content_type_reg];
                NSString *childBoundaryMark = [self boundaryMark:childContentType];
                NSArray *childContentsArray = [contentStr componentsSeparatedByString:[@"--" stringByAppendingString:childBoundaryMark]];
                
                for (int j = 1; j < childContentsArray.count - 1; j++) {
                    NSLog(@"子content不是multipart类型");
                    EmlContentElement *emlContentElement = [[EmlContentElement alloc] init];
                    emlContentElement.content_type = [self searchWithSourceStr:[childContentsArray objectAtIndex:j] andReg:content_type_reg];
                    emlContentElement.content_transfer_encoding = [self searchWithSourceStr:[childContentsArray objectAtIndex:j] andReg:@"Content-Transfer-Encoding:.*\r\n"];
                    emlContentElement.contentStr = [self getContentStr:[childContentsArray objectAtIndex:j]];
                    NSLog(@"=====================\ncontentStr:%@\n=====================",emlContentElement.contentStr);
                    
                    NSString *fileStr = [NSString stringWithFormat:@"childcontent%i-%i",i,j];
                    NSMutableDictionary *dic = [self contentDicWithContentType:emlContentElement.content_type src:fileStr];
                    [contentDic setObject:dic forKey:fileStr];
                    
                    NSString *filePath = [emlContentFileDirPath stringByAppendingPathComponent:fileStr];
                    [[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil];
                    
                    NSString *charset = [self searchWithSourceStr:emlHeaderElement.content_type andReg:@"(?<=(charset=\"))\\w*"];
                    [[self decode:emlContentElement.contentStr type:emlContentElement.content_transfer_encoding charset:charset]  writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
                    
                    [emlContentElement release];
                }
            }
            else
            {
                NSLog(@"子content不是multipart类型");
                EmlContentElement *emlContentElement = [[EmlContentElement alloc] init];
                emlContentElement.content_type = [self searchWithSourceStr:[contentsArray objectAtIndex:i] andReg:content_type_reg];
                emlContentElement.content_transfer_encoding = [self searchWithSourceStr:[contentsArray objectAtIndex:i] andReg:@"Content-Transfer-Encoding:.*\r\n"];
                emlContentElement.contentStr = [self getContentStr:[contentsArray objectAtIndex:i]];
                NSLog(@"=====================\ncontentStr:%@\n=====================",emlContentElement.contentStr);
                
                NSString *fileStr = [NSString stringWithFormat:@"childcontent%i-0",i];
                NSMutableDictionary *dic = [self contentDicWithContentType:emlContentElement.content_type src:fileStr];
                [contentDic setObject:dic forKey:fileStr];
                
                NSString *filePath = [emlContentFileDirPath stringByAppendingPathComponent:fileStr];
                [[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil];
                
                NSString *charset = [self searchWithSourceStr:emlHeaderElement.content_type andReg:@"(?<=(charset=\"))\\w*"];
                [[self decode:emlContentElement.contentStr type:emlContentElement.content_transfer_encoding charset:charset]  writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
                
                [emlContentElement release];
            }
        }
    }
    else
    {
        NSString *contentStr = [self getContentStr:emlStr];
        NSLog(@"=====================\ncontentStr:%@\n=====================",contentStr);
        
        NSString *fileStr = [NSString stringWithFormat:@"childcontent"];
        NSMutableDictionary *dic = [self contentDicWithContentType:emlHeaderElement.content_type src:fileStr];
        [contentDic setObject:dic forKey:fileStr];
        
        NSString *filePath = [emlContentFileDirPath stringByAppendingPathComponent:fileStr];
        [[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil];
        
        
        NSString *charset = [self searchWithSourceStr:emlHeaderElement.content_type andReg:@"(?<=(charset=\"))\\w*"];
        [[self decode:contentStr type:emlHeaderElement.content_transfer_encoding charset:charset]  writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }
    
    [emlHeaderElement release];
    
    SBJsonWriter *jsonW = [[SBJsonWriter alloc] init];
    NSString *emlJsonStr = [jsonW stringWithObject:emlJsonDic];
    NSLog(@"-->emlJsonStr:%@",emlJsonStr);
    [[DBControl shareDBControl] insertEmailContentJson:emlJsonStr uidl:uidl];
}

//通过正则表达式匹配
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

//邮件是否是Multipart类型的邮件
- (BOOL)isMultipartEmail:(NSString *)emlStr
{
    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"multipart" options:0 error:&error];
    
    if (regex != nil) {
        NSTextCheckingResult *firstMatch=[regex firstMatchInString:emlStr options:0 range:NSMakeRange(0, [emlStr length])];
        
        if (firstMatch) {
            return YES;
        }
    }
    return NO;
    
}
//找到boundary的值
- (NSString *)boundaryMark:(NSString *)emlStr
{
    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"boundary=.*" options:0 error:&error];
    
    if (regex != nil) {
        NSTextCheckingResult *firstMatch=[regex firstMatchInString:emlStr options:0 range:NSMakeRange(0, [emlStr length])];
        
        if (firstMatch) {
            NSRange resultRange = [firstMatch rangeAtIndex:0];
            
            NSString *result=[emlStr substringWithRange:resultRange];
            result = [result stringByReplacingOccurrencesOfString:@"boundary=" withString:@""];
            result = [result stringByReplacingOccurrencesOfString:@"\"" withString:@""];
            result = [result stringByReplacingOccurrencesOfString:@";" withString:@""];
            
            //输出结果
            NSLog(@">%@",result);
            return result;
        }
    }
    return nil;
}

- (NSString *)getContentStr:(NSString *)str
{
    NSArray *emlLineArray = [str componentsSeparatedByString:@"\r\n"];
    BOOL start = NO;
    NSString *contentStr = [NSString string];
    for (long i = 0; i < emlLineArray.count; i++) {
        if ([[emlLineArray objectAtIndex:i] isEqualToString:@""] && start == NO) {
            if (i) {
                start = YES;
            }
        }
        else if ([[emlLineArray objectAtIndex:i] isEqualToString:@"."] && start == YES)
        {
            break;
        }
        
        if (start) {
            contentStr = [contentStr stringByAppendingString:[emlLineArray objectAtIndex:i]];
        }
    }
    return contentStr;
}

//子content的类型和路径
- (NSMutableDictionary *)contentDicWithContentType:(NSString *)type src:(NSString *)src
{
    NSMutableDictionary *childContentDic = [NSMutableDictionary dictionary];
    if ([self searchWithSourceStr:type andReg:@"text/html"] != nil) {//如果是html
        [childContentDic setObject:@"html" forKey:@"type"];
    } else if ([self searchWithSourceStr:type andReg:@"text/plain"] != nil) {//如果是plain
        [childContentDic setObject:@"plain" forKey:@"type"];
    }
    else
    {
        [childContentDic setObject:@"app" forKey:@"type"];
    }
    [childContentDic setObject:src forKey:@"src"];
    return childContentDic;
}

- (NSString *)decode:(NSString *)str type:(NSString *)type charset:(NSString *)charset
{
    if ([self searchWithSourceStr:type andReg:@"base64"] != nil) {
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

- (NSString *)gb2312toutf8:(NSData *) data{
    
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSString *retStr = [[NSString alloc] initWithData:data encoding:enc];
    
    return retStr;
}
@end