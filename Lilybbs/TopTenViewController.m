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

static NSString *notLoggedKey = @"登入";
static NSString *haveLoggedKey = @"登出";

@implementation TopTenViewController
@synthesize loadingView;

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
 // [NSThread detachNewThreadSelector:@selector(myTaskMethod) toTarget:self withObject:nil];
  [self grabURLInBackground];
}

//- (void) viewDidDisappear:(BOOL)animated{
//  // Cancels an asynchronous request
//  NSLog(@"aaa");
//  if (request!=nil&&[request isFinished]) {
//    [request cancel];
//  }
//}

- (void)viewDidLoad {
  UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithTitle:notLoggedKey style:UIBarButtonItemStylePlain target:self action:@selector(btnAction)];
  [self.navigationItem setRightBarButtonItem:rightBarButton];
  [rightBarButton release];
  
  [super viewDidLoad];
}

- (void)viewDidDisappear:(BOOL)animated{
//  NSLog(@"concurrent%@",[request isConcurrent]);
//  if ([request isCancelled]==true) {
//    NSLog(@"iscanceled");
//  }
//  else
//    NSLog(@"notcanceled");
//  
//  if ([request isFinished]==true) {
//    NSLog(@"isfinished");
//  }
//  else
//    NSLog(@"notfinished");
//  
//  
  if (isLoadingFinished==false) {
    [request cancel];
  }
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
    // [loadingView performSelector:@selector(removeView) withObject:nil];
  }
  isLoadingFinished=true;
  [array release];
}

- (void)requestFailed:(ASIHTTPRequest *)arequest
{
  //NSError *error = [arequest error];
  isLoadingFinished=true;
}

- (void)btnAction{
  if ([self.navigationItem.rightBarButtonItem.title isEqualToString:notLoggedKey]) {
    LoginViewController* controller = [[[LoginViewController alloc] initWithNibName:@"Sample" bundle:nil] autorelease];
    [self.navigationController presentModalViewController:controller animated:YES];
  }
  else{
    /* TODO: 需要做登出操作 */
      LilybbsAppDelegate* lilydelegate = (LilybbsAppDelegate *)[[UIApplication sharedApplication]delegate];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://bbs.nju.edu.cn/bbslogout&",lilydelegate.cookie_value]];
    
    request = [ASIHTTPRequest requestWithURL:url];
    [request setDelegate:self];
    [request setDidFinishSelector:@selector(logoutSucceed:)];
    [request setDidFailSelector:@selector(logoutFailed:)];
    [request startAsynchronous];
  }
}

- (void)logoutSucceed:(ASIHTTPRequest *) aRequest
{ 
  NSLog([aRequest responseString]);
  /* TODO: 需要重写登出操作,这里输出的结果表明bbslogout不接受get？要试试用一个post？*/
  LilybbsAppDelegate* lilydelegate = (LilybbsAppDelegate *)[[UIApplication sharedApplication]delegate];
  lilydelegate.isLogin = false;
  lilydelegate.cookie_value = @"";
  [self.navigationItem rightBarButtonItem].title = notLoggedKey;
}

- (void)logoutFailed:(ASIHTTPRequest *) aRequest
{ 
  NSLog(@"logout failed");
}



@end
