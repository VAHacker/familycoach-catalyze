//
//  SimpleExerciseController.m
//  iStressLess
//


//

#import "TextEntryController.h"
#import "Content+ContentExtensions.h"

@implementation TextEntryController

-(void) configureFromContent {
	[super configureFromContent];
    int lines = [self.content getExtraInt:@"lines"];
    self.selectionVariable = [self.content getExtraString:@"selectionVariable"];
    NSString *exampleText = [self.content getExtraString:@"exampleText"];
    self.textView = [self addTextInputWithLines:(lines != INT_MAX)?lines:3 andPlaceholder:exampleText];
    self.textView.text = (NSString*)[self getVariable:self.selectionVariable];
    self.textView.delegate = self;
}

- (void)textViewDidChange:(UITextView *)textView {
    [self setVariable:self.selectionVariable to:self.textView.text];
}

@end
