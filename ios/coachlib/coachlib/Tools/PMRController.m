//
//  RelaxationIntroController.m
//  iStressLess
//


//

#import "PMRController.h"
#import "ManageSymptomsNavController.h"
#import "GFunctor.h"

@implementation PMRController

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

-(BOOL)shouldAddListenButton {
    return FALSE;
}

-(void) configureContentView {
	UIView *cv = self.contentView;
	CGRect r = cv.bounds;
	r.size.height -= 110;
	
	bodyContainerView = [[UIView alloc] initWithFrame:r];
	r = bodyContainerView.bounds;
	bodyContainerView.autoresizesSubviews = TRUE;
	[cv addSubview:bodyContainerView];
	
    Content *rsrc = [self.content getChildByName:@"resources"];
    overlayContent = [[NSOrderedSet orderedSetWithOrderedSet:rsrc.children] retain];

	bodyView = [[UIImageView alloc] initWithFrame:r];
	bodyView.image = rsrc.uiImage;
	bodyView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	bodyView.contentMode = UIViewContentModeScaleAspectFit;
	[bodyContainerView addSubview:bodyView];
	
	overlay = [[UIImageView alloc] initWithFrame:r];
	overlay.alpha = 0;
	overlay.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	overlay.contentMode = UIViewContentModeScaleAspectFit;
	[bodyContainerView addSubview:overlay];
	bodyContainerCenter =  bodyContainerView.center;
}

-(void) configureBackground {
	[topView setBackgroundColor:[UIColor blackColor]];
}

-(void) focusBodyPart:(UIImage*)image at:(NSTimeInterval)interval withAlphaDuration:(float)alphaDuration withCentering:(CGPoint)newCenter withPanDuration:(float)panDuration andScale:(float)scale {
	[self setKeyframeAt:interval with:^{
        [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
        [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
		overlay.image = image; // [UIImage imageNamed:[NSString stringWithFormat:@"Content/%@.png",part]];
		
		[UIView beginAnimations:@"keyframe" context:nil];
		[UIView setAnimationDuration:alphaDuration]; // 3
		overlay.alpha = 1;
		[UIView commitAnimations];
	}];
	
    if (!isnan(scale) && !isnan(panDuration)) {
        [self setKeyframeAtDelta:1 with:^{
            [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
            [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
            [UIView beginAnimations:@"keyframe2" context:nil];
            [UIView setAnimationDuration:panDuration]; // 8
            bodyContainerView.transform = CGAffineTransformConcat(CGAffineTransformMakeTranslation(newCenter.x, newCenter.y), CGAffineTransformMakeScale(scale, scale));
            [UIView commitAnimations];
        }];
    }
}

-(void) unfocusBodyPartAt:(NSTimeInterval)interval withAlphaDuration:(float)alphaDuration withPanDuration:(float)panDuration {
	[self setKeyframeAt:interval with:^{
        [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
        [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
		[UIView beginAnimations:@"keyframe" context:nil];
		[UIView setAnimationDuration:panDuration]; // 5
		bodyContainerView.center = bodyContainerCenter;
		bodyContainerView.transform = CGAffineTransformIdentity;
		[UIView commitAnimations];
	}];
	
	[self setKeyframeAtDelta:5 with:^{
        [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
        [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
		[UIView beginAnimations:@"keyframe" context:nil];
		[UIView setAnimationDuration:alphaDuration]; //2
		overlay.alpha = 0;
		[UIView commitAnimations];
	}];
}

-(void) viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[[UIApplication sharedApplication] setIdleTimerDisabled:NO];
	[[UIApplication sharedApplication] setIdleTimerDisabled:YES];
	[self playAudio];
	    
	startTime = [NSDate date];
	[startTime retain];
	lastInterval = 0;
	
    for (Content *c in overlayContent) {
        float start = [c getExtraFloat:@"start"];
        float scale = [c getExtraFloat:@"scale"];
        float alphaDuration = [c getExtraFloat:@"alphaDuration"];
        if (isnan(alphaDuration)) alphaDuration = 3;
        CGPoint center = [c getExtraPoint:@"center"];
        float panDuration = [c getExtraFloat:@"panDuration"];
        if (isnan(panDuration)) panDuration = 8;
        
        [self focusBodyPart:c.uiImage at:start withAlphaDuration:alphaDuration withCentering:center withPanDuration:panDuration andScale:scale];

        float end = [c getExtraFloat:@"end"];
        float endAlphaDuration = [c getExtraFloat:@"endAlphaDuration"];
        if (isnan(endAlphaDuration)) endAlphaDuration = 2;
        float endPanDuration = [c getExtraFloat:@"endPanDuration"];
        if (isnan(endPanDuration)) endPanDuration = 5;
        if (end != NAN) {
            [self unfocusBodyPartAt:end withAlphaDuration:endAlphaDuration withPanDuration:endPanDuration];
        }
        
    }
    /*
	CGPoint armCenter = CGPointMake(-60, 20);
	[self focusBodyPart:@"body_arms" at:62 withCentering:armCenter andScale:3];
	[self unfocusBodyPartAt:102];

	CGPoint headCenter = CGPointMake(0, 135);
	[self focusBodyPart:@"body_head" at:115 withCentering:headCenter andScale:5];
	[self unfocusBodyPartAt:175];
 
	CGPoint shouldersCenter = CGPointMake(0,100);
	[self focusBodyPart:@"body_shoulders" at:184 withCentering:shouldersCenter andScale:3];
	[self unfocusBodyPartAt:236];

	CGPoint stomachCenter = CGPointMake(0,20);
	[self focusBodyPart:@"body_stomach" at:245 withCentering:stomachCenter andScale:5];
	[self unfocusBodyPartAt:282];

	CGPoint buttCenter = CGPointMake(0,-20);
	[self focusBodyPart:@"body_butt" at:297 withCentering:buttCenter andScale:3];
	[self unfocusBodyPartAt:337];

	CGPoint feetCenter = CGPointMake(0,-130);
	[self focusBodyPart:@"body_feet" at:357 withCentering:feetCenter andScale:3];
	[self unfocusBodyPartAt:411];

	[self setKeyframeAt:458 with:^{
		overlay.image = [UIImage imageNamed:@"Content/body_all.png"];
		
		[UIView beginAnimations:@"keyframe" context:nil];
		[UIView setAnimationDuration:20];
		overlay.alpha = 1;
		[UIView commitAnimations];
	}];
	*/
 
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
	[bodyView release];
	[overlay release];
    [overlayContent release];
	[super dealloc];
}

@end
