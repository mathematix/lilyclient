//
//  TopAllViewController.h
//  Lilybbs
//
//  Created by panda on 11-4-7.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseTableViewController.h"
#import "LoadingView.h"

@interface TopAllViewController : BaseTableViewController {
  //loading遮盖层
  LoadingView *loadingView;
}

@property (nonatomic, retain) LoadingView* loadingView;

//从服务器获取热点数据
-(void)grabURLInBackground;
- (void)btnAction;

@end
