//
//  BaseViewController.m
//  Lilybbs
//
//  Created by panda on 11-4-28.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "BaseViewController.h"
#import "LilybbsAppDelegate.h"
#import "RegexKitLite.h"

static NSString *notLoggedKey = @"登入";

@implementation BaseViewController
@synthesize check_request;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    // Custom initialization
  }
  return self;
}

- (void)dealloc
{
  [super dealloc];
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
  [super viewDidLoad];
}

- (void)viewDidUnload
{
  [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)addRightLoginButton{
  UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithTitle:notLoggedKey style:UIBarButtonItemStylePlain target:self action:@selector(switchLoginAction)];
  [self.navigationItem setRightBarButtonItem:rightBarButton];
  [rightBarButton release];
}

-(void)checkLogin{
  LilybbsAppDelegate* lilydelegate = (LilybbsAppDelegate *)[[UIApplication sharedApplication]delegate];
  //这里用一个必须要登录才能访问的bbsinfo页面来做判断，流量很小，只返回800byte
  NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://bbs.nju.edu.cn/bbsinfo?%@",lilydelegate.cookie_value]];
  
  check_request = [ASIHTTPRequest requestWithURL:url];
  [check_request setDelegate:self];
  [check_request setDidFinishSelector:@selector(checkLoginSucceed:)];
  [check_request setDidFailSelector:@selector(checkLoginFailed:)];
  [check_request startAsynchronous];
}

-(void)checkLoginSucceed:(ASIHTTPRequest *) formRequest{
  //如果返回的html中包含"错误"，则说明没有登录
  if ([[formRequest responseString] rangeOfString:@"错误! 您尚未登录!"].location != NSNotFound){
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" 
//                                                    message:@"错误，请重新登录！"
//                                                   delegate:nil 
//                                          cancelButtonTitle:@"确定" 
//                                          otherButtonTitles:nil];
//    [alert show];
//    [alert release];
    LilybbsAppDelegate* lilydelegate = (LilybbsAppDelegate *)[[UIApplication sharedApplication]delegate];
    lilydelegate.isLogin = false;
    lilydelegate.cookie_value = @"";
    lilydelegate.cookie_dic = nil;
  }
}

-(void)checkLoginFailed:(ASIHTTPRequest *) formRequest{
  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" 
                                                  message:@"网络暂时忙，请重试"
                                                 delegate:nil 
                                        cancelButtonTitle:@"确定" 
                                        otherButtonTitles:nil];
  [alert show];
  [alert release];
}



@end
