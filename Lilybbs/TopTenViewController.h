//
//  TopTenViewController.h
//  Lilybbs
//
//  全站十大
//  Created by panda on 11-4-1.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LoadingView.h"
#import "ASIHTTPRequest.h"

@interface TopTenViewController : UITableViewController {
  NSArray *list;
  //loading遮盖层
  LoadingView *loadingView;
  ASIHTTPRequest *request;
}

@property (nonatomic, retain) NSArray* list;
@property (nonatomic, retain) LoadingView* loadingView;
@property (nonatomic, retain) ASIHTTPRequest *request;;


//从服务器获取十大数据
-(void)grabURLInBackground;
- (void)btnAction;

@end
