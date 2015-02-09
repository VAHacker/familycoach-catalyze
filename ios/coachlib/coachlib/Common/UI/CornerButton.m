//
//  ThreeLabelTableViewCell.m
//  coachlib
//
//  Copyright (c) 2012 Department of Veteran's Affairs. All rights reserved.
//

#import "CornerButton.h"

@implementation CornerButton

-(id)init {
    self=[super init];
    self.backgroundColor = 0;
    self.opaque = FALSE;
    return self;
}

- (void) drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    float w = self.bounds.size.width;
    float h = self.bounds.size.height;
    
    CGContextMoveToPoint(context, w, h/2);
    CGContextAddLineToPoint(context, w, h);
    CGContextAddLineToPoint(context, w-h/2, h);
    CGContextSetLineWidth(context, 1);
    CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
    CGContextSetFillColorWithColor(context, [UIColor redColor].CGColor);
    CGContextDrawPath(context, kCGPathFillStroke);
}

@end
