//
//  GradientScrollContainer.m
//  coachlib
//
//  Copyright (c) 2012 Department of Veteran's Affairs. All rights reserved.
//

#import "GradientScrollContainer.h"

@implementation GradientScrollContainer

#define GRADIENT_SIZE 5

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.maskLayer = [CAGradientLayer layer];
        
        CGColorRef outerColor = [UIColor colorWithWhite:1.0 alpha:0.0].CGColor;
        CGColorRef innerColor = [UIColor colorWithWhite:1.0 alpha:1.0].CGColor;
        
        float gradientStart = (self.frame.size.height - GRADIENT_SIZE) / (self.frame.size.height + GRADIENT_SIZE);
        self.maskLayer.colors = [NSArray arrayWithObjects:(id)innerColor,(id)innerColor,(id)outerColor, nil];
        self.maskLayer.locations = [NSArray arrayWithObjects:
                               [NSNumber numberWithFloat:0.0],
                               [NSNumber numberWithFloat:gradientStart],
                               [NSNumber numberWithFloat:1.0], nil];
        
        self.maskLayer.bounds = CGRectMake(0, 0,
                                      self.frame.size.width,
                                      self.frame.size.height+GRADIENT_SIZE);
        self.maskLayer.anchorPoint = CGPointZero;
        
        self.layer.mask = self.maskLayer;
    }
    return self;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    float gradientStart = (self.frame.size.height - GRADIENT_SIZE) / (self.frame.size.height + GRADIENT_SIZE);
    self.maskLayer.locations = [NSArray arrayWithObjects:
                                [NSNumber numberWithFloat:0.0],
                                [NSNumber numberWithFloat:gradientStart],
                                [NSNumber numberWithFloat:1.0], nil];
    self.maskLayer.bounds = CGRectMake(0, 0,
                                  self.frame.size.width,
                                  self.frame.size.height+GRADIENT_SIZE);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
