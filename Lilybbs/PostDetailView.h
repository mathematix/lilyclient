//
//  POstDetailView.h
//  Lilybbs
//
//  Created by panda on 11-4-1.
//  Copyright 2011年 __badpanda__. All rights reserved.


#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"

@interface PostDetailView: UIWebView <UIWebViewDelegate>{	//change it so our main view inherits from UIWebView
  NSString* urlString;
  NSMutableArray* reply_links;
  ASIHTTPRequest* http_request;
  ASIHTTPRequest* check_request;
  //标志requst是否结束，以此判断是否需要进行requst cancel
  BOOL isLoadingFinished;
  BOOL isCheckingFinished;
  //回复哪个post
  NSInteger post_index;
}

@property(nonatomic,retain)NSString *urlString;
@property(nonatomic,retain)NSMutableArray *reply_links;
@property(nonatomic,retain)ASIHTTPRequest* http_request;
@property(nonatomic,retain)ASIHTTPRequest* check_request;
@property BOOL isLoadingFinished;
@property BOOL isCheckingFinished;
@property NSInteger post_index;

-(void)checkLogin;
-(void)produceHTMLForPage:(NSArray*)result;	//method for generating the HTML for appropriate page
-(NSString*)produceImage:(NSString*)image;	//method for attaching image to the HTML
- (void)grabURLInBackground;

-(NSDictionary*)extractPostContent:(NSString*)content;

- (UINavigationController*)viewController;
@end
