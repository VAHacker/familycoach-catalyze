//
//  SegmentedToggleController.h
//  coachlib
//
//  Copyright (c) 2012 Department of Veteran's Affairs. All rights reserved.
//

#import "ContentViewController.h"

@interface PaneledController : ContentViewController {
    ContentViewController *topController;
    ContentViewController *bottomController;
}

@end
