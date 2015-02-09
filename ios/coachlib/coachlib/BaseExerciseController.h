//
//  SimpleExerciseController.h
//  iStressLess
//


//

#import <UIKit/UIKit.h>
#import "ContentViewController.h"
#import "GButton.h"
#import "Content.h"
#import "ExerciseRef.h"

@interface BaseExerciseController : ContentViewController {
//	ExerciseRef *_exerciseScore;
	BOOL scoreChecked;
}

@property(readwrite, retain, nonatomic) ButtonModel *thumbsup;
@property(readwrite, retain, nonatomic) ButtonModel *thumbsdown;
@property(readwrite, retain, nonatomic) ButtonModel *ccButton;
@property(readwrite, retain, nonatomic) Content *exerciseContent;
@property(readwrite, retain, nonatomic) ExerciseRef *exerciseScore;

-(NSString*) nextButtonTitle;

@end
