//
//  RelaxationIntroController.m
//  iStressLess
//


//

#import "ScheduleAppointmentController.h"
#import "ManageSymptomsNavController.h"
#import "ContactsListDelegate.h"
#import "QuestionInstance.h"
#import "iStressLessAppDelegate.h"
#import "Reminder+ReminderExtensions.h"

@implementation ScheduleAppointmentController

- (void)eventEditViewController:(EKEventEditViewController *)evc didCompleteWithAction:(EKEventEditViewAction)action {
	[evc.presentingViewController dismissViewControllerAnimated:TRUE completion:NULL];
    [self.masterController popExecLeaf:self];
    if (action == EKEventEditViewActionSaved) {
        [evc.eventStore saveEvent:evc.event span:EKSpanFutureEvents commit:TRUE error:NULL];
        
        NSManagedObjectContext *ctx = [iStressLessAppDelegate instance].udManagedObjectContext;
        Reminder *reminder = [[[Reminder alloc] initWithEntity:[NSEntityDescription entityForName:@"Reminder" inManagedObjectContext:ctx] insertIntoManagedObjectContext:ctx] autorelease];
        reminder.time = evc.event.startDate;
        reminder.type = @"appt";
        reminder.eventID = evc.event.eventIdentifier;
        reminder.displayName = evc.event.title;
        reminder.reference = nil;
        [ctx save:NULL];
        
        NSLog(@"%@",reminder);
    }
}
/*
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if ([viewController isKindOfClass:[UITableViewController class]]) {
        ((UITableViewController *)viewController).tableView.backgroundColor = [self backgroundColorToUse];
        ((UITableViewController *)viewController).tableView.backgroundView = [self backgroundViewToUse];
    } else {
    }
}
*/

-(BOOL) shouldExecInsteadOfPush {
    return TRUE;
}

-(void)execInsteadOfPush {
    ScheduleAppointmentController *_self = self;
    [[iStressLessAppDelegate instance] passCalendarForEventsFor:self to:^(EKCalendar *cal) {
        if (!cal) return;
        /*
        [[UITableView appearanceWhenContainedIn:[EKEventEditViewController class],nil] setBackgroundView:nil];
        [[UITableView appearanceWhenContainedIn:[EKEventEditViewController class],nil] setBackgroundImage:nil];
        [[UITableView appearanceWhenContainedIn:[EKEventEditViewController class],nil] setBackgroundColor:[UIColor blueColor]];
*/
        EKEventStore * eventStore = [iStressLessAppDelegate instance].eventStore;
        EKEvent *event = [EKEvent eventWithEventStore:eventStore];
        event.startDate = [NSDate dateWithTimeIntervalSinceNow:24*60*60];
        event.endDate = [event.startDate dateByAddingTimeInterval:15*60];
        event.calendar = cal;
        event.title = @"PTSD Coach appointment";
        [event addAlarm:[EKAlarm alarmWithRelativeOffset:(NSTimeInterval)-30*60]];
        
        EKEventEditViewController *evc = [[EKEventEditViewController alloc] init];
        evc.eventStore = eventStore;
        evc.event = event;
        evc.delegate = self;
        evc.editViewDelegate = self;
        [_self.masterController presentModalViewController:evc animated:TRUE];
        [evc release];
    }];
}

@end
