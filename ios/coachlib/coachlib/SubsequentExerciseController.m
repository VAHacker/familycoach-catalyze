//
//  SimpleExerciseController.m
//  iStressLess
//


//

#import "SubsequentExerciseController.h"
#import "ManageSymptomsNavController.h"

@implementation SubsequentExerciseController

-(void) addNextButton {
}

-(NSString *)nextButtonTitle {
	NSString *s = [[self nextContent] valueForKey:@"displayName"];
	if (!s) s = @"Next";
    return s;
}

@end
