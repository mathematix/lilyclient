//
//  MainViewController.h
//  Lilybbs
//
//  Created by panda on 11-4-1.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "LoginDelegate.h"

@interface MainViewController : UITableViewController <LoginDelegate> {
  NSArray *controllers;
}

@property (nonatomic, retain) NSArray *controllers;

@end
