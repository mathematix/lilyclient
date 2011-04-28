//
//  BaseTableViewController.h
//  Lilybbs
//
//  本类为tableview controller提供一系列统一接口以及实现，例如判断登录等。
//
//  Created by panda on 11-4-27.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIHTTPRequest.h"
#import "LoadingView.h"

@interface BaseTableViewController : UITableViewController {
  //保存该view中需要显示的数据
  NSArray *list;
  ASIHTTPRequest *request;
  //标志requst是否结束，以此判断是否需要进行requst cancel
  BOOL isLoadingFinished;
  //loading遮盖层
  LoadingView *loadingView;
}
@property (nonatomic, retain) NSArray* list;
@property (nonatomic, retain) ASIHTTPRequest *request;;
@property (nonatomic, retain) LoadingView* loadingView;

//判断是否登录
-(void)checkLogin;
-(void)checkLoginSucceed:(ASIHTTPRequest *) formRequest;
-(void)checkLoginFailed:(ASIHTTPRequest *) formRequest;
//登录操作(和实现登录按钮不同的是，这里在后台自动进行，即自动重连功能)
-(void)doLogin;
//navigationbar右边按钮事件
- (void)switchLoginAction;
//从服务器异步获取数据
- (void)grabURLInBackground;
//添加导航栏右边的登录按钮
- (void)addRightLoginButton;
@end
