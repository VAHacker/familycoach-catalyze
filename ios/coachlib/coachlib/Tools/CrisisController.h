//
//  RelaxationIntroController.h
//  iStressLess
//


//

#import <Foundation/Foundation.h>
#import "ContentListViewController.h"
#import "AlertDelegate.h"
#import <AddressBookUI/AddressBookUI.h>

@interface CrisisController : ContentListViewController<ABPersonViewControllerDelegate, UIAlertViewDelegate> {
	NSArray *contacts;
	NSMutableDictionary *headerDict;
	ABAddressBookRef addressBook;
}

@end
