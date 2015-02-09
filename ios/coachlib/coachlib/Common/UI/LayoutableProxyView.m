//
//  DynamicSubView.m
//  iStressLess
//


//

#import "LayoutableProxyView.h"


@implementation LayoutableProxyView

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
    }
    return self;
}

-(void)didMoveToSuperview {
    [super didMoveToSuperview];
//    CGRect r = self.superview.frame;
//    self.frame = r;
    self.superview.autoresizesSubviews = TRUE;
    self.autoresizingMask = UIViewAutoresizingFlexibleHeight/* | UIViewAutoresizingFlexibleWidth*/;
//    [self setNeedsLayout];
}

-(void)setToPreferredHeight {
    float h = [self contentHeight];
    CGRect r = self.frame;
    r.size.height = h;
    self.frame = r;
    [self setNeedsLayout];
}

-(UIView<Layoutable>*)child {
    return (UIView<Layoutable>*)[self.subviews objectAtIndex:0];
}

-(float) internalPaddingTop {
    return [[self child] internalPaddingTop];
}

-(float) internalPaddingBottom {
    return [[self child] internalPaddingBottom];
}

-(void) layoutSubviews {
    [self child].frame = self.bounds;
}

-(void)setContentSizeChanged {
    [self setNeedsLayout];
    if ([self.superview respondsToSelector:@selector(setContentSizeChanged)]) {
        [((id<Layoutable>)self.superview) setContentSizeChanged];
    } else {
        [self.superview setNeedsLayout];
    }
    if (self.proxyUp) {
        if ([self.proxyUp respondsToSelector:@selector(setContentSizeChanged)]) {
            [((id<Layoutable>)self.proxyUp) setContentSizeChanged];
        } else {
            [self.proxyUp setNeedsLayout];
        }
    }
}

-(float) contentWidth {
    return [[self child] contentWidth];
}

-(float) contentHeightWithFrame:(CGRect)r {
    float height = [[self child] contentHeightWithFrame:r];
    return height;
}

-(float) contentHeight {
    float height = [[self child] contentHeight];
    return height;
}

@end
