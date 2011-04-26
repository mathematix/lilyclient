//
//  PostDetail.h
//  Lilybbs
//
//  Created by panda on 11-4-26.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol PostDetailDelegate <NSObject>

- (void)openPostView:(NSString *)urlString;

@end
