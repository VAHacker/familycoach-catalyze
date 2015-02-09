//
//  RelaxationIntroController.h
//  iStressLess
//


//

#import <Foundation/Foundation.h>
#import "ContentViewController.h"
#import "ContentListViewController.h"

@interface EMASchedulerController : ContentListViewController<UIPickerViewDataSource,UIPickerViewDelegate> {
    NSDateFormatter *dateFormatter;
    NSDate *reminderTOD;
    int dayOfWeek;
}

@property (nonatomic,retain) UIPickerView *dayPickerView;
@property (nonatomic,retain) UIDatePicker *pickerView;

@end
