//
//  SocketControl.h
//  MailManage
//
//  Created by 韩 帅 on 13-1-20.
//  Copyright (c) 2013年 韩 帅. All rights reserved.
//

#import <Foundation/Foundation.h>
@class EmailElement;
@protocol SocketControlDelegate <NSObject>

@optional

- (void)connectSucceedWithHost:(NSString *)host port:(UInt16)port;//连接服务器成功
- (NSError *)connectFailedWithErr:(NSError *)err;//连接服务器失败

- (void)loginSucceedWithUser:(NSString *)_user pass:(NSString *)_pass;//登陆成功
- (void)loginFailedWithUser:(NSString *)_user pass:(NSString *)_pass;//登录失败

- (void)startDownLoadUidlInfo;//开始下载uidl信息
- (void)downLoadedUidlInfo;//uidl信息下载完毕
- (void)downLoadedUidlInfoErr;//uidl信息下载错误

- (void)startDownLoadListInfo;//开始下载list信息
- (void)downLoadedListInfo;//list信息下载完毕
- (void)downLoadedListInfoErr;//list信息下载错误

- (void)startDownLoadAllEmail;//开始下载全部邮件
- (void)allEmailIsDownLoaded;//下载至最后一封邮件完成

- (void)emailIsDownLoaded:(EmailElement *)uidlElement;//一封邮件下载完成
- (void)emailDownLoadFailed:(EmailElement *)uidlElement;//一封邮件下载错误

- (void)msgRecvFailedWithTagType:(long)tag;//信息接收失败

- (void)quit;//退出登陆

@end

@interface SocketControl : NSObject <SocketControlDelegate>

@property (nonatomic, retain) EmailElement *curentUidlElement;
@property (nonatomic, assign) id <SocketControlDelegate> delegate;

+(SocketControl *)shareSocketControlWithUser:(NSString *)user pass:(NSString *)pass host:(NSString *)host port:(int)port;
+(void)socketControlRelease;

- (NSError *)connectToHostWithHostName:(NSString *)host andPort:(int)port;
- (void)sendMsg:(NSString *)msg withTag:(long)tag;
- (void)downLoadAllEmail;

@end
