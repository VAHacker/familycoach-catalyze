//
//  SimpleExerciseController.h
//  iStressLess
//


//

#import <UIKit/UIKit.h>
#import "ContentViewController.h"
#import "GLabel.h"

@interface SliderController : ContentViewController {
}

@property(retain, nonatomic) GLabel *thumbView;
@property(retain, nonatomic) UISlider *sliderView;
@property (nonatomic, retain) NSString *selectionVariable;

@end
