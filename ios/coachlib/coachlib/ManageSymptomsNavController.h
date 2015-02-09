//
//  ManageSymptomsMasterController.h
//  iStressLess
//


//

#import <Foundation/Foundation.h>
#import "GNavigationController.h"
#import "ExerciseRef.h"

#define BUTTON_DONE				0
#define BUTTON_CHOOSE_ANOTHER	1
#define BUTTON_DONE_SUDS		2
#define BUTTON_SKIP_SUDS		3
#define BUTTON_TRY_ANOTHER		4
#define BUTTON_DONE_EVERYTHING	5

#define BUTTON_ADVANCE_EXERCISE	10

@interface ManageSymptomsNavController : GNavigationController {
	int state;
	int suds;
	NSManagedObject* symptom;
	ExerciseRef* exerciseOrCategory;
    NSURL *lastCategoryIntroID;
	double timerStartTime;
}

@property(readonly) NSManagedObject* exerciseOrCategory;
@property(readwrite) double timerStartTime;

-(BOOL)isInExercise;

@end
