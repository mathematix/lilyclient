//
//  TopAllViewController.m
//  Lilybbs
//
//  Created by panda on 11-4-7.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "TopAllViewController.h"
#import "LilybbsAppDelegate.h"
#import "PostController.h"

//static NSString *notLoggedKey = @"登入";
static NSString *haveLoggedKey = @"登出";

@implementation TopAllViewController
@synthesize list;


- (void)viewWillAppear:(BOOL)animated{
  LilybbsAppDelegate* lilydelegate = (LilybbsAppDelegate *)[[UIApplication sharedApplication]delegate];
  if(lilydelegate.isLogin == true){
    self.navigationItem.rightBarButtonItem.title = haveLoggedKey;
  }
}

- (void)viewDidLoad {
  NSArray *array = [[NSArray alloc] initWithObjects:@"Toy Story",
                    @"A Bug's Life", @"Toy Story 2", @"Monsters, Inc.", 
                    @"Finding Nemo", @"The Incredibles", @"Cars", 
                    @"Ratatouille", @"WALL-E", @"Up", @"Toy Story 3",
                    @"Cars 2", @"The Bear and the Bow", @"Newt", nil];
  self.list = array;
  [array release];
  [super viewDidLoad];
}
- (void)viewDidUnload {
  self.list = nil;
}
- (void)dealloc {
  [list release];
  [super dealloc];
}
#pragma mark -
#pragma mark Table Data Source Methods
- (NSInteger)tableView:(UITableView *)tableView 
 numberOfRowsInSection:(NSInteger)section {
  return [list count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView 
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  
  static NSString * DisclosureButtonCellIdentifier = 
  @"DisclosureButtonCellIdentifier";
  
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: 
                           DisclosureButtonCellIdentifier];
  if (cell == nil) {
    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
                                   reuseIdentifier: DisclosureButtonCellIdentifier]
            autorelease];
  }
  NSUInteger row = [indexPath row];
  NSString *rowString = [list objectAtIndex:row];
  cell.textLabel.text = rowString;
  cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
  [rowString release];
  return cell;
}

#pragma mark -
#pragma mark Table Delegate Methods


- (void)tableView:(UITableView *)tableView 
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.row==0) {
    PostController* postcontroller = [[PostController alloc] initWithNibName:@"PostView" bundle:nil];
    postcontroller.title = @"发表文章";
    postcontroller.urlString = @"bbspst?board=test";
    [self.navigationController pushViewController:postcontroller animated:YES];
  }
  if (indexPath.row==1) {

  }

//  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:
//                        @"Hey, do you see the disclosure button?" 
//                                                  message:@"If you're trying to drill down, touch that instead"
//                                                 delegate:nil 
//                                        cancelButtonTitle:@"Won't happen again" 
//                                        otherButtonTitles:nil];
//  [alert show];
//  [alert release];
  
}
- (void)tableView:(UITableView *)tableView 
accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
//  if (childController == nil)
//    childController = [[DisclosureDetailController alloc] 
//                       initWithNibName:@"DisclosureDetail" bundle:nil];
//  
//  childController.title = @"Disclosure Button Pressed";
//  NSUInteger row = [indexPath row];
//  
//  NSString *selectedMovie = [list objectAtIndex:row];
//  NSString *detailMessage  = [[NSString alloc] 
//                              initWithFormat:@"You pressed the disclosure button for %@.", 
//                              selectedMovie];
//  childController.message = detailMessage;
//  childController.title = selectedMovie;
//  [detailMessage release];
//  
//  [self.navigationController pushViewController:childController
//                                       animated:YES];
}

@end
