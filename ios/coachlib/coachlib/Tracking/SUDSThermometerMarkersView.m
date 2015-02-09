//
//  SUDSThermometerMarkersView.m
//  iStressLess
//


//

#import "SUDSThermometerMarkersView.h"


@implementation SUDSThermometerMarkersView

@synthesize topMarker, bottomMarker;

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
		marker = [UIImage imageNamed:@"therm_marker.png"];
    }
    return self;
}

-(id) initWithCoder:(NSCoder *)aDecoder {
	self=[super initWithCoder:(NSCoder *)aDecoder];
	marker = [UIImage imageWithCGImage:[[UIImage imageNamed:@"therm_marker.png"] CGImage] scale:1.6 orientation:UIImageOrientationUpMirrored];
	[marker retain];
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
	CGRect r;
	r.origin.x = 0;
	r.origin.y = 0;
	r.size = marker.size;
	for (int i=0;i<=10;i++) {
		float pos = bottomMarker - (((float)(bottomMarker-topMarker)) / 10.0) * i;
		r.origin.y = pos;
		[marker drawInRect:r];
	}
}

- (void)dealloc {
	[marker release];
	
    [super dealloc];
}


@end
