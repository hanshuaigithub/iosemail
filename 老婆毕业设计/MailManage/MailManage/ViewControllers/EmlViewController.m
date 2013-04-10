//
//  EmlViewController.m
//  MailManage
//
//  Created by 韩 帅 on 13-4-9.
//  Copyright (c) 2013年 韩 帅. All rights reserved.
//

#import "EmlViewController.h"
#import "SBJsonParser.h"

#define KWebViewH 350.0

@interface EmlViewController () <UITableViewDataSource,UITableViewDelegate>
{
    UITableView *emlTb;
    float contentCellH;//邮件内容cell高度
    NSMutableArray *htmlSrcPathArr;//html文件数组
    NSMutableArray *plainSrcArr;//纯文本数据数组
}
@end

@implementation EmlViewController
@synthesize contentJson = _contentJson;
@synthesize name = _name;
@synthesize eml = _eml;
@synthesize subject = _subject;
@synthesize uidl = _uidl;

- (void)dealloc
{
    MMRelease(emlTb);
    MMRelease(htmlSrcPathArr);
    MMRelease(plainSrcArr);
    self.contentJson = nil;
    self.name = nil;
    self.eml = nil;
    self.subject = nil;
    self.uidl = nil;
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
    
    htmlSrcPathArr = [[NSMutableArray alloc] init];
    plainSrcArr = [[NSMutableArray alloc] init];
    
    emlTb = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
    emlTb.dataSource = self;
    emlTb.delegate = self;
    [self.view addSubview:emlTb];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setContentJson:(NSString *)contentJson
{
    MMRelease(_contentJson);
    _contentJson = [contentJson retain];
    
    contentCellH = 0.0;
    
    SBJsonParser *jsonP = [[SBJsonParser alloc] init];
    NSDictionary *contentJsonDic = [jsonP objectWithString:_contentJson];
    NSDictionary *contentsDic = [contentJsonDic objectForKey:@"emlJson"];
    
    
    for (NSString *key in contentsDic.allKeys) {
        if ([key hasPrefix:@"childcontent"]) {
            NSDictionary *childContentDic = [contentsDic objectForKey:key];
            
            NSString *documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
            NSString *srcPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"emlContentFiles/%@/%@",_uidl,[childContentDic objectForKey:@"src"]]];
            
            NSString *type = [childContentDic objectForKey:@"type"];
            if ([type isEqualToString:@"html"]) {
                [htmlSrcPathArr addObject:srcPath];
                contentCellH += KWebViewH;
            }
            else if ([type isEqualToString:@"plain"])
            {
                NSString *childContentStr = [NSString stringWithContentsOfFile:srcPath encoding:NSUTF8StringEncoding error:nil];
                CGSize size = [childContentStr sizeWithFont:[UIFont systemFontOfSize:14]
                                          constrainedToSize:CGSizeMake(self.view.frame.size.width-20, 2000)
                                              lineBreakMode:UILineBreakModeWordWrap];
                [plainSrcArr addObject:childContentStr];
                contentCellH += size.height;
            }
        }
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    if (_subject == nil) {
        return 2;
    }
    else
    {
        return 3;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellStr=@"Cell";
	UITableViewCell *cell=(UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellStr] ;
	if(cell==nil)
	{
		cell=[[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellStr] autorelease];
	}
    if (indexPath.row == 0) {
        [cell.textLabel setText:[NSString stringWithFormat:@"发件人:%@",_name]];
    }
    
    
    if (_subject != nil) {
        if (indexPath.row == 1)
        {
            [cell.textLabel setText:[NSString stringWithFormat:@"主题:%@",_subject]];
        }
    }
    else
    {
        
    }
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return 35.0;
    }
    else
    {
        if (_subject !=nil) {
            if (indexPath.row == 1) {
                return 35.0;
            }
            else
            {
                return contentCellH>KWebViewH?contentCellH:350;
            }
        }
        else
        {
            return contentCellH>KWebViewH?contentCellH:385;
        }
    }
}

@end
