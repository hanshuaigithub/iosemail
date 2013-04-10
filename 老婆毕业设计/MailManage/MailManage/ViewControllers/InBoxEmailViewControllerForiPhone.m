//
//  InBoxEmailViewControllerForiPhone.m
//  MailManage
//
//  Created by 韩 帅 on 13-3-1.
//  Copyright (c) 2013年 韩 帅. All rights reserved.
//

#import "InBoxEmailViewControllerForiPhone.h"
#import "SBJsonParser.h"
#import "EmlHeaderInfoCell.h"
#import "EmlListInfoElement.h"
#import "DBControl.h"
#import "EmlAnalyze.h"
#import "EmlViewController.h"

@interface InBoxEmailViewControllerForiPhone () <UITableViewDataSource,UITableViewDelegate>
{
    UITableView *emlListTb;
}
@end

@implementation InBoxEmailViewControllerForiPhone
@synthesize emlArr = _emlArr;

- (void)dealloc
{
    MMRelease(emlListTb);
    self.emlArr = nil;
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
    self.title = @"收件箱";
	// Do any additional setup after loading the view.
    emlListTb = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-44)];
    emlListTb.dataSource = self;
    emlListTb.delegate = self;
    [self.view addSubview:emlListTb];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    return _emlArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellStr=@"Cell";
	EmlHeaderInfoCell *cell=(EmlHeaderInfoCell *)[tableView dequeueReusableCellWithIdentifier:cellStr] ;
	if(cell==nil)
	{
		cell=[[[EmlHeaderInfoCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellStr] autorelease];
	}
    EmlListInfoElement *emlListInfoElement = [_emlArr objectAtIndex:indexPath.row];
    [cell.textLabel setText:emlListInfoElement.name];
    [cell.detailTextLabel setText:emlListInfoElement.subject];
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 54.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    EmlListInfoElement *emlListInfoElement = [_emlArr objectAtIndex:indexPath.row];
    BOOL isNeedAnalyzed = [[DBControl shareDBControl] emlIsAnalyzed:emlListInfoElement.uidl];
    if (!isNeedAnalyzed) {
        //需要解析,先解析，再读取
        [self analyzeEml:emlListInfoElement.uidl];
    }
    
    NSString *contentJsonStr = [[DBControl shareDBControl] getContentJson:emlListInfoElement.uidl];
    EmlViewController *emlViewController = [[EmlViewController alloc] initWithNibName:nil bundle:nil];
    emlViewController.uidl = emlListInfoElement.uidl;
    emlViewController.contentJson = contentJsonStr;
    emlViewController.name = emlListInfoElement.name;
    emlViewController.eml = emlListInfoElement.eml;
    emlViewController.subject = emlListInfoElement.subject;
    [self.navigationController pushViewController:emlViewController animated:YES];
    [emlViewController release];
}

- (void)analyzeEml:(NSString *)uidl
{
    EmlAnalyze *emlAnalyze = [[EmlAnalyze alloc] init];
    NSString *documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *emlFileDirectory = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"EmlFiles/%@.eml",uidl]];
    
    [emlAnalyze analyzeEmlFileWith:[NSString stringWithContentsOfFile:emlFileDirectory encoding:NSUTF8StringEncoding error:nil] uidl:uidl];
}
@end
