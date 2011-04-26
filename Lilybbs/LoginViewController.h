//
//  AuthenticationViewController.h
//  Part of the ASIHTTPRequest sample project - see http://allseeing-i.com/ASIHTTPRequest for details
//
//  Created by Ben Copsey on 01/08/2009.
//  Copyright 2009 All-Seeing Interactive. All rights reserved.
//

#import <UIKit/UIKit.h>
#import	"SampleViewController.h"
#import "LoginDelegate.h"
@class ASIHTTPRequest;
@class ASIFormDataRequest;

@interface LoginViewController : SampleViewController <UITextFieldDelegate>{
  NSArray *dataSourceArray;
  UITextField* userfield;
  UITextField* pwfield;
  UISwitch* remswitch;
  ASIFormDataRequest* request;
  UIActivityIndicatorView *activityIndicator;
  NSObject<LoginDelegate>* delegate;
  
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
@property(nonatomic, retain) NSObject<LoginDelegate> * delegate;


@end
