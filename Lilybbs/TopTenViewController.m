//
//  TopTenViewController.m
//  Lilybbs
//
//  Created by panda on 11-4-1.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "TopTenViewController.h"
#import "LilybbsAppDelegate.h"
#import "TFHpple.h"
#import "PostDetailController.h"
#import "PostListItemModel.h"
#import "LoadingView.h"
#import "LoginViewController.h"

static NSString *haveLoggedKey = @"登出";

@implementation TopTenViewController

#pragma mark -
#pragma mark override Methods

- (void)viewWillAppear:(BOOL)animated {
  LilybbsAppDelegate* lilydelegate = (LilybbsAppDelegate *)[[UIApplication sharedApplication]delegate];
  if(lilydelegate.isLogin == true){
    self.navigationItem.rightBarButtonItem.title = haveLoggedKey;
  }
  //显示loading遮罩
  loadingView = [LoadingView loadingViewInView:self.view.superview];
  //线程异步加载数据
  [self grabURLInBackground];
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
  self.list = nil;
  loadingView = nil;
}

- (void)dealloc {
  [request clearDelegatesAndCancel];
  [request release];
  [loadingView release];
  [list release];
  [super dealloc];
}

#pragma mark -
#pragma mark Table Data Source Methods

- (NSInteger)tableView:(UITableView *)tableView 
 numberOfRowsInSection:(NSInteger)section {
  return [list count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 50;
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
  
  UILabel *textLabel = (UILabel *)[cell viewWithTag:1];
	textLabel.text = [[list objectAtIndex:row] title];
	UILabel *userLabel = (UILabel *)[cell viewWithTag:2];
	userLabel.text = [[list objectAtIndex:row] author];
  UILabel *boardLabel = (UILabel *)[cell viewWithTag:3];
	boardLabel.text = [[list objectAtIndex:row] board];
  
  return cell;
}


#pragma mark -
#pragma mark Table Delegate Methods

- (void)tableView:(UITableView *)tableView 
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  PostDetailController *nextController = [[[PostDetailController alloc] init] autorelease];
  //将post的url传入
  nextController.urlString = [(PostListItemModel*)[list objectAtIndex:[indexPath row]] url];
  //打开post detail页面
  [self.navigationController pushViewController:nextController animated:YES];
}

- (void)tableView:(UITableView *)tableView 
accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
  PostDetailController *nextController = [[PostDetailController alloc] init] ;
  [self.navigationController pushViewController:nextController animated:YES];
  [nextController release];
  
}

#pragma mark - grab url
- (void)grabURLInBackground
{
  isLoadingFinished=false;
  
  NSURL *url = [NSURL URLWithString:@"http://bbs.nju.edu.cn/bbstop10"];

  request = [ASIHTTPRequest requestWithURL:url];
  [request setDelegate:self];
  [request startAsynchronous];
}

- (void)requestFinished:(ASIHTTPRequest *)arequest
{
  TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:[arequest responseData]];   
  NSArray *elements  = [xpathParser search:@"//a"]; // get the title
  NSMutableArray *list_obj = [[[NSMutableArray alloc] init] autorelease]; 
  for (NSInteger i=0; i<10; i++) {
    PostListItemModel* postlistitem = [[[PostListItemModel alloc]init] autorelease];
    postlistitem.title = [[elements objectAtIndex:i*3+1] content];
    postlistitem.author = [[elements objectAtIndex:i*3+2] content];
    postlistitem.board = [[elements objectAtIndex:i*3] content];
    postlistitem.url = [[elements objectAtIndex:i*3+1] objectForKey:@"href"];
    [list_obj addObject:postlistitem];
  }

  NSArray *array = [[NSArray alloc] initWithArray:list_obj];
  self.list = array;
  [self.tableView reloadData];
  if (loadingView) {
    [loadingView removeView];
  }
  isLoadingFinished=true;
  [array release];
}

- (void)requestFailed:(ASIHTTPRequest *)arequest
{
  NSError *error = [arequest error];
  //如果超时了，就提示载入失败，要区别于code等于4(就是该request被cancel掉)
  [loadingView removeView];
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
