//
//  RelaxationIntroController.m
//  iStressLess
//


//

#import "SimpleExerciseIntroController.h"
#import "ManageSymptomsNavController.h"
#import "heartbeat.h"

@implementation SimpleExerciseIntroController

-(void) addNextButton {
}

-(NSString*) nextButtonTitle {
    return nil;
}

-(void) configureFromContent {
	[super configureFromContent];
	NSString *content = [[self nextContent] valueForKey:@"displayName"];
    [heartbeat
     logEvent:@"ExerciseBegin"
     withParameters:[NSDictionary dictionaryWithObjectsAndKeys:content, @"value", nil]];
	if (!content) content = @"Begin Exercise";
	[self addButtonWithText:content andStyle:BUTTON_STYLE_INLINE callingBlock:^{
        [self navigateToNext];
    }].isDefault = TRUE;
}

@end
