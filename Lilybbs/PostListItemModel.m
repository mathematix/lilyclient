//
//  page.m
//  Reader
//
//  Created by David Samuel on 6/6/10.
//  Copyright 2010 Institut Teknologi Bandung. All rights reserved.
//

#import "PostListItemModel.h"


@implementation PostListItemModel
@synthesize title,author,board,url;

-(id)init{						//method called for the initialization of this object
	if(self=[super init]){}
	return self;
}

-(void)dealloc{					//method called when object is released
	[title release];			//release each member of this object
	[author release];
  [board release];
	[url release];
	[super dealloc];
}

@end
