//
//  TopNavView.h
//  coachlib
//
//  Copyright (c) 2012 Department of Veteran's Affairs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TopNavView : UIView

@property (nonatomic,retain) UINavigationBar *navBar;
@property (nonatomic,retain) UIView *clientView;

+ (int)navBarHeight;

@end
