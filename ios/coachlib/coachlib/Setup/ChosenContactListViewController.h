//
//  ChoosenAudioListViewController.h
//  iStressLess
//


//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "ContentListViewController.h"

@interface ChosenContactListViewController : ContentListViewController<ABPeoplePickerNavigationControllerDelegate, UIActionSheetDelegate, ABNewPersonViewControllerDelegate, ABPersonViewControllerDelegate> {
	ABAddressBookRef addressBook;
	BOOL firstTimeDisplayed;
    
    NSManagedObjectContext *_tempContext;
    NSPersistentStore *_tempStore;
    BOOL _picking;
}

@end
