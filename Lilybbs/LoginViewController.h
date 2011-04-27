//
//  PostController.h
//  Lilybbs
//
//  Created by panda on 11-4-22.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//


#import <UIKit/UIKit.h>
#import	"SampleViewController.h"

@class ASIHTTPRequest;
@class ASIFormDataRequest;

@interface LoginViewController : SampleViewController <UITextFieldDelegate>{
  NSArray *dataSourceArray;
  UITextField* userfield;
  UITextField* pwfield;
  UISwitch* remswitch;
  ASIFormDataRequest* request;
  UIActivityIndicatorView *activityIndicator;
  
}

- (IBAction)loginAction:(id)sender;
- (IBAction)cancelAction:(id)sender;
- (NSString *)dataFilePath;
- (void)savePass:(id)sender;
- (void)switchSaveAction:(id)sender;
- (void)loadPass;

@property (nonatomic, retain) IBOutlet UITextField* userfield;
@property (nonatomic, retain) IBOutlet UITextField* pwfield;
@property (nonatomic, retain) IBOutlet UISwitch* remswitch;
@property (nonatomic, retain) NSArray *dataSourceArray;
@property (nonatomic, retain) ASIHTTPRequest* request;


@end
