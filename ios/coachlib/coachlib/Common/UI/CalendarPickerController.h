//
//  RelaxationIntroController.h
//  iStressLess
//


//

#import <Foundation/Foundation.h>
#import "ContentViewController.h"
#import "PickListController.h"

@interface CalendarPickerController : PickListController {
}

@property (nonatomic,retain) NSMutableArray *calendars;
@property (nonatomic) BOOL iCloudOn;
@property (nonatomic) BOOL hasPrivateCalendar;

@end
