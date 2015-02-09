//
//  RelaxationIntroController.m
//  iStressLess
//


//

#import "CrisisIntroController.h"
#import "ManageSymptomsNavController.h"

@implementation CrisisIntroController

-(NSString *)nextButtonTitle {
    return nil;
}

-(void) configureFromContent {
	[super configureFromContent];
    
    NSString *gimmeToolMsg = @"No, give me the tool";
    Content *preselectedExercise = (Content*)[self getVariable:@"preselectedExercise"];
    if ((!preselectedExercise || [preselectedExercise.entity.name isEqualToString:@"ExerciseCategory"])) {
        gimmeToolMsg = @"No, give me a tool";
    }
    
    [self addButtonWithText:gimmeToolMsg andStyle:BUTTON_STYLE_INLINE callingBlock:^{
        [self navigateToContentName:@"exercise"];
    }];
    [self addButtonWithText:@"Yes, talk to someone now" andStyle:BUTTON_STYLE_INLINE callingBlock:^{
        [self navigateToNext];
    }];
}

@end
