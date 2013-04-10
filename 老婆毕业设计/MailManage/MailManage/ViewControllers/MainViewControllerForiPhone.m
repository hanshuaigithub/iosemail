//
//  MainViewControllerForiPhone.m
//  MailManage
//
//  Created by 韩 帅 on 13-2-12.
//  Copyright (c) 2013年 韩 帅. All rights reserved.
//

#import "MainViewControllerForiPhone.h"
#import "InBoxEmailViewControllerForiPhone.h"
#import "DBControl.h"
#import "EmlListAnalyze.h"
#import "EmlListInfoElement.h"
#import "AppDelegate.h"

@interface MainViewControllerForiPhone () <UITableViewDataSource, UITableViewDelegate>
{
    UITableView *emailTb;
    UIToolbar *toolBar;
    UIBarButtonItem *refreshItem;
    UIBarButtonItem *writeEmailItem;
    InBoxEmailViewControllerForiPhone *inBoxEmailViewControllerForiPhone;
}
@end

#define KToolBarH 40

@implementation MainViewControllerForiPhone
@synthesize emailInfoArray = _emailInfoArray;

- (void)dealloc
{
    self.emailInfoArray = nil;
    MMRelease(emailTb);
    MMRelease(toolBar);
    MMRelease(refreshItem);
    MMRelease(writeEmailItem);
    MMRelease(inBoxEmailViewControllerForiPhone);
    [super dealloc];
}

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
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"邮箱";
    _emailInfoArray = [[NSMutableArray alloc] initWithObjects:@"收件箱",@"草稿箱",@"已发送",@"废纸篓", nil];
    
    emailTb = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - self.navigationController.navigationBar.frame.size.height) style:UITableViewStylePlain];
    emailTb.dataSource = self;
    emailTb.delegate = self;
    [self.view addSubview:emailTb];
    
    [self addToolBar];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _emailInfoArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text= [_emailInfoArray objectAtIndex:indexPath.row];
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0:
            inBoxEmailViewControllerForiPhone = [[InBoxEmailViewControllerForiPhone alloc] initWithNibName:nil bundle:nil];
            NSMutableArray *uidlListArr = [[DBControl shareDBControl] selectUidl];
            if (uidlListArr.count) {
                NSMutableArray *emlListInfoArray = [self getEmlListInfoArray:uidlListArr];
                inBoxEmailViewControllerForiPhone.emlArr = emlListInfoArray;
            }
            [self.navigationController pushViewController:inBoxEmailViewControllerForiPhone animated:YES];
            [inBoxEmailViewControllerForiPhone release];
            break;
            
        default:
            break;
    }
}

#pragma mark - Private

- (NSMutableArray *)getEmlListInfoArray:(NSMutableArray *)uidlArr
{
    NSMutableArray *emlListInfoArray = [[NSMutableArray alloc] init];
    for (NSString *uidl in uidlArr) {
        EmlListAnalyze *emlListAnalyze = [[EmlListAnalyze alloc] init];
        NSString *documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
        NSString *emlFileDirectory = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"EmlFiles/%@.eml",uidl]];
        
        [emlListInfoArray addObject:[emlListAnalyze analyzeEmlListWith:[NSString stringWithContentsOfFile:emlFileDirectory encoding:NSUTF8StringEncoding error:nil] uidl:uidl]];
    }
    return [emlListInfoArray autorelease];
}

- (void)addToolBar
{
    refreshItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshItemPressed:)];
    writeEmailItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(writeEmailItemPressed:)];
    
    toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-KToolBarH-44, self.view.frame.size.width, KToolBarH)];
    [toolBar setItems:[NSArray arrayWithObjects:refreshItem,writeEmailItem, nil] animated:YES];
    [self.view addSubview:toolBar];
}

- (void)refreshItemPressed:(id)sender
{
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    [appDelegate refreshItemPressed:sender];
}

- (void)writeEmailItemPressed:(id)sender
{
    
}

@end
