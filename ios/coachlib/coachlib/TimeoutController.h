//
//  SimpleExerciseController.h
//  iStressLess
//


//

#import <UIKit/UIKit.h>
#import "SimpleExerciseController.h"

@interface TimeoutController : SimpleExerciseController {
	UILabel *timerLabel;
	NSTimer *timer;
	UIButton *nextButton;
	double timerDuration;
    boolean_t startedTimerAlready;
}

@property (nonatomic) long timerStartTime;

@end
