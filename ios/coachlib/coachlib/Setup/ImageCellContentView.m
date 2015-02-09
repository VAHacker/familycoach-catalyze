//
//  ImageCellContentView.m
//  iStressLess
//


//

#import "ImageCellContentView.h"


@implementation ImageCellContentView

@synthesize imageView;

-(id) initWithFrame:(CGRect)frame {
	self=[super initWithFrame:(CGRect)frame];
	return self;
}

-(void) drawRect:(CGRect)rect {
	if (imageView) {
		CGRect r = imageView.frame;
		r = CGRectInset(r, -0.5, -0.5);
		
		CGContextRef cg = UIGraphicsGetCurrentContext();
		CGContextSetStrokeColorWithColor(cg, [[UIColor blackColor] CGColor]);
		CGContextStrokeRectWithWidth(cg, r, 1);
	}
}

@end
