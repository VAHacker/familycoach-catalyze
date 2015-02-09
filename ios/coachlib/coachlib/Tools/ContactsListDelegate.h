//
//  RelaxationIntroController.h
//  iStressLess
//


//

#import <Foundation/Foundation.h>
#import "ContentViewController.h"
#import <AddressBookUI/AddressBookUI.h>
#import <EventKitUI/EventKitUI.h>
#import <UIKit/UIKit.h>

@interface ContactsListDelegate : NSObject<UITableViewDelegate,UITableViewDataSource,ABPersonViewControllerDelegate, UIAlertViewDelegate,ABPeoplePickerNavigationControllerDelegate,EKEventEditViewDelegate, ABNewPersonViewControllerDelegate,UIActionSheetDelegate> {
	NSArray *contacts;
	NSMutableDictionary *headerDict;
	ABAddressBookRef addressBook;
    NSMutableArray *people;
    ContentViewController *owner;
    NSString *storageID;
}

@property(readwrite, assign) ContentViewController *owner;
@property(nonatomic, retain) UITableView *tableView;

-(id) initWithStorageID:(NSString*)_storageID;
-(id) initWithStorageID:(NSString*)_storageID andAllowEditing:(BOOL)editing;
-(id) initWithData:(NSString*)_value;

@end
