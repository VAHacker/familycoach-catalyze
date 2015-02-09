//
//  SimpleExerciseController.m
//  iStressLess
//


//

#import "SetupController.h"
#import "iStressLessAppDelegate.h"

@implementation SetupController

-(BOOL)resetApp:(Content*)source {
    NSString *title = source.title;
    NSString *mainText = source.mainText;
    [UIAlertView alertViewWithTitle:title message:mainText cancelButtonTitle:@"No, cancel" otherButtonTitles:@[@"Yes, reset"] onDismiss:^(int buttonIndex) {
     [[iStressLessAppDelegate instance] resetApp];
     } onCancel:NULL];
    return TRUE;
}

-(BOOL)clearToolPrefs:(Content*)source {
    [UIAlertView alertViewWithTitle:@"Confirm Clear Tool Preferences" message:@"This will clear all per-tool \"thumbs up\" and \"thumbs down\" preferences you've selected.  Are you sure?" cancelButtonTitle:@"No, cancel" otherButtonTitles:@[@"Yes, clear them"] onDismiss:^(int buttonIndex) {
     [[iStressLessAppDelegate instance] resetTools];
     } onCancel:NULL];
    return TRUE;
}

-(void)configureFromContent {
    [super configureFromContent];
    
    [self registerAction:@"clearToolPrefs" withSelector:@selector(clearToolPrefs:)];
    [self registerAction:@"resetApp" withSelector:@selector(resetApp:)];

}

@end
