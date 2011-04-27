//
//  TopAllViewController.h
//  Lilybbs
//
//  Created by panda on 11-4-7.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
@class DisclosureDetailController;

@interface TopAllViewController : UITableViewController {
  NSArray *list;
}

@property (nonatomic, retain) NSArray *list;

@end
/*TODO: 目前这个类是作为功能的测试，等全站十大完成后，再完成全站热门的功能，和全站十大类似，除了解析帖子列表的过程不同*/