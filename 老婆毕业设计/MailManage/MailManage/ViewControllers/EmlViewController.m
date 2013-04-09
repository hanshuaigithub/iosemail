//
//  EmlViewController.m
//  MailManage
//
//  Created by 韩 帅 on 13-4-9.
//  Copyright (c) 2013年 韩 帅. All rights reserved.
//

#import "EmlViewController.h"
#import "SBJsonParser.h"

@interface EmlViewController () <UITableViewDataSource,UITableViewDelegate>
{
    UITableView *emlTb;
}
@end

@implementation EmlViewController
@synthesize contentJson = _contentJson;

- (void)dealloc
{
    MMRelease(emlTb);
    self.contentJson = nil;
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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//- (void)setPlain:(NSString *)plain
//{
//    MMRelease(_plain);
//    _plain = [plain retain];
//
//    CGSize size = [_plain sizeWithFont:[UIFont systemFontOfSize:14]
//                     constrainedToSize:CGSizeMake(self.view.frame.size.width-20, 2000)
//                         lineBreakMode:UILineBreakModeWordWrap];
//
//    plainView = [[UITextView alloc] initWithFrame:CGRectMake(10, 0, self.view.frame.size.width-20, size.height)];
//    [plainView setText:_plain];
//}

- (void)setContentJson:(NSString *)contentJson
{
    SBJsonParser *jsonP = [[SBJsonParser alloc] init];
    NSDictionary *contentDic = [jsonP objectWithString:contentJson];
    
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellStr=@"Cell";
	UITableViewCell *cell=(UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellStr] ;
	if(cell==nil)
	{
		cell=[[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellStr] autorelease];
	}
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath == 0) {
        return 40.0;
    }
    else
    {
        
    }
}

@end
