//
//  GTableView.m
//  iStressLess
//


//

#import "GTreeView.h"
#import <QuartzCore/QuartzCore.h>

@implementation GTreeView

-(id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style {
    self=[super initWithFrame:frame style:style];
    self.backgroundColor = 0;
    self.backgroundView = nil;
    return self;
}

-(void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    float w = self.bounds.size.width;
    float h = self.bounds.size.height;
    
    CGContextMoveToPoint(context, 0, 0);
    CGContextAddLineToPoint(context, w, h);
    CGContextSetLineWidth(context, 1);
    CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
    CGContextDrawPath(context, kCGPathStroke);
}

@end
