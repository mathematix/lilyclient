//
//  BaseViewController.h
//  Lilybbs
//
//  此controller为所有继承UIViewController的controller提供基础的接口
//
//  Created by panda on 11-4-28.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIHTTPRequest.h"

@interface BaseViewController : UIViewController {
  ASIHTTPRequest *check_request;
}

@property (nonatomic, retain) ASIHTTPRequest *check_request;;

//判断是否登录
- (void)checkLogin;
- (void)checkLoginSucceed:(ASIHTTPRequest *) formRequest;
- (void)checkLoginFailed:(ASIHTTPRequest *) formRequest;
//添加导航栏右边的登录按钮
- (void)addRightLoginButton;

@end
