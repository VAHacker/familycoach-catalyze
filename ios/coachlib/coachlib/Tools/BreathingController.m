//
//  RelaxationIntroController.m
//  iStressLess
//


//

#import "BreathingController.h"
#import "ManageSymptomsNavController.h"
#import "GFunctor.h"

#define BREATH_TIME 5.0
#define HOLD_TIME 2.0
#define PAUSE_TIME 2.0
#define INITIAL_FADE_IN_TIME 38.0
#define INITIAL_BREATH_TIME 43.0
#define SECOND_BREATH_TIME 58.0
#define INITIAL_COUNTING_BREATH_TIME 71.0

@implementation BreathingController

-(void) setKeyframeAt:(NSTimeInterval)time with:(void(^)())block {
	NSDate *date = [NSDate dateWithTimeInterval:time sinceDate:startTime];

	GFunctor *f = [[GFunctor alloc] initWithBlock:block];
	NSTimer *timer = [[NSTimer alloc] initWithFireDate:(NSDate *)date interval:0 target:f selector:@selector(invoke) userInfo:nil repeats:NO];	
	f.toInvalidate = timer;
	[f release];

	[timers addObject:timer];
	[[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
	lastInterval = time;
}

-(void) setKeyframeAtDelta:(NSTimeInterval)time with:(void(^)())block {
	[self setKeyframeAt:time+lastInterval with:block];
}

-(void) configureContentView {
	UIView *cv = self.contentView;
	CGRect r;
	r.origin.x = r.origin.y = 0;
	r.size.width = 256;
	r.size.height = 256;
	
    breathDuration = [self.content getExtraFloat:@"breathDuration" withDefault:BREATH_TIME];
    holdDuration = [self.content getExtraFloat:@"holdDuration" withDefault:HOLD_TIME];
    pauseDuration = [self.content getExtraFloat:@"pauseDuration" withDefault:PAUSE_TIME];
    initialFadeInTime = [self.content getExtraFloat:@"initialFadeInTime" withDefault:INITIAL_FADE_IN_TIME];
    initialBreathTime = [self.content getExtraFloat:@"initialBreathTime" withDefault:INITIAL_BREATH_TIME];
    secondBreathTime = [self.content getExtraFloat:@"secondBreathTime" withDefault:SECOND_BREATH_TIME];
    firstCountingBreathTime = [self.content getExtraFloat:@"firstCountingBreathTime" withDefault:INITIAL_COUNTING_BREATH_TIME];

	balloonOutline = [[UIImageView alloc] initWithFrame:r];
	balloonOutline.image = [self.content getChildByName:@"breathe_background"].uiImage; //[UIImage imageNamed:@"Content/glass_outline.png"];
//	balloonOutline.image = [UIImage imageNamed:@"Content/glass_outline.png"];
	balloonOutline.contentMode = UIViewContentModeScaleAspectFit;
	[cv addSubview:balloonOutline];
	balloonOutline.center = CGPointMake(160, 180);
    balloonOutline.isAccessibilityElement = TRUE;
    balloonOutline.accessibilityLabel = @"ball, expanding and contracting with your breath";

	balloonContainerView = [[UIView alloc] initWithFrame:r];
	balloonContainerView.autoresizesSubviews = TRUE;
//	balloonContainerView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
	[cv addSubview:balloonContainerView];
	balloonContainerView.center = CGPointMake(160, 180);

	labelView = [[UILabel alloc] initWithFrame:r];
	labelView.opaque = FALSE;
	labelView.backgroundColor = [UIColor clearColor];
	labelView.textColor = [UIColor whiteColor];
	labelView.textAlignment = UITextAlignmentCenter;
	labelView.font = [UIFont fontWithName:@"Helvetica-Bold" size:56.0];
	labelView.shadowColor = [UIColor darkGrayColor];
	labelView.shadowOffset = CGSizeMake(2, 2);
	[cv addSubview:labelView];
	labelView.center = CGPointMake(160, 180);
	
	r = balloonContainerView.bounds;
	
	balloonGreen = [[UIImageView alloc] initWithFrame:r];
	balloonGreen.image = [self.content getChildByName:@"breathe_in"].uiImage; //[UIImage imageNamed:@"Content/glass_green.png"];
	balloonGreen.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	balloonGreen.contentMode = UIViewContentModeScaleAspectFit;
	[balloonContainerView addSubview:balloonGreen];

	balloonYellow = [[UIImageView alloc] initWithFrame:r];
	balloonYellow.image = [self.content getChildByName:@"breathe_hold"].uiImage; //[UIImage imageNamed:@"Content/glass_yellow.png"];
	balloonYellow.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	balloonYellow.contentMode = UIViewContentModeScaleAspectFit;
	[balloonContainerView addSubview:balloonYellow];

	balloonRed = [[UIImageView alloc] initWithFrame:r];
	balloonRed.image = [self.content getChildByName:@"breathe_out"].uiImage; //[UIImage imageNamed:@"Content/glass_red.png"];
//	balloonRed.image = [UIImage imageNamed:@"Content/glass_red.png"];
	balloonRed.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	balloonRed.contentMode = UIViewContentModeScaleAspectFit;
	[balloonContainerView addSubview:balloonRed];

	labelView.alpha = 0;
	balloonOutline.alpha = 0;
	balloonContainerView.alpha = 0;
	balloonGreen.alpha = 1;
	balloonYellow.alpha = 0;
	balloonRed.alpha = 0;
	balloonContainerView.transform = CGAffineTransformMakeScale(0.2, 0.2);
	currentVisible = balloonGreen;
}

-(void) inflateAt:(NSTimeInterval)interval withDuration:(NSTimeInterval)duration {
	[self setKeyframeAt:interval with:^{
        [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
        [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
		[UIView beginAnimations:@"inflate" context:nil];
		[UIView setAnimationDuration:duration];
		balloonContainerView.transform = CGAffineTransformMakeScale(1, 1);
		[UIView commitAnimations];
	}];
}

-(void) deflateAt:(NSTimeInterval)interval withDuration:(NSTimeInterval)duration {
	[self setKeyframeAt:interval with:^{
        [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
        [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
		[UIView beginAnimations:@"deflate" context:nil];
		[UIView setAnimationDuration:duration];
		balloonContainerView.transform = CGAffineTransformMakeScale(0.2, 0.2);
		[UIView commitAnimations];
	}];
}

-(void) fadeTo:(UIView*)fadingIn at:(NSTimeInterval)interval withDuration:(NSTimeInterval)duration {
	[self setKeyframeAt:interval with:^{
        [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
        [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
		if (currentVisible != fadingIn) {
			fadingIn.alpha = 0;
			[UIView beginAnimations:@"fade" context:nil];
			[UIView setAnimationDuration:duration];
			[balloonContainerView bringSubviewToFront:fadingIn];
			currentVisible = fadingIn;
			fadingIn.alpha = 1;
			[UIView commitAnimations];
		}
	}];
}

#define PULSE_DURATION 4.0
#define PULSE_FADE_DURATION 1.0

-(void) pulseMessage:(NSString*)text at:(NSTimeInterval)interval withDuration:(NSTimeInterval)duration {
	float fadeDuration = duration / 4;
	[self setKeyframeAt:interval with:^{
        [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
        [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
		labelView.alpha = 0;
		labelView.transform = CGAffineTransformMakeScale(0.5, 0.5);
		labelView.text = text;

		[UIView beginAnimations:@"labelFadeIn" context:nil];
		[UIView setAnimationDuration:fadeDuration];
		labelView.alpha = 1;
		[UIView commitAnimations];

		[UIView beginAnimations:@"labelPulse" context:nil];
		[UIView setAnimationDuration:duration];
		labelView.transform = CGAffineTransformMakeScale(1, 1);
		[UIView commitAnimations];
	}];

	[self setKeyframeAt:interval+duration-fadeDuration with:^{
        [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
        [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
		[UIView beginAnimations:@"labelFadeOut" context:nil];
		[UIView setAnimationDuration:fadeDuration];
		labelView.alpha = 0;
		[UIView commitAnimations];
	}];
}

-(BOOL)shouldAddListenButton {
    return FALSE;
}

-(void) scheduleBreathAt:(NSTimeInterval)t withFullText:(NSString*)fullText andEmptyText:(NSString*)emptyText {
	[self inflateAt:t withDuration:breathDuration];
	[self fadeTo:balloonYellow at:t+breathDuration-1 withDuration:2];
	if (fullText) [self pulseMessage:fullText at:t+breathDuration withDuration:holdDuration];
	[self fadeTo:balloonRed at:t+breathDuration+holdDuration-1 withDuration:2];
	[self deflateAt:t+breathDuration+holdDuration withDuration:breathDuration];
	if (emptyText) [self pulseMessage:emptyText at:t+breathDuration+holdDuration+breathDuration-1 withDuration:pauseDuration];
	[self fadeTo:balloonGreen at:t+breathDuration+holdDuration+breathDuration+pauseDuration-1 withDuration:1];
}

-(void) viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[[UIApplication sharedApplication] setIdleTimerDisabled:NO];
	[[UIApplication sharedApplication] setIdleTimerDisabled:YES];
	[self playAudio];
	
	startTime = [NSDate date];
	[startTime retain];
	lastInterval = 0;

	[self setKeyframeAt:initialFadeInTime with:^{
		[UIView beginAnimations:@"initialFadeIn" context:nil];
		[UIView setAnimationDuration:3];
		balloonOutline.alpha = 0.3;
		balloonContainerView.alpha = 1;
		[UIView commitAnimations];
	}];

	[self scheduleBreathAt:initialBreathTime withFullText:nil andEmptyText:nil];
	[self scheduleBreathAt:secondBreathTime withFullText:nil andEmptyText:nil];
	
	float t = firstCountingBreathTime;
	for (int i=0;i<8;i++) {
		[self scheduleBreathAt:t withFullText:[NSString stringWithFormat:@"%d",(i+1)] andEmptyText:@"Relax"];
		t += breathDuration+holdDuration+breathDuration+pauseDuration;
	}
	for (int i=7;i>=0;i--) {
		[self scheduleBreathAt:t withFullText:[NSString stringWithFormat:@"%d",(i+1)] andEmptyText:@"Relax"];
		t += breathDuration+holdDuration+breathDuration+pauseDuration;
	}
	
}

-(void) viewWillDisappear:(BOOL)animated {
	for (int i=0;i<timers.count;i++) {
		NSTimer *timer = [timers objectAtIndex:i];
		[timer invalidate];
	}
	[[UIApplication sharedApplication] setIdleTimerDisabled:NO];
	[super viewWillDisappear:animated];
}

-(void)dealloc {
	[startTime release];
	[timers release];
	[balloonContainerView release];
	[balloonOutline release];
	[balloonGreen release];
	[balloonYellow release];
	[balloonRed release];
	[labelView release];
	[super dealloc];
}

@end
