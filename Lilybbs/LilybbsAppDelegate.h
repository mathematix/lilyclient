//
//  LilybbsAppDelegate.h
//  Lilybbs
//
//  Created by panda on 11-4-1.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LilybbsAppDelegate : NSObject <UIApplicationDelegate> {
  UINavigationController *navController;
  NSString* username;
  NSString* password;
  NSString* cookie_value;
  NSDictionary* cookie_dic;
  BOOL isLogin;
  BOOL shouldRefreshView;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navController;
@property (nonatomic, retain) NSString* username;
@property (nonatomic, retain) NSString* password;
@property (nonatomic, retain) NSString* cookie_value;
@property (nonatomic, retain) NSDictionary* cookie_dic;

@property BOOL isLogin;
@property BOOL shouldRefreshView;

@end
