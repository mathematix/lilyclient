//
//  PostController.m
//  Lilybbs
//
//  Created by panda on 11-4-22.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "PostController.h"
#import <QuartzCore/QuartzCore.h>
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "RegexKitLite.h"
#import "LilybbsAppDelegate.h"
#import "TFHpple.h"

@implementation PostController
@synthesize content_view;
@synthesize titleField;
@synthesize titleLabel, urlString, postData, isPostingFinished, isCheckingFinished;

#pragma mark - sys

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)dealloc
{
  [request clearDelegatesAndCancel];
  [request release];
  [titleLabel release];
  [activityIndicator release];
  [urlString release];  
  [content_view release];
  [titleField release];
  [postData release];
  [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewWillAppear:(BOOL)animated{
  [self grabURLInBackground];
}

- (void)viewWillDisappear:(BOOL)animated{
  //如果view的graburl线程还没有结束，那么在这儿cancel掉
  if (isLoadingFinished==false) {
    [reply_request cancel];
  }
  //如果view的checking线程还没有结束，那么在这儿cancel掉
  if (isCheckingFinished==false) {
    [check_request cancel];
  }
  //如果view的posting线程还没有结束，那么在这儿cancel掉
  if (isPostingFinished==false) {
    [request cancel];
  }
  LilybbsAppDelegate* lilydelegate = (LilybbsAppDelegate *)[[UIApplication sharedApplication]delegate];
  lilydelegate.shouldRefreshView = true;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  //显示取消，发表按钮
  [self showNomalButton:self];
  //设置textview的属性
  [self.content_view.layer setBackgroundColor:[[UIColor whiteColor] CGColor]];
  [self.content_view.layer setBorderColor:[[UIColor grayColor] CGColor]];
  [self.content_view.layer setBorderWidth:1.0];
  //[self.content_view.layer setCornerRadius:4.0];
  [self.content_view.layer setMasksToBounds:YES];
  [self.content_view.layer setShadowRadius:2.0];
  self.content_view.clipsToBounds = YES;
  [content_view setFrame:CGRectMake(5, 50, 310, 405)];
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillAppear:) name:UIKeyboardWillShowNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillDisappear:) name:UIKeyboardWillHideNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillAppear:) name:UITextViewTextDidBeginEditingNotification object:nil];
}

- (void)viewDidUnload
{
  [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)keyboardWillAppear:(NSNotification *)notification {
  if([content_view isFirstResponder]){
    [self changeToEditMode:self];
  }
}

-(void)keyboardWillDisappear:(NSNotification *) notification {
  if([content_view isFirstResponder])
    [self changeToNomalMode:self];
}

- (void)showNomalButton:(id)sender{
  UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc]
                                   initWithTitle:@"取消"
                                   style:UIBarButtonItemStylePlain
                                   target:self
                                   action:@selector(cancel:)];
  self.navigationItem.leftBarButtonItem = cancelButton;
  [cancelButton release];
  
  UIBarButtonItem *saveButton = [[UIBarButtonItem alloc]
                                 initWithTitle:@"发表" 
                                 style:UIBarButtonItemStyleDone
                                 target:self
                                 action:@selector(post:)];
  self.navigationItem.rightBarButtonItem = saveButton;
  [saveButton release];
}

- (void)showDoneButton:(id)sender{
  self.navigationItem.leftBarButtonItem = nil;
  [self.navigationItem setHidesBackButton:true];
  UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]
                                 initWithTitle:@"完成" 
                                 style:UIBarButtonItemStyleDone
                                 target:self
                                 action:@selector(changeToNomalMode:)];
  self.navigationItem.rightBarButtonItem = doneButton;
}


- (void)changeToNomalMode:(id)sender{
  [UIView beginAnimations:nil context:NULL];
  [content_view setFrame:CGRectMake(5, 50, 310, 360)];
  [titleField setHidden:false];
  [titleLabel setHidden:false];
  [UIView commitAnimations];
  [self showNomalButton:self];
  [content_view resignFirstResponder];
}

- (void)changeToEditMode:(id)sender{
  [titleField setHidden:true];
  [titleLabel setHidden:true];
  [UIView beginAnimations:nil context:NULL];
  [content_view setFrame:CGRectMake(0, 0, 320, 180)];
  [UIView commitAnimations];
  [self showDoneButton:self];
}

- (IBAction)backgroundTap:(id)sender { 
 // [content_view resignFirstResponder]; 
  [titleField resignFirstResponder]; 
}


- (IBAction)textFieldDoneEditing:(id)sender{
  [sender resignFirstResponder];
}


-(IBAction)cancel:(id)sender{
  [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)post:(id)sender
{
  isCheckingFinished=false;
  [self checkLogin];
}

-(void)checkLoginSucceed:(ASIHTTPRequest *) formRequest{
  [super checkLoginSucceed:formRequest];
  LilybbsAppDelegate* lilydelegate = (LilybbsAppDelegate *)[[UIApplication sharedApplication]delegate];
  if(lilydelegate.isLogin==true){
    isPostingFinished = false;
    NSURL *url;
    url = [NSURL URLWithString:[NSString stringWithFormat:@"http://bbs.nju.edu.cn/%@&%@",[postData objectForKey:@"action"],lilydelegate.cookie_value]];
    NSString* title = [titleField text];
    NSString* content = [content_view text];
    
    activityIndicator = 
    [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    UIBarButtonItem * loadingButton = 
    [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
    
    [self.navigationItem setRightBarButtonItem:loadingButton];
    [loadingButton release];
    [activityIndicator startAnimating];
    
    //生成并提交form
    request = [ASIFormDataRequest requestWithURL:url];
    [request setPostValue:[postData objectForKey:@"pid"] forKey:@"pid"];
    [request setPostValue:[postData objectForKey:@"reid"] forKey:@"reid"];
    [request setPostValue:title forKey:@"title"];
    [request setPostValue:content forKey:@"text"];
    [request setStringEncoding:-2147483623];
    [request setDidFinishSelector:@selector(postSucceed:)];
    [request setDidFailSelector:@selector(postFailed:)];
    [request setDelegate:self];
    [request setUseSessionPersistence:NO];
    [request setShouldRedirect:true];
    [request startAsynchronous];
  }
  isCheckingFinished=true;
}

-(void)checkLoginFailed:(ASIHTTPRequest *)formRequest{
  [super checkLoginFailed:formRequest];
  isCheckingFinished = true;
}

- (void)postSucceed:(ASIHTTPRequest *) aRequest
{ 
  isPostingFinished = true;
  [activityIndicator stopAnimating];
  [activityIndicator release];
  /*TODO: 加入是否发表成功的判断*/
  [self.navigationController popViewControllerAnimated:YES];
}

- (void)postFailed:(ASIHTTPRequest *) aRequest
{ 
  NSLog(@"LOginfailed");
  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:
                        @"Hey, do you see the disclosure button?" 
                                                  message:@"fail to login"
                                                 delegate:nil 
                                        cancelButtonTitle:@"Won't happen again" 
                                        otherButtonTitles:nil];
  [alert show];
  [alert release];  
  isPostingFinished = true;
  [activityIndicator stopAnimating];
  [activityIndicator release];
}

//初始化
- (void)grabURLInBackground
{
  isLoadingFinished = false;
  LilybbsAppDelegate* lilydelegate = (LilybbsAppDelegate *)[[UIApplication sharedApplication]delegate];
  //相当于点击发表文章或者回复文章，主要是为了从返回的页面中获取pid
  NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://bbs.nju.edu.cn/%@&%@",urlString,lilydelegate.cookie_value]];
  reply_request = [ASIHTTPRequest requestWithURL:url];
  [reply_request setDelegate:self];
  [reply_request startAsynchronous];
}

- (void)requestFinished:(ASIHTTPRequest *)arequest
{
  postData = [[NSMutableDictionary alloc] init];
  
  TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:[arequest responseData]];  
  //  
  TFHppleElement* element = [[xpathParser search:@"//input[@name='title']"] objectAtIndex:0];
  NSString* title = [element objectForKey:@"value"];
  
  element = [[xpathParser search:@"//form[@name='form2']"] objectAtIndex:0];
  [postData setValue:[element objectForKey:@"action"] forKey:@"action"];  //
  
  element = [[xpathParser search:@"//input[@name='pid']"] objectAtIndex:0];
  [postData setValue:[element objectForKey:@"value"] forKey:@"pid"];  //
  
  element = [[xpathParser search:@"//input[@name='reid']"] objectAtIndex:0];
  [postData setValue:[element objectForKey:@"value"] forKey:@"reid"];  //
  
  [titleField setText:title];
  isLoadingFinished = true;
}

- (void)requestFailed:(ASIHTTPRequest *)arequest
{
  /*TODO: 错误处理*/
  //NSError *error = [arequest error];
  isLoadingFinished = true;
}


@end
