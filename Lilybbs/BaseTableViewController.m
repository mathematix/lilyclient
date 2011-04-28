//
//  BaseTableViewController.m
//  Lilybbs
//
//  Created by panda on 11-4-27.
//  Copyright 2011年 __badpanda__. All rights reserved.
//

#import "BaseTableViewController.h"
#import "LoginViewController.h"
#import "LilybbsAppDelegate.h"
#import "ASIFormDataRequest.h"
#import "RegexKitLite.h"

static NSString *notLoggedKey = @"登入";

@implementation BaseTableViewController

@synthesize list,request,loadingView;


-(void)checkLogin{
  LilybbsAppDelegate* lilydelegate = (LilybbsAppDelegate *)[[UIApplication sharedApplication]delegate];
  //这里用一个必须要登录才能访问的bbsinfo页面来做判断，流量很小，只返回800byte
  NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://bbs.nju.edu.cn/bbsinfo?%@",lilydelegate.cookie_value]];
  
  request = [ASIHTTPRequest requestWithURL:url];
  [request setDelegate:self];
  [request setDidFinishSelector:@selector(checkLoginSucceed:)];
  [request setDidFailSelector:@selector(checkLoginFailed:)];
  [request startAsynchronous];
}

-(void)checkLoginSucceed:(ASIHTTPRequest *) formRequest{
  LilybbsAppDelegate* lilydelegate = (LilybbsAppDelegate *)[[UIApplication sharedApplication]delegate];
  //如果返回的html中包含"错误"，则说明没有登录
  if ([[formRequest responseString] rangeOfString:@"错误! 您尚未登录!"].location != NSNotFound){
    lilydelegate.isLogin = false;
    lilydelegate.cookie_value = @"";
    lilydelegate.cookie_dic = nil;
  }else{
    //do nothing
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


-(void)doLogin{
  NSURL *url;
  
  url = [NSURL URLWithString:@"http://bbs.nju.edu.cn/vd15734/bbslogin?type=2"];
  
  LilybbsAppDelegate* lilydelegate = (LilybbsAppDelegate *)[[UIApplication sharedApplication]delegate];
  
  ASIFormDataRequest* arequest = [ASIFormDataRequest requestWithURL:url];
  [arequest setPostValue:lilydelegate.username forKey:@"id"];
  [arequest setPostValue:lilydelegate.password forKey:@"pw"];
  [arequest setDidFinishSelector:@selector(doLoginSucceed:)];
  [arequest setDidFailSelector:@selector(doLoginFailed:)];
  [arequest setDelegate:self];
  [arequest setUseSessionPersistence:NO]; //Shouldn't be needed as this is the default
  [arequest setShouldRedirect:true];
  [arequest startAsynchronous];
}

-(void)doLoginSucceed:(ASIHTTPRequest *) formRequest{
  if ([[formRequest responseString] rangeOfString:@"setCookie"].location != NSNotFound){
    NSString * myResponseString = [formRequest responseString];
    
    NSString *regEx = @"setCookie\\(\\'(.*)\\'\\)";
    NSString *match = [myResponseString stringByMatching:regEx capture:1L];
    
    if ([match isEqualToString:@""]==NO) {
      int i = [match intValue]+2;  
      NSInteger start = [[NSString stringWithFormat:@"%d", i] length];
      NSInteger end = [match rangeOfString:@"+"].location;
      NSString *uid = [match substringWithRange:NSMakeRange(start+1, end-start-1)];
      NSInteger key = [[match substringFromIndex:end+1] intValue] - 2;
      
      NSMutableString* cookie_value = [[NSMutableString alloc]init];
      [cookie_value appendString:@"_U_NUM="];
      [cookie_value appendString:[NSString stringWithFormat:@"%d&", i]];
      [cookie_value appendString:@"_U_UID="];
      [cookie_value appendString:[NSString stringWithFormat:@"%@&", uid]];
      [cookie_value appendString:@"_U_KEY="];
      [cookie_value appendString:[NSString stringWithFormat:@"%d", key]];
      
      NSMutableDictionary* cookie_dic = [[[NSMutableDictionary alloc]init]autorelease];
      [cookie_dic setValue:[NSString stringWithFormat:@"%d", i] forKey:@"_U_NUM"];
      [cookie_dic setValue:uid forKey:@"_U_UID"];
      [cookie_dic setValue:[NSString stringWithFormat:@"%d", key] forKey:@"_U_KEY"];
      
      
      LilybbsAppDelegate* lilydelegate = (LilybbsAppDelegate *)[[UIApplication sharedApplication]delegate];
      lilydelegate.cookie_value = cookie_value;
      lilydelegate.cookie_dic = cookie_dic;
      lilydelegate.isLogin = true;
      [cookie_value release];
    }
  }
}

-(void)doLoginFailed:(ASIHTTPRequest *) formRequest{
  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" 
                                                  message:@"网络暂时忙，请重试"
                                                 delegate:nil 
                                        cancelButtonTitle:@"确定" 
                                        otherButtonTitles:nil];
  [alert show];
  [alert release];
}


-(void)addRightLoginButton{
  UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithTitle:notLoggedKey style:UIBarButtonItemStylePlain target:self action:@selector(switchLoginAction)];
  [self.navigationItem setRightBarButtonItem:rightBarButton];
  [rightBarButton release];
}

-(void)grabURLInBackground{
}


#pragma mark - switch login

- (void)switchLoginAction{
  if ([self.navigationItem.rightBarButtonItem.title isEqualToString:notLoggedKey]) {
    LoginViewController* controller = [[[LoginViewController alloc] initWithNibName:@"Sample" bundle:nil] autorelease];
    [self.navigationController presentModalViewController:controller animated:YES];
  }
  else{
    /* 登出操作 */
    LilybbsAppDelegate* lilydelegate = (LilybbsAppDelegate *)[[UIApplication sharedApplication]delegate];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://bbs.nju.edu.cn/bbslogout?%@",lilydelegate.cookie_value]];
    
    request = [ASIHTTPRequest requestWithURL:url];
    [request setDelegate:self];
    [request setDidFinishSelector:@selector(logoutSucceed:)];
    [request setDidFailSelector:@selector(logoutFailed:)];
    [request startAsynchronous];
  }
}

- (void)logoutSucceed:(ASIHTTPRequest *) aRequest
{ 
  //如果返回的html中包含以下数据，则表明logout成功了，此处是否需要做这个判断？
  if ([[aRequest responseString] rangeOfString:@"Net.BBS.clearCookie"].location != NSNotFound) {
  }
  
  LilybbsAppDelegate* lilydelegate = (LilybbsAppDelegate *)[[UIApplication sharedApplication]delegate];
  lilydelegate.isLogin = false;
  lilydelegate.cookie_value = @"";
  lilydelegate.cookie_dic = nil;
  [self.navigationItem rightBarButtonItem].title = notLoggedKey;
  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" 
                                                  message:@"成功登出"
                                                 delegate:nil 
                                        cancelButtonTitle:@"确定" 
                                        otherButtonTitles:nil];
  [alert show];
  [alert release]; 
}

- (void)logoutFailed:(ASIHTTPRequest *) aRequest
{ 
  NSLog(@"logout failed");
}

@end
