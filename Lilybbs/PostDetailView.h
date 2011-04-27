//
//  mainView.h
//  Reader
//
//  Created by David Samuel on 6/4/10.
//  Copyright 2010 Institut Teknologi Bandung. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "ASIHTTPRequest.h"

@interface PostDetailView: UIWebView <UIWebViewDelegate>{	//change it so our main view inherits from UIWebView
  NSString* urlString;
  NSMutableArray* reply_links;
  ASIHTTPRequest* http_request;
}

@property(nonatomic,retain)NSString *urlString;
@property(nonatomic,retain)NSMutableArray *reply_links;
@property(nonatomic,retain)ASIHTTPRequest* http_request;

-(void)produceHTMLForPage:(NSArray*)result;								//method for generating the HTML for appropriate page
-(NSString*)produceImage:(NSString*)image;	//method for attaching image to the HTML
- (void)grabURLInBackground;

-(NSDictionary*)extractPostContent:(NSString*)content;

- (UINavigationController*)viewController;
@end
