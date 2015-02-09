//
//  SimpleExerciseController.m
//  iStressLess
//


//

#import "RIDRelaxController.h"
#import "ManageSymptomsNavController.h"
#import "iStressLessAppDelegate.h"
#import "ThemeManager.h"

#define BUTTON_START_TIMER 300
#define BUTTON_MORE_RELAX 301

@implementation RIDRelaxController

-(void) updateTimerDisplay {
	double now = CACurrentMediaTime(); 
	int seconds = (now - timerStartTime);
	seconds = 30 - seconds;
	if (seconds <= 0) {
		self.goAgainButton.enabled = TRUE;
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
	self.goAgainButton.enabled = FALSE;

	if (timer) {
		[timer invalidate];
		[timer release];
		timer = nil;
	}
	
	timer = [NSTimer 
			 scheduledTimerWithTimeInterval:0.5
			 target:self 
			 selector:@selector(timerFired:) 
			 userInfo:nil 
			 repeats:YES];
	[timer retain];
	
	timerStartTime = CACurrentMediaTime(); 
}

-(void) configureFromContent {
    self.goAgainButton = [self addButtonWithText:@"30 More Seconds of Relax" andStyle:BUTTON_STYLE_INLINE callingBlock:^{
        [self startTimer];
		[self updateTimerDisplay];
    }];
    self.goAgainButton.enabled = FALSE;
    
	[super configureFromContent];

    ThemeManager *theme = [ThemeManager sharedManager];
    UIView *v = [self createLabel:@"00:30" withFont:[UIFont fontWithName:@"Helvetica-Bold" size:56] andColor:[theme colorForName:@"textColor"]];
	timerLabel = [[v subviews] objectAtIndex:0];
	timerLabel.textAlignment = UITextAlignmentCenter;
	[self addCenteredView:timerLabel];
	[v release];
//	[self addCenteredView:[self createButton:BUTTON_DIAL_PREARRANGED_NUMBER+i withText:number]];
}

-(void) viewWillAppear:(BOOL)animated {
	[super viewWillAppear:(BOOL)animated];
	[self startTimer];
	[self updateTimerDisplay];
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
