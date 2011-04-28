//
//  PostController.h
//  Lilybbs
//
//  Created by panda on 11-4-22.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "BaseViewController.h"

@interface PostController : BaseViewController {
  UITextView* content_view;
  ASIFormDataRequest* request;
  ASIHTTPRequest *reply_request;
  UILabel* titleLabel;
  UITextField* titleField;
  UIActivityIndicatorView* activityIndicator;
  NSString* urlString;
  NSMutableDictionary* postData;
  BOOL isPostingFinished;
  BOOL isCheckingFinished;
}
@property (nonatomic,retain) IBOutlet UITextView* content_view;
@property (nonatomic, retain) IBOutlet UITextField* titleField;
@property (nonatomic, retain) IBOutlet UILabel* titleLabel;
@property (nonatomic, retain) NSString* urlString;
@property (nonatomic, retain) NSMutableDictionary* postData;
@property BOOL isPostingFinished;
@property BOOL isCheckingFinished;

- (IBAction)cancel:(id)sender;
- (IBAction)post:(id)sender;
- (IBAction)backgroundTap:(id)sender;
- (IBAction)textFieldDoneEditing:(id)sender;

- (void) showNomalButton:(id) sender;
- (void) showDoneButton:(id)sender;
- (void) grabURLInBackground;
- (void) changeToNomalMode:(id) sender;
- (void) changeToEditMode:(id) sender;

@end
