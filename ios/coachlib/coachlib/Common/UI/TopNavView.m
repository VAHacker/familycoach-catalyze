//
//  TopNavView.m
//  coachlib
//
//  Copyright (c) 2012 Department of Veteran's Affairs. All rights reserved.
//

#import "iStressLessAppDelegate.h"
#import "TopNavView.h"

@implementation TopNavView

+ (int)navBarHeight {
    if ([iStressLessAppDelegate deviceMajorVersion] >= 7) return 64;
    return 44;
}
    
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)layoutSubviews {
    CGRect r = self.bounds;
    float barHeight = 0;
    if (self.navBar) {
        barHeight = [TopNavView navBarHeight];
        r.size.height = barHeight;
        self.navBar.frame = r;
    }

    r = self.bounds;
    r.origin.y += barHeight;
    r.size.height -= barHeight;
    self.clientView.frame = r;
}

@end
