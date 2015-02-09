//
//  SegmentedToggleController.h
//  coachlib
//
//  Copyright (c) 2012 Department of Veteran's Affairs. All rights reserved.
//

#import "ContentViewController.h"

@interface SegmentedToggleController : ContentViewController <UIPageViewControllerDataSource,UIPageViewControllerDelegate> {
    UISegmentedControl *segmentedControl;
    NSMutableArray *controllers;
    int selectedController;
}

@property (nonatomic,retain) UIPageViewController *pageViewController;

@end
