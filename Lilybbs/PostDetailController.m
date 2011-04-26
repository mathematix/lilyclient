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
        // Custom initialization
    }
    return self;
}


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	_postDetailView = [[PostDetailView alloc]initWithFrame:[UIScreen mainScreen].applicationFrame];		//initialize a mainView
  _postDetailView.urlString = urlString;
 // _postDetailView.urlString = urlString;
	self.view=_postDetailView;	//make the mainView as the view of this controller
	[_postDetailView release];	//don't forget to release what you've been allocated
	
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc
{
  [_postDetailView release];
  [super dealloc];
}



@end
