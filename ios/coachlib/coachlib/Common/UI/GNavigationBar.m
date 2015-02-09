//
//  GNavigationBar.m
//  coachlib
//
//  Copyright (c) 2012 Department of Veteran's Affairs. All rights reserved.
//

#import "GNavigationBar.h"
#import "ThemeManager.h"

@implementation GNavigationBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
/*
        // Initialization code
        CGSize size = CGSizeMake(768, 50);
        CGRect r = CGRectMake(0, 0, 768, 50);
        UIGraphicsBeginImageContext(size);
        CGContextRef c = UIGraphicsGetCurrentContext();
        UIColor *uiColor = [[ThemeManager sharedManager] colorForName:@"navBarTintColor"];
        CGContextSetFillColorWithColor(c, [uiColor CGColor]);
        CGContextFillRect(c, r);
        UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [self setBackgroundImage:newImage forBarMetrics:UIBarMetricsDefault];
*/
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
/*
- (CGSize)sizeThatFits:(CGSize)size
{
    // This is how you set the custom size of your UINavigationBar
    CGRect frame = [UIScreen mainScreen].applicationFrame;
    CGSize newSize = CGSizeMake(frame.size.width , 30);
    return newSize;
}
*/
    
-(void)setFrame:(CGRect)frame {
    [super setFrame:frame];
}
    
@end
