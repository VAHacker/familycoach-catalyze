//
//  SimpleExerciseController.h
//  iStressLess
//


//

#import <UIKit/UIKit.h>
#import "ContentViewController.h"
#import "GTextView.h"

@interface TextEntryController : ContentViewController <UITextViewDelegate> {
}

@property(retain, nonatomic) GTextView *textView;
@property (nonatomic, retain) NSString *selectionVariable;

@end
