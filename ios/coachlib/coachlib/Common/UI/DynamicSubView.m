//
//  DynamicSubView.m
//  iStressLess
//


//

#import "DynamicSubView.h"
#import "StyledTextView.h"

@implementation DynamicSubView

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
		self.childMargin = 0;
        self.topMargin = 10;
        self.autoresizesSubviews = NO;
    }
    return self;
}

-(float) internalPaddingTop {
    return 0;
}

-(float) internalPaddingBottom {
    return 0;
}

-(void) layoutSubviews {
	CGRect myFrame = self.bounds;
//	r.origin.x += 10;
	float y = self.topMargin;
	NSArray *children = [self subviews];
	for (int i=0;i<children.count;i++) {
		UIView *child = [children objectAtIndex:i];
		CGRect r = child.frame;
        if ([child respondsToSelector:@selector(internalPaddingTop)]) {
            float paddingTop = [(DynamicSubView*)child internalPaddingTop];
            y -= paddingTop;
        }
		r.origin.y = y;
        if ([child respondsToSelector:@selector(contentHeight)]) {
            r.size.height = ceilf([(DynamicSubView*)child contentHeight]);
        }
        if (self.matchBounds && (i == children.count-1)) {
            r.size.height = ceilf(myFrame.size.height - y - self.childMargin);
        }
        r.size.width = myFrame.size.width;
//        NSLog(@"Child %d at %.0f,%.0f,%.0f,%.0f",i,r.origin.x,r.origin.y,r.size.width,r.size.height);
        child.frame = r;
        if ([child respondsToSelector:@selector(internalPaddingBottom)]) {
            float paddingBottom = [(DynamicSubView*)child internalPaddingBottom];
            y -= paddingBottom;
        }
		y += r.size.height + self.childMargin;
	}
}

-(void)addSubview:(UIView *)view {
    [super addSubview:view];
    [self setContentSizeChanged];
    [self setNeedsLayout];
}

-(void)setContentSizeChanged {
    [self setNeedsLayout];
    if ([self.superview respondsToSelector:@selector(setContentSizeChanged)]) {
        [((id<Layoutable>)self.superview) setContentSizeChanged];
    } else {
        [self.superview setNeedsLayout];
    }
}

-(float) contentWidth {
	CGRect r = self.bounds;
    return r.size.width;
}

-(float) contentHeightWithFrame:(CGRect)r {
    return [self contentHeight];
}

-(float) contentHeight {
	CGRect r = self.bounds;
    if (self.matchBounds) return r.size.height;
	float y = self.topMargin;
	NSArray *children = [self subviews];
	for (int i=0;i<children.count;i++) {
		UIView *child = [children objectAtIndex:i];
		CGRect r = child.frame;
        /*
        if ([child isKindOfClass:[StyledTextView class]]) {
            StyledTextView *tv = (StyledTextView*)child;
            CGSize size = [tv suggestedFrameSizeToFitEntireStringConstraintedToWidth:child.frame.size.width+20];
            NSLog(@"StyledTextView: %f,%f,%f %f,%f",child.frame.origin.y,child.frame.size.width,child.frame.size.height,size.width,size.height);
            NSLog(@"insets: %f,%f,%f,%f",tv.edgeInsets.left,tv.edgeInsets.top,tv.edgeInsets.right,tv.edgeInsets.bottom);
            NSLog(@"text: %@",[[tv attributedString] string]);
        }
        */
        if ([child respondsToSelector:@selector(internalPaddingTop)]) {
            float paddingTop = [(DynamicSubView*)child internalPaddingTop];
            y -= paddingTop;
        }
        if ([child respondsToSelector:@selector(contentHeight)]) {
            r.size.height = [(DynamicSubView*)child contentHeight];
        }
        if ([child respondsToSelector:@selector(internalPaddingBottom)]) {
            float paddingBottom = [(DynamicSubView*)child internalPaddingBottom];
            y -= paddingBottom;
        }
		y += r.size.height;
        if (i < children.count-1) y += self.childMargin;
	}
	
	return y;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGRect r = self.bounds;
    CGFloat color[4];
    color[0] = 1;
    color[1] = 0;
    color[2] = 0;
    color[3] = 1;
    CGContextSetStrokeColor(context, color);
    CGContextSetRGBFillColor(context, 1, 0, 0, 1);
    CGContextSetRGBStrokeColor(context, 0.0, 0.0, 0.0, 1.0);
    CGContextFillRect(context, r);
    [super drawRect:rect];

}
*/


- (void)dealloc {
    [super dealloc];
}


@end
