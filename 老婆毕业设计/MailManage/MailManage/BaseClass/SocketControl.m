//
//  SocketControl.m
//  MailManage
//
//  Created by 韩 帅 on 13-1-20.
//  Copyright (c) 2013年 韩 帅. All rights reserved.
//

#import "SocketControl.h"
#import "AsyncSocket.h"
#import "DBControl.h"
#import "EmailElement.h"
#import "ListElement.h"

#define KTimeOutTag 30

@interface SocketControl ()
{
    AsyncSocket *asyncSocket;
    DBControl *dbControl;
    NSMutableData  *writer;
    NSFileManager *fileManager;
    
    NSMutableArray *needDownLoadArr;//需要下载的邮件数组
    NSInteger currentindex;//当前下载邮件数组index
    BOOL isDownLoading;//下载状态
    
    NSString *hostName;//主机名
    UInt16 portNum;//端口
    
    NSString *user;//用户名
    NSString *pass;//密码
    
    BOOL isConnecting;//是否连接上服务器
}
@end

static SocketControl *socketControl = nil;

@implementation SocketControl
@synthesize curentUidlElement;
@synthesize delegate;

- (void)dealloc
{
    MMRelease(socketControl);
    MMRelease(asyncSocket);
    MMRelease(dbControl);
    MMRelease(writer);
    MMRelease(fileManager);
    MMRelease(needDownLoadArr);
    MMRelease(user);
    MMRelease(pass);
    self.curentUidlElement = nil;
    [super dealloc];
}

- (id)initWithUser:(NSString *)_user pass:(NSString *)_pass host:(NSString *)_hostName port:(int)_port
{
    self = [super init];
    if (self) {
        asyncSocket = [[AsyncSocket alloc] initWithDelegate:self];
        [asyncSocket setRunLoopModes:[NSArray arrayWithObject:NSRunLoopCommonModes]];
        dbControl = [DBControl shareDBControl];
        writer = [[NSMutableData alloc] init];
        fileManager = [NSFileManager defaultManager];
        self.delegate = self;
        isDownLoading = NO;
        user = _user;
        pass = _pass;
        hostName = _hostName;
        portNum = _port;
        isConnecting = NO;
    }
    return self;
}

#pragma mark - Class Method

+(SocketControl *)shareSocketControlWithUser:(NSString *)user pass:(NSString *)pass host:(NSString *)host port:(int)port
{
    if (!socketControl) {
        socketControl = [[SocketControl alloc] initWithUser:user pass:pass host:host port:port];
    }
    return socketControl;
}

+(void)socketControlRelease
{
    MMRelease(socketControl);
}

#pragma mark - Public Method
- (NSError *)connectToHostWithHostName:(NSString *)host andPort:(int)port
{
    NSError *err = nil;
    
    if (![asyncSocket connectToHost:host onPort:port error:&err]) {
        NSLog(@"Error:%@",err);
    }
    return err;
}

- (void)sendMsg:(NSString *)msg withTag:(long)tag
{
    msg = [msg stringByAppendingFormat:@"\r\n"];
    NSData *msgData = [msg dataUsingEncoding:NSUTF8StringEncoding];
    [asyncSocket writeData:msgData withTimeout:-1 tag:tag];
}

- (void)downLoadAllEmail
{
    if (isDownLoading) {
        return;
    }
    if (!isConnecting) {
        [self connectToHostWithHostName:hostName andPort:portNum];
    }
    else
    {
        //开始下载uidl信息并下载邮件
        [self.delegate startDownLoadUidlInfo];
        [self sendMsg:@"uidl" withTag:uidl_tag];
    }
}

#pragma mark -- AsyncSocketDelegate Method

- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
    [self.delegate connectSucceedWithHost:host port:port];
//    [sock readDataWithTimeout:-1 tag:conn_tag];
    [sock readDataToData:[AsyncSocket CRLFData] withTimeout:-1 tag:conn_tag];
}

- (void)onSocketDidSecure:(AsyncSocket *)sock
{
	NSLog(@"onSocketDidSecure:%p", sock);
}

- (void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err
{
    [self.delegate connectFailedWithErr:err];
	NSLog(@"onSocket:%p willDisconnectWithError:%@", sock, err);
}

- (void)onSocketDidDisconnect:(AsyncSocket *)sock
{
	NSLog(@"onSocketDidDisconnect:%p", sock);
}

- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
	NSString *msg = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];

    if ([msg hasPrefix:@"-ERR"]) {
        [self.delegate msgRecvFailedWithTagType:tag];
        NSLog(@"Error");
    }
    else{
        if (tag == conn_tag) {
            [self sendMsg:[NSString stringWithFormat:@"user %@",user] withTag:user_tag];
        }
        else if (tag == user_tag) {
            if ([msg hasPrefix:@"+OK"]) {
                [self sendMsg:[NSString stringWithFormat:@"pass %@",pass] withTag:pass_tag];
            }
        }
        else if (tag == pass_tag)
        {
            if ([msg hasPrefix:@"+OK"]) {
                [self.delegate loginSucceedWithUser:user pass:pass];
            }
        }
        else if (tag == list_tag)
        {
            NSString *newestuidlPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"Newestlist"];
            NSString *uidlFilePath = [newestuidlPath stringByAppendingPathComponent:@"newestlist"];
            
            NSString *uidlFileStr = [NSString stringWithContentsOfFile:uidlFilePath encoding:NSUTF8StringEncoding error:nil];
            if ([uidlFileStr hasSuffix:@".\r\n"]) {
                [fileManager removeItemAtPath:uidlFilePath error:nil];
            }
            
            [writer appendData:[msg dataUsingEncoding:NSUTF8StringEncoding]];
            
            if ([msg isEqualToString:@".\r\n"]) {
                //
                if (![fileManager fileExistsAtPath:newestuidlPath isDirectory:NO]) {
                    [fileManager createDirectoryAtPath:newestuidlPath withIntermediateDirectories:YES attributes:nil error:nil];
                }
                if (![fileManager fileExistsAtPath:uidlFilePath]) {
                    [fileManager createFileAtPath:uidlFilePath contents:nil attributes:nil];
                }
                [writer writeToFile:uidlFilePath atomically:YES];
                [writer setData:nil];//清空缓存区
                
                //
                NSString *fileStr = [NSString stringWithContentsOfFile:uidlFilePath encoding:NSUTF8StringEncoding error:nil];
                NSArray *uidlinfoarr = [fileStr componentsSeparatedByString:@"\r\n"];
                for (NSString *lineStr in uidlinfoarr) {
                    if ([lineStr hasPrefix:@"+OK"]) {
                        continue;
                    }
                    NSArray *uidlinfo = [lineStr componentsSeparatedByString:@" "];
                    
                    if ([lineStr hasSuffix:@"."] || uidlinfo.count == 1) {
                        break;
                    }
                    ListElement *listElement = [[ListElement alloc] init];
                    listElement.emailid = [[uidlinfo objectAtIndex:0] integerValue];
                    listElement.emailsize = [[uidlinfo objectAtIndex:1] integerValue];
                    [dbControl updateEmailSize:listElement];
                    [ListElement release];
                }
                [self.delegate downLoadedListInfo];
                return;
            }
            [sock readDataToData:[AsyncSocket CRLFData] withTimeout:-1 tag:list_tag];
        }
        else if (tag == retr_tag)
        {
            [writer appendData:[msg dataUsingEncoding:NSUTF8StringEncoding]];
            if ([msg isEqualToString:@".\r\n"]) {
                if (writer.length<curentUidlElement.emailsize) {
                    [sock readDataToData:[AsyncSocket CRLFData] withTimeout:KTimeOutTag tag:retr_tag];
                }
                else
                {
                    NSString *uidlNumPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"EmlFiles"];
                    if (![fileManager fileExistsAtPath:uidlNumPath isDirectory:NO]) {
                        [fileManager createDirectoryAtPath:uidlNumPath withIntermediateDirectories:YES attributes:nil error:nil];
                    }
                    NSString *emlFilePath = [uidlNumPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.eml",curentUidlElement.uidl]];
                    
                    if (![fileManager fileExistsAtPath:emlFilePath]) {
                        [fileManager createFileAtPath:emlFilePath contents:nil attributes:nil];
                    }
                    [writer writeToFile:emlFilePath atomically:YES];
                    [writer setData:nil];//清空缓存区
                    
                    curentUidlElement.isreceived = YES;
                    [dbControl updateEmailuidltbWithUidlElement:curentUidlElement];
                    [delegate emailIsDownLoaded:curentUidlElement];
                    return;
                }
            }
            [sock readDataToData:[AsyncSocket CRLFData] withTimeout:KTimeOutTag tag:retr_tag];
        }
        else if(tag == uidl_tag)
        {
            NSString *newestuidlPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"Newestuidl"];
            NSString *uidlFilePath = [newestuidlPath stringByAppendingPathComponent:@"newestuidl"];

            NSString *uidlFileStr = [NSString stringWithContentsOfFile:uidlFilePath encoding:NSUTF8StringEncoding error:nil];
            if ([uidlFileStr hasSuffix:@".\r\n"]) {
                [fileManager removeItemAtPath:uidlFilePath error:nil];
            }
            
            [writer appendData:[msg dataUsingEncoding:NSUTF8StringEncoding]];
            
            if ([msg isEqualToString:@".\r\n"]) {
                //
                if (![fileManager fileExistsAtPath:newestuidlPath isDirectory:NO]) {
                    [fileManager createDirectoryAtPath:newestuidlPath withIntermediateDirectories:YES attributes:nil error:nil];
                }
                if (![fileManager fileExistsAtPath:uidlFilePath]) {
                    [fileManager createFileAtPath:uidlFilePath contents:nil attributes:nil];
                }
                [writer writeToFile:uidlFilePath atomically:YES];
                [writer setData:nil];//清空缓存区
                
                //
                NSString *fileStr = [NSString stringWithContentsOfFile:uidlFilePath encoding:NSUTF8StringEncoding error:nil];
                NSArray *uidlinfoarr = [fileStr componentsSeparatedByString:@"\r\n"];
                for (NSString *lineStr in uidlinfoarr) {
                    if ([lineStr hasPrefix:@"+OK"]) {
                        continue;
                    }
                    NSArray *uidlinfo = [lineStr componentsSeparatedByString:@" "];

                    if ([lineStr hasSuffix:@"."] || uidlinfo.count == 1) {
                        break;
                    }
                    EmailElement *uidlElement = [[EmailElement alloc] init];
                    uidlElement.emailid = [[uidlinfo objectAtIndex:0] integerValue];
                    uidlElement.uidl = [uidlinfo objectAtIndex:1];
                    [dbControl getUidlElement:uidlElement];
                    [uidlElement release];
                }
                [self.delegate downLoadedUidlInfo];
                return;
            }
            [sock readDataToData:[AsyncSocket CRLFData] withTimeout:-1 tag:uidl_tag];
        }
        else if (tag == stat_tag)
        {
            
        }
        else if (tag == quit_tag)
        {
            if ([msg isEqualToString:@"+OK Bye\r\n"]) {
                [self.delegate quit];
            }
        }
    }
}

- (void)onSocket:(AsyncSocket *)sock didWriteDataWithTag:(long)tag
{
//    [sock readDataWithTimeout:-1 tag:tag];
    [sock readDataToData:[AsyncSocket CRLFData] withTimeout:-1 tag:tag];
}

- (NSTimeInterval)onSocket:(AsyncSocket *)sock
  shouldTimeoutReadWithTag:(long)tag
				   elapsed:(NSTimeInterval)elapsed
				 bytesDone:(CFIndex)length
{
    [self.delegate msgRecvFailedWithTagType:tag];
    return KTimeOutTag;
}
#pragma mark - SocketControlDelegate Method

//Connect
//=============================================
- (void)connectSucceedWithHost:(NSString *)host port:(UInt16)port//连接服务器成功
{
    isConnecting = YES;
    NSLog(@"连接服务器成功,Host:%@,port:%d",host,port);
}

- (NSError *)connectFailedWithErr:(NSError *)err//连接服务器失败
{
    isConnecting = NO;
    NSLog(@"连接服务器失败,Err:%@",err);
    return err;
}

//Login
//=============================================
- (void)loginSucceedWithUser:(NSString *)_user pass:(NSString *)_pass
{
    NSLog(@"user:%@,pass:%@ 登陆成功",_user,_pass);
    //开始下载uidl信息并下载邮件
    [self.delegate startDownLoadUidlInfo];
    [self sendMsg:@"uidl" withTag:uidl_tag];
}

- (void)loginFailedWithUser:(NSString *)_user pass:(NSString *)_pass
{
    NSLog(@"user:%@,pass:%@ 登陆失败",_user,_pass);
}

//Uidl
//=============================================
- (void)startDownLoadUidlInfo//开始下载uidl信息
{
    NSLog(@"开始下载uidl信息");
}

- (void)downLoadedUidlInfo//uidl信息下载完毕
{
    NSLog(@"uidl信息下载完毕");
    //开始下载邮件
    [self.delegate startDownLoadAllEmail];
    currentindex = 0;
    //更新邮件大小
    [self.delegate startDownLoadListInfo];
    [self sendMsg:@"list" withTag:list_tag];
}

- (void)downLoadedUidlInfoErr//uidl信息下载错误
{
    NSLog(@"下载uidl信息错误");
    isDownLoading = NO;
}


//开始下载list信息
- (void)startDownLoadListInfo
{
    NSLog(@"开始下载list信息");
}

//list信息下载完毕
- (void)downLoadedListInfo
{
    NSLog(@"list信息下载完毕");
    MMRelease(needDownLoadArr);
    needDownLoadArr = [[NSMutableArray alloc] initWithArray:(NSArray *)[[DBControl shareDBControl] selectUidlElementWithIsUnreceived]];
    if (needDownLoadArr.count) {
        EmailElement *uidlElement = [needDownLoadArr objectAtIndex:currentindex];
        self.curentUidlElement = uidlElement;
        [self sendMsg:[NSString stringWithFormat:@"retr %i",uidlElement.emailid] withTag:retr_tag];
        NSLog(@"==========>开始下载email EmailId:%i,uidl:%@",uidlElement.emailid,uidlElement.uidl);
    }
    else
    {
        [self.delegate allEmailIsDownLoaded];
    }
}

//list信息下载错误
- (void)downLoadedListInfoErr
{
    NSLog(@"list信息下载错误");
}

//邮件全局进程
//=============================================
- (void)startDownLoadAllEmail//开始下载全部邮件
{
    isDownLoading = YES;
    NSLog(@"邮件下载全局进程开始");
}
- (void)allEmailIsDownLoaded//全部邮件下载完毕
{
    NSLog(@"邮件下载全局进程结束");
    currentindex = 0;
    isDownLoading = NO;
    [self sendMsg:@"quit" withTag:quit_tag];
}

//每封邮件进程
//=============================================
- (void)emailIsDownLoaded:(EmailElement *)uidlElement//一封邮件下载完成
{
    NSLog(@"本封邮件下载完成,emailid:%i,uidl:%@",uidlElement.emailid,uidlElement.uidl);
    [self downNextEmail];
}

- (void)emailDownLoadFailed:(EmailElement *)uidlElement//一封邮件下载错误
{
    NSLog(@"本封邮件下载失败,emailid:%i,uidl:%@",uidlElement.emailid,uidlElement.uidl);
    [writer setData:nil];
    [self downNextEmail];
}

//接受失败
//=============================================
- (void)msgRecvFailedWithTagType:(long)tag//信息接收失败
{
    NSLog(@"信息接收失败 tag:%ld",tag);
    if (tag == retr_tag) {
        [self.delegate emailDownLoadFailed:curentUidlElement];
    }
    else if (tag == uidl_tag)
    {
        [self.delegate downLoadedUidlInfoErr];
    }
    else if (tag == user_tag)
    {
        [self.delegate loginFailedWithUser:user pass:pass];
    }
    else if (tag == pass_tag)
    {
        [self.delegate loginFailedWithUser:user pass:pass];
    }
    else if (tag == list_tag)
    {
        [self.delegate downLoadedListInfoErr];
    }
}

//退出登陆
//=============================================
- (void)quit
{
    isConnecting = NO;
    NSLog(@"成功退出登陆");
}

#pragma mark - Private Method

//下载下一封邮件
- (void)downNextEmail
{
    currentindex ++;
    if (currentindex>=needDownLoadArr.count) {
        [self.delegate allEmailIsDownLoaded];
        return;
    }
    EmailElement *nextUidlElement = [needDownLoadArr objectAtIndex:currentindex];
    NSLog(@"==>开始下载email EmailId:%i,uidl:%@",nextUidlElement.emailid,nextUidlElement.uidl);
    socketControl.curentUidlElement = nextUidlElement;
    [socketControl sendMsg:[NSString stringWithFormat:@"retr %i",nextUidlElement.emailid] withTag:retr_tag];
}
@end
