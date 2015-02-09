//
//  ConstructedView.m
//  iStressLess
//


//

#import "ButtonBarView.h"
#import "ConstructedView.h"


@implementation ButtonBarView

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
		buttons = nil;
    }
    return self;
}

-(void) addButton:(UIView*)button {
	if (!buttons) buttons = [[NSMutableArray alloc] init];
	[buttons addObject:button];
	if (button.tag != BUTTON_LEFT_RIGHT_MARKER) [self addSubview:button];
}

- (void) layoutSubviews {
	CGRect r = self.bounds;

	int i;
	int rightMost=r.size.width;
	//int topMost = 0;
	for (i=[buttons count];i--;) {
		UIButton *v = [buttons objectAtIndex:i];
		if (v.tag == BUTTON_LEFT_RIGHT_MARKER) break;
		CGRect vr = v.frame;
		vr.origin.y = r.size.height - vr.size.height;
		vr.origin.x = rightMost - vr.size.width - 6;
		//topMost = vr.origin.y;
		rightMost = rightMost - vr.size.width - 6;
		v.frame = vr;
	}

	rightMost = 10;
	
	int j = i;
	for (i=0;i<j;i++) {
		UIView *v = [buttons objectAtIndex:i];
		if (v.tag == BUTTON_LEFT_RIGHT_MARKER) break;
		CGRect vr = v.frame;
		vr.origin.y = r.size.height - vr.size.height;
		vr.origin.x = rightMost;
		//topMost = vr.origin.y;
		rightMost = rightMost + vr.size.width + 6;
		v.frame = vr;
	}
	
}

-(float) contentHeight {
	float height = 0;
	
	if (buttons.count > 0) {
		height += [[buttons objectAtIndex:0] frame].size.height;
	}
	
	return height;
}

- (void)dealloc {
	[buttons release];
    [super dealloc];
}


@end
