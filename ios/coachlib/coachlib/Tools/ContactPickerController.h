//
//  RelaxationIntroController.h
//  iStressLess
//


//

#import <Foundation/Foundation.h>
#import "ContentListViewController.h"
#import <AddressBookUI/AddressBookUI.h>
#import <EventKitUI/EventKitUI.h>

@interface ContactPickerController : ContentListViewController<ABPersonViewControllerDelegate, UIAlertViewDelegate,ABPeoplePickerNavigationControllerDelegate,EKEventEditViewDelegate> {
	NSArray *contacts;
	NSMutableDictionary *headerDict;
	ABAddressBookRef addressBook;
    NSMutableArray *people;
	NSManagedObject *activity;
	ButtonModel *scheduleItButton;
    BOOL hasActivities;
    BOOL hasContacts;
}

@end
