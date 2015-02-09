//
//  SimpleExerciseController.m
//  iStressLess
//


//

#import "TimeoutController.h"
#import "ManageSymptomsNavController.h"
#import "ThemeManager.h"
#import "iStressLessAppDelegate.h"

#define BUTTON_START_TIMER 300
#define BUTTON_MORE_RELAX 301

@implementation TimeoutController

- (id)init {
    self = [super init];
    if (self) {
        startedTimerAlready = FALSE;
    }
    return self;
}

-(void) updateTimerDisplay {
	double now = CACurrentMediaTime();
	int seconds = (now - [self timerStartTime]);
	seconds = 60*timerDuration - seconds;
	if (seconds <= 0) {
		seconds = 0;
		if (timer) {
			[timer invalidate];
			[timer release];
			timer = nil;
		}
	}
	int minutes = seconds / 60;
	seconds -= (minutes*60);
	timerLabel.text = [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
}

-(void) timerFired: (NSTimer*)timer {
	[self updateTimerDisplay];
}

- (void) startTimer {

	if (timer) {
		[timer invalidate];
		[timer release];
		timer = nil;
	}
	
	[[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    startedTimerAlready = TRUE;

	timer = [NSTimer
			 scheduledTimerWithTimeInterval:0.5
			 target:self 
			 selector:@selector(timerFired:)
			 userInfo:nil 
			 repeats:YES];
	[timer retain];
	
//    if (self.timerStartTime == 0) {
        self.timerStartTime =  CACurrentMediaTime();
//    }
    
    [self updateTimerDisplay];
}

-(void) configureFromContent {
	[super configureFromContent];
    timerDuration = 5;
    NSString *s = [self.content getExtraString:@"timeoutDuration"];
    if (s) timerDuration = [s doubleValue];
    
    ThemeManager *theme = [ThemeManager sharedManager];
	int seconds = 60*timerDuration;
	int minutes = seconds / 60;
	seconds -= (minutes*60);
	NSString *timerText = [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
    UIView *v = [self createLabel:timerText withFont:[UIFont fontWithName:@"Helvetica-Bold" size:56] andColor:[theme colorForName:@"textColor"]];

	timerLabel = [[v subviews] objectAtIndex:0];
	timerLabel.textAlignment = UITextAlignmentCenter;
	[self addCenteredView:timerLabel];
	[v release];
    
    [self addButtonWithText:@"Start Timer" andStyle:BUTTON_STYLE_INLINE callingBlock:^{
        [self startTimer];
    }].isDefault = TRUE;
}

-(void) viewWillAppear:(BOOL)animated {
	[super viewWillAppear:(BOOL)animated];
}

-(void) viewWillDisappear:(BOOL)animated {
	[[UIApplication sharedApplication] setIdleTimerDisabled:NO];
	if (timer) {
		[timer invalidate];
		[timer release];
		timer = nil;
	}
	[super viewWillDisappear:animated];
}

-(void) dealloc {
	if (timer) {
		[timer invalidate];
		[timer release];
		timer = nil;
	}
	[timerLabel release];
	
	[super dealloc];
}

@end
