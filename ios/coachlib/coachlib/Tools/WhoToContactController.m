//
//  RelaxationIntroController.m
//  iStressLess
//


//

#import "WhoToContactController.h"
#import "NSManagedObject+MOExtensions.h"
#import "HorizontalLayout.h"
#import "iStressLessAppDelegate.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import <EventKit/EventKit.h>
#import <EventKitUI/EventKitUI.h>
#import "ManageSymptomsNavController.h"
#import "GTableView.h"
#import "ContactsListDelegate.h"

#define BUTTON_DIAL_PREARRANGED_NUMBER 5000
#define BUTTON_CONTACT 10000
#define BUTTON_SCHEDULE_IT 20000

@implementation WhoToContactController


-(void) setEnables {
//	scheduleItButton.enabled = people.count && activity;
}

-(void) configureFromContent {
	NSString *storeAs = [self.content getExtraString:@"storeAs"];

	[super configureFromContent];
    contactsList = [[ContactsListDelegate alloc] initWithStorageID:storeAs andAllowEditing:[self.content getExtraBoolean:@"editing"]];
    contactsList.owner = self;
    [self.dynamicView addSubview:contactsList.tableView];
	[self.scrollView setNeedsLayout];
}
/*
-(void) buttonPressed:(UIButton *)button {
	if (button.tag == BUTTON_SCHEDULE_IT) {
        NSManagedObject *next = [self getChildContentWithName:@"@scheduleIt"];
        if (next) {
            [self.navigationController setVariable:@"socialActivitySummary" to:[self composeTitle]];
            ContentViewController *cvc = [self getChildControllerWithName:@"@scheduleIt"];
            [self.navigationController pushViewController:cvc animated:TRUE];
            return;
        }
		EKEventStore *eventStore = [[EKEventStore alloc] init];
		EKCalendar *cal = [eventStore defaultCalendarForNewEvents];
		
		EKEvent *event = [EKEvent eventWithEventStore:(EKEventStore *)eventStore];
		event.calendar = cal;
		event.title = [self composeTitle];
		event.notes = [self composeNotes];
		[event addAlarm:[EKAlarm alarmWithRelativeOffset:(NSTimeInterval)-24*60*60]];
		[event addAlarm:[EKAlarm alarmWithRelativeOffset:(NSTimeInterval)-30*60]];

		EKEventEditViewController *evc = [[EKEventEditViewController alloc] init];
		evc.eventStore = eventStore;
		evc.event = event;
		evc.editViewDelegate = self;
		[self presentModalViewController:evc animated:TRUE];
		[evc release];
		
		[eventStore release];
	} else {
        [super buttonPressed:button];
    }
}
*/
-(void) contentLoaded {
	[self.scrollView setNeedsLayout];
	[super contentLoaded];
}

-(void) viewWillAppear:(BOOL)animated {
	[super viewWillAppear:(BOOL)animated];
//	self.masterController.selectionDelegate = nil;
}

-(void) dealloc {
	[scheduleItButton release];
	[super dealloc];
}

@end
