//
//  BaseTableViewController.h
//  Lilybbs
//
//  本类为第二层controller提供一系列统一接口以及实现，例如判断登录等。
//
//  Created by panda on 11-4-27.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIHTTPRequest.h"


@interface BaseTableViewController : UITableViewController {
  NSArray *list;
  ASIHTTPRequest *request;
  BOOL isLoadingFinished;
}
@property (nonatomic, retain) NSArray* list;
@property (nonatomic, retain) ASIHTTPRequest *request;;

-(void)checkLogin;

-(void)doLogin;

@end
