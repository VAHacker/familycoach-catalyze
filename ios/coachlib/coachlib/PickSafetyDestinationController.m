//
//  SimpleExerciseController.m
//  iStressLess
//


//

#import "PickSafetyDestinationController.h"
#import "ManageSymptomsNavController.h"
#import "iStressLessAppDelegate.h"
#import "GTextView.h"
#import "Content+ContentExtensions.h"

@implementation PickSafetyDestinationController

-(void) configureFromContent {
	[super configureFromContent];
	
	NSArray *a = [self getChildContentList];
	textViews = [[NSMutableArray alloc] initWithCapacity:a.count];
	for (int i=0;i<a.count;i++) {
		Content *o = [a objectAtIndex:i];
		NSString *prompt = [o valueForKey:@"mainText"];
		NSString *exampleText = [o getExtraString:@"exampleText"];
		[self addText:prompt];
        GTextView *tv = [self addTextInputWithLines:3 andPlaceholder:exampleText];
        NSString *storeAs = [o getExtraString:@"storeAs"];
        tv.text = [[iStressLessAppDelegate instance] getSetting:storeAs];
		[textViews addObject:tv];
	}
    UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, nil);
}

- (void) reportVariables {
	NSArray *a = [self getChildContentList];
	for (int i=0;i<a.count;i++) {
		Content *o = [a objectAtIndex:i];
		GTextView *tv = [textViews objectAtIndex:i];
        NSString *storeAs = [o getExtraString:@"storeAs"];
        [[iStressLessAppDelegate instance] setSetting:storeAs to:tv.text];
	}
}

- (void) navigateToNext {
	for (int i=0;i<textViews.count;i++) {
		GTextView *tv = [textViews objectAtIndex:i];
		if (!tv.text || [tv.text isEqual:@""]) {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Some Fields Empty" message:@"Please fill in the requested field before going on." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
			[alert show];
			[alert release];
			return;
		}
	}
    
	[self reportVariables];
	[super navigateToNext];
}

-(void) dealloc {
	[textViews release];
	
	[super dealloc];
}

@end
