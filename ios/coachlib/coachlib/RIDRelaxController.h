//
//  SimpleExerciseController.h
//  iStressLess
//


//

#import <UIKit/UIKit.h>
#import "SubsequentExerciseController.h"

@interface RIDRelaxController : SubsequentExerciseController {
	UILabel *timerLabel;
	NSTimer *timer;
	double timerStartTime;
}

@property (nonatomic,retain) ButtonModel *goAgainButton;

@end
