//
//  GLabel.m
//  iStressLess
//


//

#import "GLabel.h"


@implementation GLabel


- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
        self.drawWedge = TRUE;
        self.opaque = FALSE;
        self.backgroundColor = 0;
    }
    return self;
}

#define WEDGE_HEIGHT 3
#define WEDGE_WIDTH 3
#define ROUNDRECT_RADIUS 3

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
	CGRect r = self.bounds;
	r.origin.x += 3.5;
	r.origin.y += 3.5;
	r.size.width -= 7;
	r.size.height -= 7;
	
	CGMutablePathRef path = CGPathCreateMutable();
	
	CGPathMoveToPoint(path, NULL, r.origin.x+ROUNDRECT_RADIUS, r.origin.y);

	CGPathAddArcToPoint(path, NULL, r.origin.x+r.size.width, r.origin.y, r.origin.x+r.size.width, r.origin.y+r.size.height, ROUNDRECT_RADIUS);

    if (self.drawWedge) {
        float wedgePlacement = 0.5;
        
        CGPathAddLineToPoint(path, NULL, r.origin.x+r.size.width, (r.origin.y + r.size.height*wedgePlacement) - WEDGE_WIDTH);
        CGPathAddLineToPoint(path, NULL, r.origin.x+r.size.width + WEDGE_HEIGHT, (r.origin.y + r.size.height*wedgePlacement));
        CGPathAddLineToPoint(path, NULL, r.origin.x+r.size.width, (r.origin.y + r.size.height*wedgePlacement) + WEDGE_WIDTH);
    }
	
	CGPathAddArcToPoint(path, NULL, r.origin.x+r.size.width, r.origin.y+r.size.height, r.origin.x, r.origin.y+r.size.height, ROUNDRECT_RADIUS);
	CGPathAddArcToPoint(path, NULL, r.origin.x, r.origin.y+r.size.height, r.origin.x, r.origin.y, ROUNDRECT_RADIUS);
	CGPathAddArcToPoint(path, NULL, r.origin.x, r.origin.y, r.origin.x+r.size.width, r.origin.y, ROUNDRECT_RADIUS);

	CGPathCloseSubpath(path);
	
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	CGContextAddPath(ctx, path);
	
	CGContextSetFillColorWithColor(ctx, [UIColor whiteColor].CGColor);
	CGContextFillPath(ctx);
	
	CGContextAddPath(ctx, path);
	CGContextSetLineWidth(ctx, 1);
	CGContextSetStrokeColorWithColor(ctx, [UIColor blackColor].CGColor);
	CGContextStrokePath(ctx);
	CGPathRelease(path);
	
	[super drawRect:rect];
}

- (void)dealloc {
    [super dealloc];
}


@end
