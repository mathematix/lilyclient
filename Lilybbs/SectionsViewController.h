//
//  SectionsViewController.h
//  Lilybbs
//
//  Created by panda on 11-4-29.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseTableViewController.h"

@interface SectionsViewController : BaseTableViewController {
  NSArray* sectionNames;
}

@property (nonatomic, retain) NSArray* sectionNames;

@end
