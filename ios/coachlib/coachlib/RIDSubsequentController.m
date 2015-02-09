//
//  SimpleExerciseController.m
//  iStressLess
//


//

#import "RIDSubsequentController.h"
#import "ManageSymptomsNavController.h"
#import "Content+ContentExtensions.h"

@implementation RIDSubsequentController

-(void) configureFromContent {
	[super configureFromContent];
	
	NSArray *a = [self getChildContentList];
	textViews = [[NSMutableArray alloc] initWithCapacity:a.count];
	for (int i=0;i<a.count;i++) {
		Content *o = [a objectAtIndex:i];
		NSString *prompt = [o valueForKey:@"mainText"];
		NSString *exampleText = [o getExtraString:@"exampleText"];
		[self addText:prompt];
		[textViews addObject:[self addTextInputWithLines:3 andPlaceholder:exampleText]];
	}
    UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, nil);
}

- (void) reportVariables {
	NSArray *a = [self getChildContentList];
	for (int i=0;i<a.count;i++) {
		NSManagedObject *o = [a objectAtIndex:i];
		GTextView *tv = [textViews objectAtIndex:i];
		[self setVariable:[o valueForKey:@"name"] to:tv.text];
	}
}

- (void) navigateToNext {
	for (int i=0;i<textViews.count;i++) {
		GTextView *tv = [textViews objectAtIndex:i];
		if (!tv.text || [tv.text isEqual:@""]) {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Some Fields Empty" message:@"Please fill in the requested fields to continue with the RIDS exercise." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
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
