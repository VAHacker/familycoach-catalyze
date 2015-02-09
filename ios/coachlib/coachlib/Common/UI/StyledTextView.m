//
//  StyledTextView.m
//  coachlib
//
//  Copyright (c) 2012 Department of Veteran's Affairs. All rights reserved.
//

#import "StyledTextView.h"

@implementation StyledTextView 

-(void) setContentSizeChanged {
}

-(float) internalPaddingTop {
    return 0;
}

-(float) internalPaddingBottom {
    return 0;
}

-(float) contentWidth {
    return self.bounds.size.width;
}

-(float) contentHeight {
	CGRect r = self.bounds;
    return [self suggestedFrameSizeToFitEntireStringConstraintedToWidth:r.size.width].height;
}

-(float) contentHeightWithFrame:(CGRect)r {
    return [self suggestedFrameSizeToFitEntireStringConstraintedToWidth:r.size.width].height;
}

@end
