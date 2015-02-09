//
//  RelaxationIntroController.m
//  iStressLess
//

#if 0
//

#import "SafetyPlanFinishedController.h"
#import "ManageSymptomsNavController.h"
#import "iStressLessAppDelegate.h"

@implementation SafetyPlanFinishedController

-(void) configureFromContent {
	[super configureFromContent];
    [[iStressLessAppDelegate instance] setSetting:@"finishedSafetyPlan" to:@"true"];
}

-(void) buttonPressed:(UIButton *)button {
	if (button.tag >= BUTTON_ADVANCE_EXERCISE) {
        NSManagedObject *parent = [[iStressLessAppDelegate instance] getContentWithName:@"safetyPlan"];
        NSManagedObject *child = [self getChildContentWithName:@"@subsequent" forContent:parent];
        ContentViewController *cvc = [[iStressLessAppDelegate instance] getContentControllerForObject:child];
        ((BaseExerciseController*)cvc).exerciseContent = self.exerciseContent;
        [self.masterController pushViewControllerAndRemoveAllNonRootPrevious:cvc];
    }
}

@end

#endif
