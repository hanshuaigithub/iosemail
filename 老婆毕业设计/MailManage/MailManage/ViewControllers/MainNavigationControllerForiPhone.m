//
//  MainNavigationControllerForiPhone.m
//  MailManage
//
//  Created by 韩 帅 on 13-2-12.
//  Copyright (c) 2013年 韩 帅. All rights reserved.
//

#import "MainNavigationControllerForiPhone.h"

@interface MainNavigationControllerForiPhone ()

@end

@implementation MainNavigationControllerForiPhone

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#ifdef __IPHONE_6_0
//ios 6 )supported
- (BOOL)shouldAutorotate{
    return YES;
}
-(NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
}
#endif

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return UIInterfaceOrientationIsPortrait(interfaceOrientation);
}
@end
