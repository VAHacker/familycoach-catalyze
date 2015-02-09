//
//  RelaxationIntroController.h
//  iStressLess
//


//

#import <Foundation/Foundation.h>
#import "SubsequentExerciseController.h"
#import <AddressBookUI/AddressBookUI.h>
#import <EventKitUI/EventKitUI.h>
#import "ContactsListDelegate.h"

@interface WhoToContactController : ContentViewController {
	UIButton *scheduleItButton;
    ContactsListDelegate *contactsList;
}

@end
