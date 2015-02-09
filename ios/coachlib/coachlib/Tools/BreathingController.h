//
//  RelaxationIntroController.h
//  iStressLess
//


//

#import <Foundation/Foundation.h>
#import "BaseExerciseController.h"

@interface BreathingController : BaseExerciseController {
	NSDate *startTime;
	NSMutableArray *timers;
	NSTimeInterval lastInterval;
	
	UIView *balloonContainerView;
	UIImageView *balloonOutline;
	UIImageView *balloonGreen;
	UIImageView *balloonYellow;
	UIImageView *balloonRed;
	UIView *currentVisible;
	UILabel *labelView;
    
    float breathDuration;
    float holdDuration;
    float pauseDuration;
    float initialFadeInTime;
    float initialBreathTime;
    float secondBreathTime;
    float firstCountingBreathTime;
}

@end
