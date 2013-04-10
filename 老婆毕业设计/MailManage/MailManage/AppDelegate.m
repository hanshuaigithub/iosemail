//
//  AppDelegate.m
//  MailManage
//
//  Created by 韩 帅 on 13-1-15.
//  Copyright (c) 2013年 韩 帅. All rights reserved.
//

#import "AppDelegate.h"

#import "ViewController.h"
#import "MainViewControllerForiPhone.h"
#import "MainViewControllerForiPad.h"
#import "MainNavigationControllerForiPhone.h"
#import "SocketControl.h"
//
#import "EmlAnalyze.h"

#define KToolBarH 44

@interface AppDelegate ()
{
    SocketControl *socketControl;
    UIToolbar *toolBar;
    UIBarButtonItem *refreshItem;
    UIBarButtonItem *writeEmailItem;
}
@end

@implementation AppDelegate

@synthesize viewControllerForiPhone = _viewControllerForiPhone;
@synthesize viewControllerForiPad = _viewControllerForiPad;
@synthesize navigationControllerForiPhone = _navigationControllerForiPhone;

- (void)dealloc
{
    [_window release];
    [_viewControllerForiPhone release];
    [_viewControllerForiPad release];
    [_navigationControllerForiPhone release];
    MMRelease(socketControl);
    MMRelease(toolBar);
    MMRelease(refreshItem);
    MMRelease(writeEmailItem);
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self test];
    
    socketControl = [SocketControl shareSocketControlWithUser:@"792618173" pass:@"#dongaiai" host:@"pop.qq.com" port:110];

    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        self.viewControllerForiPhone = [[[MainViewControllerForiPhone alloc] initWithNibName:nil bundle:nil] autorelease];
        self.navigationControllerForiPhone = [[MainNavigationControllerForiPhone alloc] initWithRootViewController:self.viewControllerForiPhone];
        self.window.rootViewController = self.navigationControllerForiPhone;
    } else {
        self.viewControllerForiPad = [[[MainViewControllerForiPad alloc] initWithNibName:nil bundle:nil] autorelease];
        self.window.rootViewController = self.viewControllerForiPad;
    }
    
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)refreshItemPressed:(id)sender
{
    [socketControl downLoadAllEmail];
}

- (void)test
{
    return;
    EmlAnalyze *emlAnalyze = [[EmlAnalyze alloc] init];
    NSString *documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *emlFileDirectory = [documentsDirectory stringByAppendingPathComponent:@"EmlFiles/ZC0908-ijeuXDh14ty~GzRlcK3pM34.eml"];

    [emlAnalyze analyzeEmlFileWith:[NSString stringWithContentsOfFile:emlFileDirectory encoding:NSUTF8StringEncoding error:nil] uidl:@"ZC0908-ijeuXDh14ty~GzRlcK3pM34"];
}
@end
