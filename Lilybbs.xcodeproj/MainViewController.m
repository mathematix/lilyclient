//
//  MainViewController.m
//  Lilybbs
//
//  Created by panda on 11-4-1.
//  Copyright 2011年 __badpanda__. All rights reserved.
//

#import "MainViewController.h"
#import "TopTenViewController.h"
#import "TopAllViewController.h"
#import "ASIHTTPRequest.h"
#import "LoginViewController.h"
#import "LilybbsAppDelegate.h"
#import "SectionsViewController.h"

//登陆和登出的key，用于显示，以及判断不同的key，在action中进行不同的操作
static NSString *notLoggedKey = @"登入";
static NSString *haveLoggedKey = @"登出";

@implementation MainViewController
@synthesize controllers;


#pragma mark - 
#pragma mark Sys 

- (void) viewWillAppear: (BOOL)animated{
  //从AppDelegate中取出共享数据。如果isLogin为true，则将导航栏的右边字样改成"登出"
  LilybbsAppDelegate* lilydelegate = (LilybbsAppDelegate *)[[UIApplication sharedApplication]delegate];
  if(lilydelegate.isLogin == true){
    self.navigationItem.rightBarButtonItem.title = haveLoggedKey;
  }else{
    self.navigationItem.rightBarButtonItem.title = notLoggedKey;  
  }
}

- (void)viewDidLoad {
  
  [self addRightLoginButton];
  
  self.title = @"LilyBBS";
  
  NSMutableArray *array = [[NSMutableArray alloc] init]; 

  //top 10
  TopTenViewController *topTenViewController =[[TopTenViewController alloc] initWithNibName:@"TopTenDetail" bundle:nil];
  topTenViewController.title = @"全站十大";

  [array addObject:topTenViewController];
  [topTenViewController release];

  //top all
  TopAllViewController *topAllViewController = [[TopAllViewController alloc]initWithNibName:@"TopAllDetail" bundle:nil];
  topAllViewController.title = @"各区热点";

  [array addObject:topAllViewController];
  [topAllViewController release];
  
  //sections
  SectionsViewController*  sectionsViewController = [[SectionsViewController alloc]initWithNibName:@"SectionsView" bundle:nil];
  sectionsViewController.title = @"分类讨论区";
  
  [array addObject:sectionsViewController];
  [sectionsViewController release];
  
  self.controllers = array; 
  [array release]; 
  [super viewDidLoad];
}

- (void)viewDidUnload {
  self.controllers = nil; 
  [super viewDidUnload];
} 

- (void)dealloc {
  [controllers release]; 
  [super dealloc];
} 

#pragma mark - 
#pragma mark Table Data Source Methods 
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section { 
  return [self.controllers count];
} 

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath { 
  static NSString *FirstLevelCell= @"firstlevelcell"; 
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:FirstLevelCell];
  if (cell == nil) { cell = [[[UITableViewCell alloc]
                              initWithStyle:UITableViewCellStyleDefault reuseIdentifier: FirstLevelCell] autorelease];
  } // Configure the cell 
  NSUInteger row = [indexPath row]; 
  UITableViewController *controller = [controllers objectAtIndex:row]; 
  cell.textLabel.text = controller.title; 
  cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator; 
  return cell;
} 

#pragma mark - 
#pragma mark Table View Delegate Methods 
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  NSUInteger row = [indexPath row]; 
  UITableViewController *nextController = [self.controllers objectAtIndex:row];
  LilybbsAppDelegate* lilydelegate = (LilybbsAppDelegate *)[[UIApplication sharedApplication]delegate];
  lilydelegate.shouldRefreshView = true;
  [self.navigationController pushViewController:nextController animated:YES];
}


@end
