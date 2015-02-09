//
//  RelaxationIntroController.m
//  iStressLess
//


//
/*
#import "MakeSafetyPlanController.h"
#import "ManageSymptomsNavController.h"
#import "iStressLessAppDelegate.h"

@implementation MakeSafetyPlanController

-(void) addNextButton {
}

-(NSString*)mainText {
    NSString *finishedPlan = [[iStressLessAppDelegate instance] getSetting:@"finishedSafetyPlan"];
    NSString *startedPlan = [[iStressLessAppDelegate instance] getSetting:@"startedSafetyPlan"];

    if (finishedPlan && [finishedPlan isEqualToString:@"true"]) {
        return [[self getChildContentWithName:@"@recreate"] valueForKey:@"mainText"];
    }

    if (startedPlan && [startedPlan isEqualToString:@"true"]) {
        return [[self getChildContentWithName:@"@incomplete"] valueForKey:@"mainText"];
    }
    
    return [super mainText];
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
}

-(void)advanceToNext {
    [[iStressLessAppDelegate instance] setSetting:@"startedSafetyPlan" to:@"true"];
    [super advanceToNext];
}

@end
*/
