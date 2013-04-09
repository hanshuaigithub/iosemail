//
//  ViewController.m
//  MailManage
//
//  Created by 韩 帅 on 13-1-15.
//  Copyright (c) 2013年 韩 帅. All rights reserved.
//

#import "ViewController.h"
#import "SocketControl.h"
#import "DBControl.h"

@interface ViewController ()
{
    UITextField *codeFiled;
    UIButton *sendBt;
    UIButton *downLoadAllEmailBt;
    SocketControl *socketControl;
}
@end

@implementation ViewController

- (void)dealloc
{
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //
        self.view.backgroundColor = [UIColor whiteColor];
        codeFiled = [[UITextField alloc] initWithFrame:CGRectMake(0, 5, 200, 30)];
        codeFiled.borderStyle = UITextBorderStyleRoundedRect;
        [self.view addSubview:codeFiled];
        sendBt = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [sendBt setTitle:@"发送指令" forState:UIControlStateNormal];
        sendBt.frame = CGRectMake(220, 5, 80, 30);
        [sendBt addTarget:self action:@selector(sendMsg:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:sendBt];
        downLoadAllEmailBt = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [downLoadAllEmailBt setTitle:@"下载全部邮件" forState:UIControlStateNormal];
        [downLoadAllEmailBt addTarget:self action:@selector(downLoadAllEmailBtPressed:) forControlEvents:UIControlEventTouchUpInside];
        downLoadAllEmailBt.frame = CGRectMake(220, 40, 80, 30);
        [self.view addSubview:downLoadAllEmailBt];
        socketControl = [SocketControl shareSocketControlWithUser:@"792618173" pass:@"#dongaiai" host:@"pop.qq.com" port:110];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)sendMsg:(id)sender
{
    NSString *textStr = [codeFiled.text lowercaseString];
    codeFiled.text = nil;

    if ([textStr hasPrefix:@"list"]) {
        [socketControl sendMsg:textStr withTag:list_tag];
    }
    else if([textStr hasPrefix:@"retr"])
    {
        [socketControl sendMsg:textStr withTag:retr_tag];
    }
    else if ([textStr hasPrefix:@"uidl"])
    {
        [socketControl sendMsg:textStr withTag:uidl_tag];
    }
    else if ([textStr hasPrefix:@"stat"])
    {
        [socketControl sendMsg:textStr withTag:stat_tag];
    }
    else if ([textStr hasPrefix:@"quit"])
    {
        [socketControl sendMsg:@"quit" withTag:quit_tag];
    }
}

- (void)downLoadAllEmailBtPressed:(id)sender
{
    [socketControl downLoadAllEmail];
}

@end
