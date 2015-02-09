//
//  CenteringView.m
//  iStressLess
//


//

#import "CenteringView.h"


@implementation CenteringView

+(CenteringView*) centeredView:(UIView *)v {
	return [[[CenteringView alloc] initWithView:v] autorelease];
}

+(CenteringView*) gravityView:(UIView *)v withGravity:(int)gravity {
	return [[[CenteringView alloc] initWithView:v usingGravity:gravity] autorelease];
}

- (id)initWithView:(UIView*)v {
    if ((self = [super initWithFrame:v.frame])) {
		[self addSubview:v];
        self.userInteractionEnabled = TRUE;
        self.gravity = GRAVITY_CENTER_HORIZONTAL | GRAVITY_CENTER_VERTICAL;
    }
    return self;
}

-(id) initWithView:(UIView *)v usingGravity:(int)gravity {
    CenteringView *cv = [self initWithView:v];
    if (cv) cv.gravity = gravity;
    return cv;
}

-(void) layoutSubviews {
	CGRect r = self.frame;
	NSArray *children = [self subviews];
	if (children.count == 0) return;
	UIView *v = [children objectAtIndex:0];
	if (v) {
        CGRect subr = v.frame;

        if (self.gravity & GRAVITY_CENTER_HORIZONTAL) {
            subr.origin.x = (r.size.width - subr.size.width)/2;
        } else if ((self.gravity & (GRAVITY_LEFT|GRAVITY_RIGHT)) == GRAVITY_LEFT) {
            subr.origin.x = 0;
        } else if ((self.gravity & (GRAVITY_LEFT|GRAVITY_RIGHT)) == GRAVITY_RIGHT) {
            subr.origin.x = r.size.width - subr.size.width;
        } else if ((self.gravity & (GRAVITY_LEFT|GRAVITY_RIGHT)) == (GRAVITY_LEFT|GRAVITY_RIGHT)) {
            subr.origin.x = 0;
            subr.size.width = r.size.width;
        }

        if (self.gravity & GRAVITY_CENTER_VERTICAL) {
            subr.origin.y = (r.size.height - subr.size.height)/2;
        } else if ((self.gravity & (GRAVITY_TOP|GRAVITY_BOTTOM)) == GRAVITY_TOP) {
            subr.origin.y = 0;
        } else if ((self.gravity & (GRAVITY_TOP|GRAVITY_BOTTOM)) == GRAVITY_BOTTOM) {
            subr.origin.y = r.size.height - subr.size.height;
        } else if ((self.gravity & (GRAVITY_TOP|GRAVITY_BOTTOM)) == (GRAVITY_TOP|GRAVITY_BOTTOM)) {
            subr.origin.y = 0;
            subr.size.height = r.size.height;
        }
        
        v.frame = subr;
	}
}

@end
