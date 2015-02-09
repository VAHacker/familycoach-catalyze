
#import <Foundation/Foundation.h>
#import "DynamicListController.h"

@interface WellnessJournalController : DynamicListController <UIPickerViewDataSource,UIPickerViewDelegate>
{
}

@property (retain) UIView *pickerView;
@property (retain) UIPickerView *picker;
@property (retain) NSArray *filterByOptions;
@property (retain) UIButton *filterButton;
@property (retain) ButtonModel *doneButton;

@end
