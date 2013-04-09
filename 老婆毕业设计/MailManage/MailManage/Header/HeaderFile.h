//
//  HeaderFile.h
//  MailManage
//
//  Created by 韩 帅 on 13-1-20.
//  Copyright (c) 2013年 韩 帅. All rights reserved.
//

#ifndef MailManage_HeaderFile_h
#define MailManage_HeaderFile_h

#define conn_tag 0  //连接服务器tag
#define user_tag 1  //用户名
#define pass_tag 2  //密码
#define list_tag 3  //列表
#define retr_tag 4  //返回邮件原文
#define uidl_tag 5  //详细列表
#define stat_tag 6  
#define quit_tag 7  //退出

//释放内存
#define MMRelease(format){\
    if(format){\
    [format release];\
    format = nil;\
    }\
}

#define content_type_reg @"Content-Type: multipart/.*\r\n.*boundary=.*|Content-Type: multipart/.*\r\n.*charset=.*|Content-Type: .*\r\n.*charset=.*|Content-Type:.*\r\n.*charset=.*|Content-Type: .*\r\n.*\r\n.*boundary=.*|Content-Type: .*\r\n.*name=.*|Content-Type: .*"

#endif
