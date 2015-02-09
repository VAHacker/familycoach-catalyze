//
//  ConstructedView.m
//  iStressLess
//


//

#import "ConstructedView.h"
#import "GButton.h"
#import "ContentViewController.h"

@implementation ConstructedView

@synthesize rightSideView;
@synthesize clipDynamicView;

static int touchHappening = 0;

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
		clipDynamicView = FALSE;
        self.onTop = TRUE;
        _rightButtons = _leftButtons = nil;
        self.clipsToBounds = YES;
    }
    return self;
}

-(float) internalPaddingTop {
    return 0;
}

-(float) internalPaddingBottom {
    return 0;
}

-(void)debugOutput:(UIView *)v withOrigin:(CGPoint)origin andIndent:(int)indent {
    int count = v.subviews.count;
    NSMutableString *indentStr = [NSMutableString string];
    int i=indent;
    while (i>0) {
        [indentStr appendString:@" "];
        i--;
    }
    CGRect r = v.frame;
    NSLog(@"%@[%@ (%f,%f,%f,%f)]",
          indentStr,
          NSStringFromClass([v class]),
          origin.x+r.origin.x, origin.y+r.origin.y,
          origin.x+r.origin.x+r.size.width, origin.y+r.origin.y+r.size.height);
    for (i=0;i<count;i++) {
        UIView *subview = [v.subviews objectAtIndex:i];
        [self debugOutput:subview withOrigin:r.origin andIndent:indent+2];
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (!touchHappening) {
        touchHappening = 1;
/*
        UITouch *touch = [touches anyObject];
        CGRect r = self.frame;
        NSLog(@"touch (%f,%f) on [%@ (%f,%f,%f,%f)]",
              [touch locationInView:self].x, [touch locationInView:self].y,
              NSStringFromClass([self class]),
              r.origin.x, r.origin.y,
              r.origin.x+r.size.width, r.origin.y+r.size.height);

        UIView *v = self;
        while (v.superview) {
            v = v.superview;
        }
        [self debugOutput:v withOrigin:CGPointMake(0,0) andIndent:0];
*/
        touchHappening = 0;
    }
    [super touchesBegan:touches withEvent:event];
}

-(void)setLeftButtons:(NSArray *)buttons {
    for (UIView *button in _leftButtons) {
        [button removeFromSuperview];
    }
    _leftButtons = [buttons retain];
    for (UIView *button in _leftButtons) {
        [self addSubview:button];
    }
    [self layoutSubviews];
}

-(NSArray *)leftButtons {
    return _leftButtons;
}

-(void)setRightButtons:(NSArray *)buttons {
    for (UIView *button in _rightButtons) {
        [button removeFromSuperview];
    }
    _rightButtons = [buttons retain];
    for (UIView *button in _rightButtons) {
        [button removeFromSuperview];
        [self addSubview:button];
    }
    [self layoutSubviews];
}

-(NSArray *)rightButtons {
    return _rightButtons;
}

- (void) layoutSubviews {
	CGRect r = self.bounds;

	float height = 0;
	if (self.clientView && !clipDynamicView) {
        if ([self.clientView respondsToSelector:@selector(contentHeight)]) {
            height = [(id<Layoutable>)self.clientView contentHeight];
            CGRect subr = self.clientView.frame;
            subr.origin.x = 0;
            subr.origin.y = 0;
            subr.size.width = r.size.width;
            if (self.rightSideView) subr.size.width -= self.rightSideView.frame.size.width;
            subr.size.height = height;
            self.clientView.frame = subr;
		}
	}

	int i;
	int topMost,rightMost = 10;
//    topMost = r.size.height;
    
	for (i=0;i<self.leftButtons.count;i++) {
		GButton *v = [self.leftButtons objectAtIndex:i];
        if (v.dynamicPredicate && ![v.controller evalJSPredicate:v.dynamicPredicate]) {
            v.hidden = TRUE;
        } else {
            CGRect vr = v.frame;
            vr.size.width = [v contentWidth];
            vr.origin.y = r.size.height - vr.size.height - 15;
            vr.origin.x = rightMost;
//            topMost = vr.origin.y;
            rightMost = rightMost + vr.size.width + 10;
            v.frame = vr;
        }
	}
	
    int leftMargin = rightMost;
	int leftMost=r.size.width;
    int currentBottom = r.size.height;
	topMost = r.size.height;
	for (i=[self.rightButtons count];i--;) {
		GButton *v = [self.rightButtons objectAtIndex:i];
        if (v.dynamicPredicate && ![v.controller evalJSPredicate:v.dynamicPredicate]) {
            v.hidden = TRUE;
        } else {
            CGRect vr = v.frame;
            vr.size.width = [v contentWidth];
            vr.origin.y = currentBottom - vr.size.height - 15;
            vr.origin.x = leftMost - vr.size.width - 10;
            if (vr.origin.x < leftMargin) {
                currentBottom = topMost;
                leftMost = r.size.width;
                vr.origin.y = currentBottom - vr.size.height - 15;
                vr.origin.x = leftMost - vr.size.width - 10;
            }
            topMost = vr.origin.y;
            leftMost = leftMost - vr.size.width - 10;
            v.frame = vr;
        }
	}
	
	if (self.clientView && clipDynamicView) {
		CGRect subr = self.clientView.frame;
        subr.origin.x = 0;
        subr.origin.y = 0;
		subr.size.height = topMost-15-subr.origin.y;
        subr.size.width = r.size.width;
        if (self.rightSideView) subr.size.width -= self.rightSideView.frame.size.width;
		self.clientView.frame = subr;
	}
    
    CGRect subr = self.rightSideView.frame;
    subr.size.height = self.clientView.frame.size.height;
    self.rightSideView.frame = subr;

/*	
	r = aboveButtonsView.frame;
	r.origin.y = topMost - r.size.height - 80;
	aboveButtonsView.frame = r;
*/
}

-(void)setContentSizeChanged {
    if ([self.superview respondsToSelector:@selector(setContentSizeChanged)]) {
        [((id<Layoutable>)self.superview) setContentSizeChanged];
    } else {
        CGRect r = self.superview.frame;
        r.size.height = [self contentHeightWithFrame:r];
        self.frame = r;
        [self.superview setNeedsLayout];
    }
    [self setNeedsLayout];
}

-(float) contentWidth {
	CGRect r = self.bounds;
    return r.size.width;
}

-(float) contentHeight {
    if (self.dynamicPredicate && self.controller) {
        BOOL shouldShow = [self.controller evalJSPredicate:self.dynamicPredicate];
        if (!shouldShow) return 0;
    }
    
    if ([self.clientView respondsToSelector:@selector(contentHeight)]) {
        return [(id<Layoutable>)self.clientView contentHeight];
    }
    
    if (self.clientView) {
        return self.clientView.frame.size.height;
    }
    
    return 0;
}

-(float) contentHeightWithFrame:(CGRect)r {
	if (!self.clientView || clipDynamicView || ![self.clientView respondsToSelector:@selector(contentHeight)]) return r.size.height;

    if (self.dynamicPredicate && self.controller) {
        BOOL shouldShow = [self.controller evalJSPredicate:self.dynamicPredicate];
        if (!shouldShow) return 0;
    }
    
	float height = [(id<Layoutable>)self.clientView contentHeight];
	
	CGRect rightSideRect = rightSideView.frame;
	float rightSideHeight = rightSideRect.origin.y + rightSideRect.size.height;
	if (rightSideHeight > height) height = rightSideHeight;
	
    float max = 0;
    for (GButton *v in self.leftButtons) {
        if (v.dynamicPredicate && ![v.controller evalJSPredicate:v.dynamicPredicate]) continue;
        if (v.frame.size.height > max) max = v.frame.size.height;
    }
    for (GButton *v in self.rightButtons) {
        if (v.dynamicPredicate && ![v.controller evalJSPredicate:v.dynamicPredicate]) continue;
        if (v.frame.size.height > max) max = v.frame.size.height;
    }

	if (max > 0) {
		height += max+20;
	}
	
	if (r.size.height > height) height = r.size.height;
	
	return height;
}

- (void)dealloc {
	[rightSideView release];
	[_rightButtons release];
	[_leftButtons release];
	
    [super dealloc];
}


@end
