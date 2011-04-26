//
//  TopTenViewController.m
//  Lilybbs
//
//  Created by panda on 11-4-1.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "TopTenViewController.h"
#import "LilybbsAppDelegate.h"
#import "TFHpple.h"
#import "PostDetailController.h"
#import "PostListItemModel.h"

static NSString *notLoggedKey = @"登入";
static NSString *haveLoggedKey = @"登出";

@implementation TopTenViewController
@synthesize list;

-(NSArray*)postdata{
    
  NSURL *url;
  
  NSMutableURLRequest *urlRequest;
  
  NSMutableData *postBody = [NSMutableData data];
  
  url = [NSURL URLWithString:@"http://bbs.nju.edu.cn/bbstop10"];
  
  urlRequest = [[[NSMutableURLRequest alloc] initWithURL:url] autorelease];
  
  [urlRequest setHTTPBody:postBody];

  NSData *returnData = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:nil error:nil];
  
  if(returnData)
  {
    
   // NSString *result = [[NSString alloc] initWithData:returnData encoding:-2147483623];
        
    TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:returnData];   
    NSArray *elements  = [xpathParser search:@"//a"]; // get the title
    NSMutableArray *list_obj = [[[NSMutableArray alloc] init] autorelease]; 
    for (NSInteger i=0; i<10; i++) {
      PostListItemModel* postlistitem = [[[PostListItemModel alloc]init] autorelease];
      postlistitem.title = [[elements objectAtIndex:i*3+1] content];
      postlistitem.author = [[elements objectAtIndex:i*3+2] content];
      postlistitem.board = [[elements objectAtIndex:i*3] content];
      postlistitem.url = [[elements objectAtIndex:i*3+1] objectForKey:@"href"];
      [list_obj addObject:postlistitem];
    }
  //  TFHppleElement *element = [elements objectAtIndex:0];
  //  NSString *h1Tag = [element content];  
  //  NSLog(@"result = %@",h1Tag);
    return list_obj;
    
  }
  
  return nil;
}


-(void)myTaskMethod
{
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  NSArray *array = [[NSArray alloc] initWithArray:[self postdata]];
  self.list = array;
  [self.tableView reloadData];
  [array release];
  [pool release];
  
}

- (void)viewWillAppear:(BOOL)animated {
  LilybbsAppDelegate* lilydelegate = (LilybbsAppDelegate *)[[UIApplication sharedApplication]delegate];
  if(lilydelegate.isLogin == true){
    self.navigationItem.rightBarButtonItem.title = haveLoggedKey;
  }
  PostListItemModel* postlistitem = [[[PostListItemModel alloc]init] autorelease];
  postlistitem.title = @"Loading...";
  postlistitem.author = @"";
  postlistitem.board = @"";
  postlistitem.url = @"";
  NSArray *array = [[NSArray alloc] initWithObjects:postlistitem, nil];
  
  self.list = array;
  [self.tableView reloadData];
  if ([self.list count]<=2) {
    [NSThread detachNewThreadSelector:@selector(myTaskMethod) toTarget:self withObject:nil];
  }
}


- (void)viewDidLoad {
  UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithTitle:notLoggedKey style:UIBarButtonItemStylePlain target:self action:@selector(btnAction)];
  [self.navigationItem setRightBarButtonItem:rightBarButton];
  [rightBarButton release];
  
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 75;
}

- (UITableViewCell *)tableView:(UITableView *)tableView 
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  
  static NSString * DisclosureCellIdentifier = @"PostListItem";
  
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: 
                           DisclosureCellIdentifier];
  if (cell == nil) {
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"PostListItem" owner:self options:nil];
		cell = (UITableViewCell *)[nib objectAtIndex:0];
  }
  NSUInteger row = [indexPath row];
  
  UILabel *textLabel = (UILabel *)[cell viewWithTag:1];
	textLabel.text = [[list objectAtIndex:row] title];
	UILabel *userLabel = (UILabel *)[cell viewWithTag:2];
	userLabel.text = [[list objectAtIndex:row] author];
  UILabel *boardLabel = (UILabel *)[cell viewWithTag:3];
	boardLabel.text = [[list objectAtIndex:row] board];
  
 // NSString *rowString = [list objectAtIndex:row*3+1];
 // cell.textLabel.text = rowString;
 // cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
 // [rowString release];
  return cell;
}

#pragma mark -
#pragma mark Table Delegate Methods


- (void)tableView:(UITableView *)tableView 
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  PostDetailController *nextController = [[PostDetailController alloc] init] ;
  nextController.urlString = [[list objectAtIndex:[indexPath row]] url];
  [self.navigationController pushViewController:nextController animated:YES];
//  
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
  
  PostDetailController *nextController = [[PostDetailController alloc] init] ;
  
  [self.navigationController pushViewController:nextController animated:YES];
  
  [nextController release];
  
//  
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
