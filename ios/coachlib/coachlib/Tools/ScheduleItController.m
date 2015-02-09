//
//  RelaxationIntroController.m
//  iStressLess
//

//

#import "ScheduleItController.h"
#import "ManageSymptomsNavController.h"
#import "ContactsListDelegate.h"
#import "QuestionInstance.h"
#import "iStressLessAppDelegate.h"

@implementation ScheduleItController

- (NSString *)nextButtonTitle {
    return nil;
}

- (void)eventEditViewController:(EKEventEditViewController *)controller didCompleteWithAction:(EKEventEditViewAction)action {
	[controller.presentingViewController dismissModalViewControllerAnimated:TRUE];
	if (action == EKEventEditViewActionSaved) {
        [self navigateToNext];
	}
}

-(void) configureFromContent {
	[super configureFromContent];
	
    NSString *contactsStr = (NSString*)[self.masterController getVariable:@"socialActivitySummaryContactList"];
    ContactsListDelegate *contactsList = [[ContactsListDelegate alloc] initWithData:contactsStr];
    contactsList.owner = self;
    [self.dynamicView addSubview:contactsList.tableView];
    self.contactsListDelegate = [contactsList autorelease];

	[self addButtonWithText:@"Add it to my calendar" andStyle:BUTTON_STYLE_INLINE callingBlock:^{
        [[iStressLessAppDelegate instance] passCalendarForEventsFor:self afterAskingForWhichCalendar:FALSE to:^(EKCalendar *cal) {
            if (!cal) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [UIAlertView alertViewWithTitle:@"Cannot Access Calendars" message:@"You've denied me access to your calendars.  If you wish to use this feature, you need to go to the Settings app and select General --> Reset --> Reset Location & Privacy." cancelButtonTitle:@"Ok" otherButtonTitles:nil onDismiss:nil onCancel:nil];
                });
                return;
            }
            
            EKEventStore *eventStore = [iStressLessAppDelegate instance].eventStore;
            EKEvent *event = [EKEvent eventWithEventStore:eventStore];
            event.calendar = cal;
            event.title = (NSString*)[self.masterController getVariable:@"socialTitle"];
            event.notes = (NSString*)[self.masterController getVariable:@"socialNotes"];
            [event addAlarm:[EKAlarm alarmWithRelativeOffset:(NSTimeInterval)-24*60*60]];
            [event addAlarm:[EKAlarm alarmWithRelativeOffset:(NSTimeInterval)-30*60]];
            
            EKEventEditViewController *evc = [[EKEventEditViewController alloc] init];
            evc.eventStore = eventStore;
            evc.event = event;
            evc.editViewDelegate = self;
            [[iStressLessAppDelegate instance] presentModalViewController:evc animated:TRUE];
            [evc release];
        }];
    }];
}

@end
