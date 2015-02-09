//
//  RelaxationIntroController.m
//  iStressLess
//


//

#import "ScheduleToolController.h"
#import "ManageSymptomsNavController.h"
#import "ContactsListDelegate.h"
#import "QuestionInstance.h"
#import "iStressLessAppDelegate.h"
#import "Reminder+ReminderExtensions.h"
#import "ExerciseRef.h"

@implementation ScheduleToolController

- (void)eventEditViewController:(EKEventEditViewController *)evc didCompleteWithAction:(EKEventEditViewAction)action {
	[evc dismissModalViewControllerAnimated:TRUE];
	if (action == EKEventEditViewActionSaved) {
        [evc.eventStore saveEvent:evc.event span:EKSpanFutureEvents commit:TRUE error:NULL];
        
        NSLog(@"%@",self.selectedContent);

        NSManagedObjectContext *ctx = [iStressLessAppDelegate instance].udManagedObjectContext;
        Reminder *reminder = [[Reminder alloc] initWithEntity:[NSEntityDescription entityForName:@"Reminder" inManagedObjectContext:ctx] insertIntoManagedObjectContext:ctx];
        reminder.time = evc.event.startDate;
        reminder.type = @"tool";
        reminder.eventID = evc.event.eventIdentifier;
        reminder.displayName = [NSString stringWithFormat:@"Use '%@' tool",self.selectedContent.displayName];
        reminder.reference = self.selectedContent.uniqueID;
        [ctx save:NULL];

        NSLog(@"%@",reminder);
        [reminder release];

        [self.navigationController popViewControllerAnimated:FALSE];
	}
    
    self.selectedContent = nil;
}
/*
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if ([viewController isKindOfClass:[UITableViewController class]]) {
        ((UITableViewController *)viewController).tableView.backgroundColor = [self backgroundColorToUse];
        ((UITableViewController *)viewController).tableView.backgroundView = [self backgroundViewToUse];
    } else {
        UIView *firstView = [[viewController.view subviews] objectAtIndex:0];
        if ([firstView isKindOfClass:[UITableView class]]) {
            UITableView *tv = (UITableView*)firstView;
            tv.backgroundColor = [self backgroundColorToUse];
            tv.backgroundView = [self backgroundViewToUse];
        }
    }
}
*/
-(void)managedObjectSelected:(NSManagedObject *)mo {
    Content *tool = (Content*)mo;
    UIViewController *_self = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [[iStressLessAppDelegate instance] passCalendarForEventsFor:self to:^(EKCalendar *cal) {
            if (!cal) return;
            
            self.selectedContent = tool;
            
            EKEventStore * eventStore = [iStressLessAppDelegate instance].eventStore;
            EKEvent *event = [EKEvent eventWithEventStore:eventStore];
            event.startDate = [NSDate dateWithTimeIntervalSinceNow:24*60*60];
            event.endDate = [event.startDate dateByAddingTimeInterval:15*60];
            event.calendar = cal;
            event.location = @"PTSD Coach app";
            event.title = [NSString stringWithFormat:@"Use PTSD Coach '%@' tool",tool.displayName];
            [event addAlarm:[EKAlarm alarmWithRelativeOffset:(NSTimeInterval)-5*60]];
            
            EKEventEditViewController *evc = [[EKEventEditViewController alloc] init];
            evc.eventStore = eventStore;
            evc.event = event;
            evc.editViewDelegate = self;
            evc.delegate = self;
            [_self presentModalViewController:evc animated:TRUE];
            [evc release];
        }];
    });
}


@end
