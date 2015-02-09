//
//  RelaxationIntroController.m
//  iStressLess
//

#if 0
//

#import "SafetyPlanController.h"
#import "ManageSymptomsNavController.h"
#import "iStressLessAppDelegate.h"

@implementation SafetyPlanController

-(NSManagedObject*)checkProxy {
    NSString *finishedPlan = [[iStressLessAppDelegate instance] getSetting:@"finishedSafetyPlan"];
    ContentViewController *cvc = nil;
    if (finishedPlan && [finishedPlan isEqualToString:@"true"]) {
        return [self getChildControllerWithName:@"@subsequent"];
    }
	return [self getChildControllerWithName:@"@first"];
}

/*
-(void) addNextButton {
}

-(void) configureFromContent {
	[super configureFromContent];
	
	NSString *s = [[self nextContent] valueForKey:@"displayName"];
	if (!s) s = @"Begin Exercise";

	UIButton *nextButton = [self createButton:BUTTON_ADVANCE_EXERCISE withText:s];
	
	CGRect r;
	
	r = nextButton.frame;
	
	r.size.height *= 1.5;
	r.size.width = self.dynamicView.frame.size.width - 20;
	nextButton.frame = r;

	[nextButton setFont:[nextButton.font fontWithSize:17]];
	
	[self addText:@""];
	[self addCenteredView:nextButton];
	
	[self addThumbs];
    [self addNewToolButton];
}
*/
@end
#endif
