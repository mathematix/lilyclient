//
//  TopAllViewController.m
//  Lilybbs
//
//  Created by panda on 11-4-7.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "TopAllViewController.h"
#import "LilybbsAppDelegate.h"
#import "PostController.h"
#import "TFHpple.h"
#import "RegexKitLite.h"
#import "LoginViewController.h"
#import "PostDetailController.h"

static NSString *haveLoggedKey = @"登出";

@implementation TopAllViewController
@synthesize sectionNames;

#pragma mark -
#pragma mark override Methods

- (void)viewWillAppear:(BOOL)animated{
  LilybbsAppDelegate* lilydelegate = (LilybbsAppDelegate *)[[UIApplication sharedApplication]delegate];
  if(lilydelegate.isLogin == true){
    self.navigationItem.rightBarButtonItem.title = haveLoggedKey;
  }
  if (lilydelegate.shouldRefreshView==true) {
    //显示loading遮罩
    loadingView = [LoadingView loadingViewInView:self.view.superview];
    //线程异步加载数据
    [self grabURLInBackground];
  }
}

- (void)viewWillDisappear:(BOOL)animated{
  //如果graburl线程还没有结束，那么在这儿cancel掉
  if (isLoadingFinished==false) {
    [request cancel];
  }
}

- (void)viewDidLoad {
  //添加登录按钮
  [self addRightLoginButton];
  
  [super viewDidLoad];
}

- (void)viewDidUnload {
  self.sectionNames = nil;
  self.list = nil;
  self.loadingView = nil;
}
- (void)dealloc {
  [request clearDelegatesAndCancel];
  [request release];
  [loadingView release];
  [sectionNames release];
  [list release];
  [super dealloc];
}


#pragma mark -
#pragma mark Table Data Source Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return [self.list count];
}

- (NSString *)tableView:(UITableView *)atableView titleForHeaderInSection:(NSInteger)section
{
  if ([sectionNames count]<2) {
    sectionNames = [[NSArray alloc]initWithObjects:
                    @"本站系统", @"南京大学", 
                    @"乡情校谊", @"电脑技术",
                    @"学术科学", @"文化艺术",
                    @"体育娱乐", @"感性休闲",
                    @"新闻信息", @"百合广角",
                    @"校务信箱", @"社团群体",
                    nil];
  }
  
  return [sectionNames objectAtIndex:section];
}

- (NSInteger)tableView:(UITableView *)tableView 
 numberOfRowsInSection:(NSInteger)section {
  return [[list objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView 
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  
  
  static NSString * DisclosureCellIdentifier = @"PostListItem";
  
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: 
                           DisclosureCellIdentifier];
  if (cell == nil) {
    //从postListItem.xib载入view
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"PostListItem" owner:self options:nil];
		cell = (UITableViewCell *)[nib objectAtIndex:0];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
  }
  NSUInteger row = [indexPath row];
  NSString *post_name = [[[list objectAtIndex:indexPath.section] objectAtIndex:row] objectForKey:@"post_name"];
  NSString *board_name = [[[list objectAtIndex:indexPath.section] objectAtIndex:row] objectForKey:@"board_name"];
  
  UILabel *textLabel = (UILabel *)[cell viewWithTag:1];
	textLabel.text = post_name;
	UILabel *userLabel = (UILabel *)[cell viewWithTag:2];
	userLabel.text = @"";
  UILabel *boardLabel = (UILabel *)[cell viewWithTag:3];
	boardLabel.text = board_name;
  
  return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 50;
}



#pragma mark -
#pragma mark Table Delegate Methods


- (void)tableView:(UITableView *)tableView 
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  PostDetailController *nextController = [[[PostDetailController alloc] init] autorelease];
  //将post的url传入
  nextController.urlString = [[[list objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]objectForKey:@"post_url"];
  [self.navigationController pushViewController:nextController animated:YES];
  
}


#pragma mark - grab url
- (void)grabURLInBackground
{
  isLoadingFinished=false;
  
  NSURL *url = [NSURL URLWithString:@"http://bbs.nju.edu.cn/bbstopall"];
  
  request = [ASIHTTPRequest requestWithURL:url];
  [request setDelegate:self];
  [request setResponseEncoding:-2147483623];
  [request setDefaultResponseEncoding:-2147483623];
  [request startAsynchronous];
}

- (void)requestFinished:(ASIHTTPRequest *)arequest
{
  //因为服务器返回的data是压缩过的，因此responseString是空值，必须通过responseData来转换。而responseData转换后是写成Unicode格式(\xxxx)的gb2312，因此这边处理起来比较麻烦
  NSData* responseData = [arequest responseData];
  NSStringEncoding enc = 
  CFStringConvertEncodingToNSStringEncoding (kCFStringEncodingGB_18030_2000); 
  NSString *responseString=[[NSString alloc]initWithData:responseData encoding:enc];
  
  NSMutableArray* sections = [[[NSMutableArray alloc]init]autorelease];
  //分开section
  //  regEx = @"<img class=hand onclick='location=\"bbsboa\\?sec=(.*)\"'";
  NSString * regEx_sections = @"<td colspan=2>";
  NSArray* matchArray_sections = [responseString componentsSeparatedByRegex:regEx_sections];
  
  for (int i=1; i<[matchArray_sections count]; i++) {
    NSArray* matchArray_posts = [[matchArray_sections objectAtIndex:i] componentsSeparatedByRegex:@"<td>○"];
    NSMutableArray* posts = [[[NSMutableArray alloc]init]autorelease];
    for (int j=1; j<[matchArray_posts count]; j++) {
      
      NSMutableDictionary* post = [[[NSMutableDictionary alloc]init]autorelease];
      //奇怪的正则表达式
      NSString* regEx_post = @"<a href=\"(.*)\">(.*)</a> \\[<a href=(.*)>(.*)</a>";
      NSString* tmp = [matchArray_posts objectAtIndex:j];
      tmp = [tmp stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
      tmp = [tmp stringByReplacingOccurrencesOfString:@"\n" withString:@""];
      [post setValue:[tmp stringByMatching:regEx_post capture:1L] forKey:@"post_url"];
      [post setValue:[tmp stringByMatching:regEx_post capture:2L] forKey:@"post_name"];
      [post setValue:[tmp stringByMatching:regEx_post capture:3L] forKey:@"board_url"];
      [post setValue:[tmp stringByMatching:regEx_post capture:4L] forKey:@"board_name"];
      [posts addObject:post];
    }
    [sections addObject:posts];
  }
  
  self.list = sections;
  [self.tableView reloadData];
  if (loadingView) {
    [loadingView removeView];
  }
  isLoadingFinished=true;
}

- (void)requestFailed:(ASIHTTPRequest *)arequest
{
  [loadingView removeView];
  NSError *error = [arequest error];
  //如果超时了，就提示载入失败，要区别于code等于4(就是该request被cancel掉)
  if ([error code]==2) {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" 
                                                    message:@"载入失败！请重试！"
                                                   delegate:nil 
                                          cancelButtonTitle:@"确定" 
                                          otherButtonTitles:nil];
    [alert show];
    [alert release];  
  }
  isLoadingFinished=true;
}



@end
