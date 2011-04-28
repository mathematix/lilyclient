//
//  PostDetailController.m
//  Lilybbs
//
//  Created by panda on 11-4-7.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "PostDetailController.h"
#import "PostController.h"

@implementation PostDetailController
@synthesize _postDetailView;
@synthesize urlString;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
  //initialize a mainView
	_postDetailView = [[PostDetailView alloc]initWithFrame:[UIScreen mainScreen].applicationFrame];
  _postDetailView.urlString = urlString;

	self.view=_postDetailView;	//make the mainView as the view of this controller
	[_postDetailView release];	//don't forget to release what you've been allocated
	
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillDisappear:(BOOL)animated{
  //如果view的graburl线程还没有结束，那么在这儿cancel掉
  if (((PostDetailView*)(self.view)).isLoadingFinished==false) {
    [((PostDetailView*)(self.view)).http_request cancel];
  }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc
{
  [urlString release];
 // [_postDetailView release];
  [super dealloc];
}



@end
