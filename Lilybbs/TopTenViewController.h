//
//  TopTenViewController.h
//  Lilybbs
//
//  Created by panda on 11-4-1.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TopTenViewController : UITableViewController {
  NSArray *list;
}

@property (nonatomic, retain) NSArray* list;

-(NSArray*)postdata;

@end
