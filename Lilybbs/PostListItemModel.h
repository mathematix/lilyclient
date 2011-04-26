//
//  page.h
//  Reader
//
//  Created by David Samuel on 6/6/10.
//  Copyright 2010 Institut Teknologi Bandung. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PostListItemModel: NSObject {
	NSString *title;		
	NSString* author;	
  NSString* board;
	NSString *url;
}

@property(nonatomic,retain) NSString *title;
@property(nonatomic,retain) NSString *author;
@property(nonatomic,retain) NSString *board;
@property(nonatomic,retain) NSString *url;

@end
