//
//  FavoritesListViewController.h
//  iStressLess
//


//

#import <Foundation/Foundation.h>
#import "ContentListViewController.h"

@interface PickDateTimeController : ContentListViewController {
}

@property (nonatomic, retain) Content *itemContent;
@property (nonatomic) BOOL useDuration;
@property (nonatomic) BOOL dateOnly;
@property (nonatomic) BOOL timeOnly;
@property (nonatomic) BOOL futureOnly;
@property (nonatomic, retain) NSString *selectionVariable;
@property (nonatomic, retain) NSString *alarmSelectionVariable;
@property (nonatomic, retain) NSString *alarmID;
@property (nonatomic, retain) NSString *defaultValue;
@property (nonatomic, retain) UIView *pickerView;
@property (nonatomic, retain) UIDatePicker *picker;
@property (nonatomic, retain) ButtonModel *doneButton;

@property (nonatomic, retain) NSString *alarmInfo;
@property (nonatomic, retain) NSString *alarmDestination;
@property (nonatomic, retain) NSString *alarmAction;
@property (nonatomic, retain) NSString *alarmBody;

@end
