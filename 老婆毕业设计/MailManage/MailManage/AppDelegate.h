//
//  AppDelegate.h
//  MailManage
//
//  Created by 韩 帅 on 13-1-15.
//  Copyright (c) 2013年 韩 帅. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MainViewControllerForiPhone;
@class MainViewControllerForiPad;
@class MainNavigationControllerForiPhone;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) MainViewControllerForiPhone *viewControllerForiPhone;
@property (strong, nonatomic) MainViewControllerForiPad *viewControllerForiPad;
@property (strong, nonatomic) MainNavigationControllerForiPhone *navigationControllerForiPhone;

- (void)refreshItemPressed:(id)sender;

@end
