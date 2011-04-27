//
//  PostDetailController.h
//  Lilybbs
//
//  Created by panda on 11-4-7.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LilybbsAppDelegate.h"
#import "PostDetailView.h"
#import "TFHpple.h"

@interface PostDetailController : UIViewController {
  //没有xib，手动生成view
	PostDetailView* _postDetailView;
  NSString* urlString;
}

@property (nonatomic,retain)PostDetailView* _postDetailView;

@property (nonatomic,retain)NSString* urlString;

@end
