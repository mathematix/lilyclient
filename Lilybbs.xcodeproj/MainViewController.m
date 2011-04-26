//
//  MainViewController.m
//  Lilybbs
//
//  Created by panda on 11-4-1.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "MainViewController.h"
#import "TopTenViewController.h"
#import "TopAllViewController.h"
#import "ASIHTTPRequest.h"
#import "LoginViewController.h"
#import "LilybbsAppDelegate.h"

static NSString *notLoggedKey = @"登入";
static NSString *haveLoggedKey = @"登出";
//static NSString *cancelKey = @"取消";

@implementation MainViewController
@synthesize controllers;


- (void) viewWillAppear: (BOOL)animated{
  LilybbsAppDelegate* lilydelegate = (LilybbsAppDelegate *)[[UIApplication sharedApplication]delegate];
  if(lilydelegate.isLogin == true){
    self.navigationItem.rightBarButtonItem.title = haveLoggedKey;
  }
}


- (void)viewDidLoad {
  
  UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithTitle:notLoggedKey style:UIBarButtonItemStylePlain target:self action:@selector(loginAction)];
  [self.navigationItem setRightBarButtonItem:rightBarButton];
  [rightBarButton release];
  
  self.title = @"LilyBBS";
  NSMutableArray *array = [[NSMutableArray alloc] init]; 

  //top 10
  TopTenViewController *topTenViewController =[[TopTenViewController alloc]initWithStyle:UITableViewStylePlain];
  topTenViewController.title = @"Top Ten";
 // topTenViewController.rowImage = [UIImage 
 //                                        imageNamed:@"disclosureButtonControllerIcon.png"];
  [array addObject:topTenViewController];
  [topTenViewController release];

  //top all
  TopAllViewController *topAllViewController =[[TopAllViewController alloc]initWithStyle:UITableViewStylePlain];
  topAllViewController.title = @"Top All";
//  topAllViewController.rowImage = [UIImage 
 //                                        imageNamed:@"disclosureButtonControllerIcon.png"];
  [array addObject:topAllViewController];
  [topAllViewController release];
  
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
  TopTenViewController *controller = [controllers objectAtIndex:row]; 
  cell.textLabel.text = controller.title; 
//  cell.imageView.image = controller.rowImage; 
  cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator; 
  return cell;
} 

#pragma mark - 
#pragma mark Table View Delegate Methods 
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  NSUInteger row = [indexPath row]; 
  TopTenViewController *nextController = [self.controllers objectAtIndex:row];
  
  [self.navigationController pushViewController:nextController animated:YES];
}




- (void)loginAction {
  if ([self.navigationItem.rightBarButtonItem.title isEqualToString:notLoggedKey]) {
    LoginViewController* controller = [[[LoginViewController alloc] initWithNibName:@"Sample" bundle:nil] autorelease];
    controller.delegate = self;
    [self.navigationController presentModalViewController:controller animated:YES];
  }
  else{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:
                          @"Hey, do you see the disclosure button?" 
                                                    message:@"If you're trying to drill down, touch that instead"
                                                   delegate:nil 
                                          cancelButtonTitle:@"Won't happen again" 
                                          otherButtonTitles:nil];
    [alert show];
    [alert release];
  }
  
}



//
- (void)passValue:(NSString *)value
{
  self.navigationItem.rightBarButtonItem.title= value;
}


@end
