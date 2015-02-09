//
//  ConstructiveScrollView.m
//  iStressLess
//


//

#import "ConstructiveScrollView.h"
#import "ConstructedView.h"

@implementation ConstructiveScrollView


- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
		self.showsVerticalScrollIndicator = YES;
    }
    return self;
}
 
- (BOOL)accessibilityScroll:(UIAccessibilityScrollDirection)direction {
    CGPoint offset = [self contentOffset];
    CGSize size = [self contentSize];
    CGRect bounds = [self bounds];
    int height = bounds.size.height;
    int vertSize = size.height;
    int vertOffset = offset.y;
    int page = (vertOffset / height) + 1;
    int numPages = (vertSize+height-1)/height;
    if (direction == UIAccessibilityScrollDirectionLeft) return FALSE;
    if (direction == UIAccessibilityScrollDirectionRight) return FALSE;
    if (direction == UIAccessibilityScrollDirectionUp) {
        if (page == 1) return FALSE;
        offset.y -= bounds.size.height;
        page--;
    } else if (direction == UIAccessibilityScrollDirectionDown) {
        if (page == numPages) return FALSE;
        offset.y += bounds.size.height;
        page++;
    }
    
    [UIView beginAnimations:@"scrolling" context:nil];
    self.contentOffset = offset;
    [UIView commitAnimations];
    
    UIAccessibilityPostNotification(UIAccessibilityPageScrolledNotification, [NSString stringWithFormat:@"Page %d of %d",page,numPages]);
    return TRUE;
}

-(void) layoutSubviews {
	CGRect r = self.frame;
	NSArray *children = [self subviews];
	if (children.count > 0) {
		UIView *child = [children objectAtIndex:0];
		if ([child respondsToSelector:@selector(contentHeightWithFrame:)]) {
			float height = [(id<Layoutable>)child contentHeightWithFrame:r];
			r.size.height = height;
		}
        if (!CGRectEqualToRect(child.frame,r)) {
            child.frame = r;
            [child setNeedsLayout];
        }
	}
	self.contentSize = r.size;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)dealloc {
    [super dealloc];
}


@end
