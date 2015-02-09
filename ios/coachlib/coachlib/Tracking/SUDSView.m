//
//  SUDSView.m
//  iStressLess
//


//

#import "SUDSView.h"


@implementation SUDSView

@synthesize numberLabel,therm,markersView;

#define THERM_HEIGHT 185.0

- (int)rating {
	return rating;
}

- (void )setRating:(int)_rating {
	if (rating == _rating) return;
	
	CGRect r;
	CGPoint pt;
	
	rating = _rating;

	int ratingToUse = rating;
	if (ratingToUse == -1) ratingToUse = 5;
	
	float quantizedDelta = (ratingToUse) * (THERM_HEIGHT / 10);

	[UIView beginAnimations:@"thermometer" context:nil];
	r = originalMercury;
	r.size.height += quantizedDelta;
	r.origin.y -= quantizedDelta;
	mercury.frame = r;
	
	pt = numberLabel.center;
	pt.y = r.origin.y+3.5;
	numberLabel.center = pt;
	if (rating == -1) {
		numberLabel.text = @"?";
	} else {
		numberLabel.text = [NSString stringWithFormat:@"%d", rating];
	}

	numberLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:26-(10-ratingToUse)];
	numberLabel.textColor = [UIColor colorWithRed:(ratingToUse/10.0) green:(10-ratingToUse)/15.0 blue:0 alpha:1];
	[UIView commitAnimations];
}

- (void) adjustToTouch:(UITouch*)touch {
	CGPoint pt = [touch locationInView:self];
	
	CGRect r = originalMercury;
	float delta = r.origin.y - pt.y;
	if (delta < 0) delta = 0;
	if (delta > THERM_HEIGHT) delta = THERM_HEIGHT;
	
	float _rating = ((delta / THERM_HEIGHT) * 10);
	int ratingInt = round(_rating);
	
	[self setRating:ratingInt];
}

- (UIImageView*)mercury {
	return mercury;
}

-(void) awakeFromNib {
	[self setRating:-1];
	markersView.bottomMarker = originalMercury.origin.y - markersView.frame.origin.y;
	markersView.topMarker = markersView.bottomMarker - THERM_HEIGHT;
    touchDown = FALSE;
}

-(void)accessibilityIncrement {
    int r = rating;
    if (r == -1) r = 5; 
    else if (r < 10) r++;
    if (r != rating) [self setRating:r];
}

-(void)accessibilityDecrement {
    int r = rating;
    if (r == -1) r = 5; 
    else if (r > 0) r--;
    if (r != rating) [self setRating:r];
}

-(NSString *)accessibilityLabel {
    return @"Distress Meter";
}

-(NSString *)accessibilityHint {
    return @"Set your distress level between 0 and 10";
}

-(NSString *)accessibilityValue {
    if (rating == -1) return @"unset";
    return [NSString stringWithFormat:@"%d of 10",rating];
}

-(UIAccessibilityTraits)accessibilityTraits {
    UIAccessibilityTraits traits = [super accessibilityTraits];
    traits |= UIAccessibilityTraitAdjustable;
    return traits;
}

- (void)setMercury:(UIImageView *)_mercury {
	[mercury release];
	mercury = _mercury;
	[mercury retain];
	mercury.image = [mercury.image stretchableImageWithLeftCapWidth:0 topCapHeight:10];
	originalMercury = mercury.frame;
}


- (BOOL)isAccessibilityElement {
    return YES;
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *t = [touches anyObject];
    if (CGRectContainsPoint(therm.bounds, [t locationInView:therm])) {
        touchDown = TRUE;
        [self adjustToTouch:t];
    }
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	if (touchDown) [self adjustToTouch:[touches anyObject]];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    touchDown = FALSE;
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    touchDown = FALSE;
}
    
- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
		[self setup];
    }
    return self;
}

-(id) initWithCoder:(NSCoder *)aDecoder {
	self=[super initWithCoder:(NSCoder *)aDecoder];
	[self setup];
	return self;
}

- (void)setup {
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)dealloc {
	[mercury release];
	
    [super dealloc];
}


@end
