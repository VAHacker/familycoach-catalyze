//
//  SegmentedToggleController.h
//  coachlib
//
//  Copyright (c) 2012 Department of Veteran's Affairs. All rights reserved.
//

#import "ContentViewController.h"

@interface TabController : ContentViewController <UITabBarControllerDelegate> {
    UITabBarController *tabBarController;
    NSMutableArray *tabList;
    NSMutableArray *rootList;
}

@end
