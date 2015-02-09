//
//  FavoritesListViewController.m
//  iStressLess
//


//

#import <EventKitUI/EventKitUI.h>
#import "ReminderListController.h"
#import "iStressLessAppDelegate.h"
#import "ThreeLabelTableViewCell.h"
#import "Reminder+ReminderExtensions.h"
#import "UIAlertView+MKBlockAdditions.h"

@implementation ReminderListController

- (void)configureCell:(UITableViewCell *)_cell atIndexPath:(NSIndexPath *)indexPath {
    Reminder *reminder = [self.fetchedResultsController objectAtIndexPath:indexPath];
//	cell.accessoryType = (value && key && [value isEqual:key]) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    ThreeLabelTableViewCell *cell = (ThreeLabelTableViewCell*)_cell;
    if ([reminder.type isEqualToString:@"tool"]) {
        cell.titleLabel.text = @"Use Tool";
    } else if ([reminder.type isEqualToString:@"appt"]) {
        cell.titleLabel.text = @"Appointment";
    } else if ([reminder.type isEqualToString:@"assess"]) {
        cell.titleLabel.text = @"Take Assessment";
    }
    
    NSDate *date = reminder.time;
    NSTimeInterval fromNow = [date timeIntervalSinceNow];
    NSCalendar *cal = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
    NSDateComponents *thenComponents = [cal components:NSDayCalendarUnit fromDate:date];
    NSDateComponents *nowComponents = [cal components:NSDayCalendarUnit fromDate:[NSDate date]];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    if ([thenComponents day] > [nowComponents day]) {
        [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
        [dateFormatter setDateStyle:NSDateFormatterShortStyle];
        cell.rightLabel.text = [dateFormatter stringFromDate:date];
    } else if (fromNow <= 0) {
        cell.rightLabel.text = @"Due";
    } else {
        [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
        [dateFormatter setDateStyle:NSDateFormatterNoStyle];
        cell.rightLabel.text = [dateFormatter stringFromDate:date];
    }
    cell.subtitleLabel.text = reminder.displayName;
    [dateFormatter release];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return true;
}

-(UITableViewCell *)createCell:(NSString*)typeIdentifier NS_RETURNS_RETAINED {
    NSArray *a = [[NSBundle mainBundle] loadNibNamed:@"ThreeLabelTableViewCell" owner:self options:nil];
    return [[a objectAtIndex:0] retain];
}

- (void)eventEditViewController:(EKEventEditViewController *)evc didCompleteWithAction:(EKEventEditViewAction)action {
    Reminder *reminder = self.selectedReminder;
	[evc.presentingViewController dismissViewControllerAnimated:TRUE completion:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            NSManagedObjectContext *ctx = [iStressLessAppDelegate instance].udManagedObjectContext;
            if ((action == EKEventEditViewActionDeleted) || ([reminder.time timeIntervalSinceNow] < 0)) {
                [ctx deleteObject:reminder];
            } else {
                reminder.time = evc.event.startDate;
                reminder.type = @"appt";
                reminder.eventID = evc.event.eventIdentifier;
                reminder.displayName = evc.event.title;
                reminder.reference = nil;
            }
            [ctx save:NULL];
        });
    }];

    self.selectedReminder = nil;
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
    Reminder *reminder = (Reminder*)mo;
    if ([reminder.type isEqualToString:@"tool"]) {
        if ([reminder.time timeIntervalSinceNow] > 5*60) {
        [UIAlertView alertViewWithTitle:@"Not Time Yet" message:@"It isn't time yet to use this tool.  Do you want to do it now anyway, and clear this reminder?" cancelButtonTitle:@"Nevermind" otherButtonTitles:@[@"Clear reminder",@"Use the tool"] onDismiss:^(int buttonIndex) {
            if (buttonIndex > 0) {
                [self navigateToContent:reminder.referencedContent];
            }
            [reminder.managedObjectContext deleteObject:reminder];
            [reminder.managedObjectContext save:NULL];
            } onCancel:NULL];
        } else {
            [self navigateToContent:reminder.referencedContent];
            [reminder.managedObjectContext deleteObject:reminder];
            [reminder.managedObjectContext save:NULL];
        }
    } else if ([reminder.type isEqualToString:@"appt"]) {
        [UIAlertView alertViewWithTitle:@"Scheduled Activity" message:@"Would you like to view the calendar event, or clear this reminder?" cancelButtonTitle:@"Nevermind" otherButtonTitles:@[@"Clear reminder",@"View event"] onDismiss:^(int buttonIndex) {
            if (buttonIndex == 0) {
                [reminder.managedObjectContext deleteObject:reminder];
                [reminder.managedObjectContext save:NULL];
            } else {
                EKEventStore * eventStore = [iStressLessAppDelegate instance].eventStore;
                EKEvent *event = [eventStore eventWithIdentifier:reminder.eventID];
                
                EKEventEditViewController *evc = [[EKEventEditViewController alloc] init];
                evc.eventStore = eventStore;
                evc.event = event;
                evc.delegate = self;
                evc.editViewDelegate = self;
                
                self.selectedReminder = reminder;
                [[iStressLessAppDelegate instance] presentModalViewController:evc animated:TRUE];
            }
        } onCancel:NULL];
    } else if ([reminder.type isEqualToString:@"assess"]) {
    }
}

- (NSFetchedResultsController *)createFetchedResultsController {
	NSManagedObjectContext *udContext = [iStressLessAppDelegate instance].udManagedObjectContext;

    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Reminder"];
    [fetchRequest setFetchBatchSize:100];
    
    if ([[self.content getExtraString:@"dueOnly"] isEqualToString:@"true"]) {
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"time <= %@",[[NSDate date] dateByAddingTimeInterval:5*60]];
    }

    // Edit the sort key as appropriate.
    NSArray *sortDescriptors = [NSArray arrayWithObjects:
								[NSSortDescriptor sortDescriptorWithKey:@"time" ascending:YES],
								nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
	
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:udContext sectionNameKeyPath:nil cacheName:nil];
    aFetchedResultsController.delegate = self;
    
    NSError *error = nil;
    if (![aFetchedResultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return aFetchedResultsController;
}

@end
