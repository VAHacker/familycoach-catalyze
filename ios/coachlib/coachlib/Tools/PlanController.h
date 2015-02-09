//
//  RelaxationIntroController.h
//  iStressLess
//


//

#import <Foundation/Foundation.h>
#import "ContentListViewController.h"
#import <AddressBookUI/AddressBookUI.h>
#import <EventKitUI/EventKitUI.h>

@interface PlanController : ContentListViewController<UIAlertViewDelegate,EKEventEditViewDelegate> {
	NSArray *contacts;
	NSMutableDictionary *headerDict;
	ABAddressBookRef addressBook;
	ButtonModel *scheduleItButton;
    BOOL hasActivities;
    BOOL hasContacts;
}

@property (nonatomic,retain) NSManagedObject *activity;
@property (nonatomic,retain) NSMutableArray *people;

@end
