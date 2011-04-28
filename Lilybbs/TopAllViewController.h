//
//  TopAllViewController.h
//  Lilybbs
//
//  Created by panda on 11-4-7.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseTableViewController.h"
#import "LoadingView.h"

@interface TopAllViewController : BaseTableViewController {
  NSArray* sectionNames;

}

@property (nonatomic, retain) NSArray* sectionNames;

@end
