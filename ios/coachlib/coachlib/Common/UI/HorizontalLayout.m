//
//  GridView.m
//  iStressLess
//


//

#import "HorizontalLayout.h"


@implementation HorizontalLayout

@synthesize cellMarginX, cellMarginY, outerMarginX, outerMarginY;

- (id)initWithViews:(int)count,... {
	va_list args;
    va_start(args, count);
	
    UIView *v;
	NSMutableArray *a = [NSMutableArray arrayWithCapacity:count];
    for( int i = 0; i < count; i++ ) {
        v = va_arg(args, UIView *);
		[a addObject:v];
    }
	
    va_end(args);
	return [self initWithViewArray:a];
}
	
- (id)initWithViewArray:(NSArray*)a {
	CGSize s;
	CGRect r,cr;
	outerMarginX = 0;
	outerMarginY = 0;
	cellMarginX = 10;
	cellMarginY = 10;
	s.width = outerMarginX;
    s.height = 0;
	for (int i=0;i<a.count;i++) {
		UIView *v = [a objectAtIndex:i];
		cr = v.frame;
		cr.origin.x = s.width;
		cr.origin.y = outerMarginY;
		v.frame = cr;
		s.width += cr.size.width;
		if (i < (a.count-1)) s.width += cellMarginX;
		if (cr.size.height > s.height) s.height = cr.size.height;
	}
	s.width += outerMarginX;
	s.height += outerMarginY*2;

	r.origin.x = 0;
	r.origin.y = 0;
	r.size = s;
	self = [super initWithFrame:r];
	
	for (int i=0;i<a.count;i++) {
		UIView *v = [a objectAtIndex:i];
		[self addSubview:v];
	}

    return self;
}

@end
