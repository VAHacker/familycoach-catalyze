//
//  ThreeLabelTableViewCell.m
//  coachlib
//
//  Copyright (c) 2012 Department of Veteran's Affairs. All rights reserved.
//

#import "BackgroundView.h"

@implementation BackgroundView

- (void) drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSaveGState(context);
    CGContextAddRect(context, self.bounds);
    CGContextClip(context);
    
    CGSize size = self.image.size;
    CGRect r = self.bounds;
    r.size.height = (r.size.width/size.width) * size.height;
    [self.image drawInRect:r];

    CGPoint startPoint = CGPointMake(0, 0);
    CGPoint endPoint = CGPointMake(0, r.size.height+1);
    
    float red,green,blue,alpha;
    [self.color getRed:&red green:&green blue:&blue alpha:&alpha];
    CGFloat locations [] = { 0, 0.75, 1.0 };
    CGFloat colors [] = {
        red, green, blue, 0.5,
        red, green, blue, 1.0,
        red, green, blue, 1.0
    };
    CGColorSpaceRef baseSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColorComponents(baseSpace, colors, locations, 3);
    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
    CGContextRestoreGState(context);
    CGColorSpaceRelease(baseSpace);
    CGGradientRelease(gradient);
    
}

@end
