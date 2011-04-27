//
//  LilybbsAppDelegate.m
//  Lilybbs
//
//  Created by panda on 11-4-1.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "LilybbsAppDelegate.h"

@implementation LilybbsAppDelegate


@synthesize window=_window;
@synthesize navController;
@synthesize username,password,cookie_value;
@synthesize isLogin;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  [self.window addSubview: navController.view];
  [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
}

- (void)applicationWillTerminate:(UIApplication *)application
{
}

- (void)dealloc
{
  [navController release];
  [_window release];
    [super dealloc];
}

@end
