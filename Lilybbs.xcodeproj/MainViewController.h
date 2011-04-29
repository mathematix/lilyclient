//
//  MainViewController.h
//  Lilybbs
//
//  Created by panda on 11-4-1.
//  Copyright 2011年 __badpanda__. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "LoginDelegate.h"
#import "BaseTableViewController.h"

//主view
@interface MainViewController : BaseTableViewController {
  //保存level 2的contoller
  NSArray *controllers;
}

@property (nonatomic, retain) NSArray *controllers;

@end
