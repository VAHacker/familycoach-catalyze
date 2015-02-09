//
//  RelaxationIntroController.h
//  iStressLess
//


//

#import <Foundation/Foundation.h>
#import "BaseExerciseController.h"

@interface PMRController : BaseExerciseController {
	NSDate *startTime;
	NSMutableArray *timers;
	NSTimeInterval lastInterval;
	
	UIView *bodyContainerView;
	UIImageView *bodyView;
	UIImageView *overlay;
	CGPoint bodyContainerCenter;
    NSOrderedSet *overlayContent;
}

@end
