//
//  RelaxationIntroController.m
//  iStressLess
//

#if 0
//

#import "ContactPickerController.h"
#import "NSManagedObject+MOExtensions.h"
#import "HorizontalLayout.h"
#import "iStressLessAppDelegate.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import <EventKit/EventKit.h>
#import <EventKitUI/EventKitUI.h>
#import "ManageSymptomsNavController.h"
#import "GTableView.h"

#define BUTTON_DIAL_PREARRANGED_NUMBER 5000
#define BUTTON_CONTACT 10000

@implementation ContactPickerController
/*
-(void) buttonPressed:(UIButton *)button {
	if (button.tag >= BUTTON_CONTACT) {
		ABAddressBookRef addressBook = ABAddressBookCreate();
		NSManagedObject *managedObject = [contacts objectAtIndex:button.tag - BUTTON_CONTACT];
		NSNumber *refID = [managedObject valueForKey:@"refID"];
		ABRecordRef rec = ABAddressBookGetPersonWithRecordID(addressBook, [refID intValue]);
		ABPersonViewController *pvc = [[ABPersonViewController alloc] init];
		pvc.displayedPerson = rec;
		pvc.personViewDelegate = self;
		pvc.navigationItem.title = @"Get Support";
		[self.navigationController pushViewController:pvc animated:TRUE];
		CFRelease(addressBook);
	} else if (button.tag >= BUTTON_DIAL_PREARRANGED_NUMBER) {
		int i = button.tag - BUTTON_DIAL_PREARRANGED_NUMBER;
		NSArray *a = [self getChildContentList];
		NSManagedObject *o = [a objectAtIndex:i];
		NSString *number = [o getExtraString:@"phoneNumber"];
		NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@",number]];
		UIApplication *app = [UIApplication sharedApplication];
		[app openURL:url];
	} else {
		[super buttonPressed:(UIButton *)button];
	}
}
*/

- (BOOL)personViewController:(ABPersonViewController *)personViewController shouldPerformDefaultActionForPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifierForValue {
	return TRUE;
}

- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker {
	[peoplePicker dismissModalViewControllerAnimated:TRUE];
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)_person {
    [people addObject:_person];
	[peoplePicker dismissModalViewControllerAnimated:TRUE];
	[self setEnables];
	return NO;
}

-(NSString *)nameForContact:(int)index {
    ABRecordRef rec = [people objectAtIndex:index];
    NSString *text = @"<Unknown person>";
    if (rec) {
        CFTypeRef firstname = ABRecordCopyValue(rec, kABPersonFirstNameProperty);
        CFTypeRef lastname = ABRecordCopyValue(rec, kABPersonLastNameProperty);
        CFTypeRef orgname = ABRecordCopyValue(rec, kABPersonOrganizationProperty);
        if (firstname && lastname) {
            text = [NSString stringWithFormat:@"%@ %@",firstname,lastname];
        } else if (firstname) {
            text = [NSString stringWithFormat:@"%@",firstname];
        } else if (lastname) {
            text = [NSString stringWithFormat:@"%@",lastname];
        } else if (orgname) {
            text = [NSString stringWithFormat:@"%@",orgname];
        }
        if (firstname) CFRelease(firstname);
        if (lastname) CFRelease(lastname);
        if (orgname) CFRelease(orgname);
    }

    return text;
}

-(NSString*)composeTitle {
	NSMutableString *s = [NSMutableString string];
	[s appendFormat:@"%@ with ",[activity valueForKey:@"displayName"]];
    for (int i=0;i<people.count;i++) {
        [s appendFormat:@"%@",[self nameForContact:i]];
        if (i == people.count-2) {
            if (people.count > 2) {
                [s appendString:@", and "];
            } else {
                [s appendString:@" and "];
            }
        } else if (i < people.count-1) {
            [s appendString:@", "];
        }
    }
    
    return s;
}

-(NSString*)composeNotes {
	NSMutableString *s = [NSMutableString string];
    [s appendFormat:@"%@\r\n",[self composeTitle]];

    NSString *text = [activity valueForKey:@"mainText"];
    if (text) {
        [s appendString:@"\r\n"];
        [s appendString:text];
        [s appendString:@"\r\n"];
    }

    for (int i=0;i<people.count;i++) {
        [s appendString:@"\r\n"];
        [s appendFormat:@"%@\r\n",[self nameForContact:i]];
        
        ABMutableMultiValueRef phones = ABRecordCopyValue([people objectAtIndex:i], kABPersonPhoneProperty);
        
        for(CFIndex x=0;x<ABMultiValueGetCount(phones);x++) {
            const NSString *label = (const NSString *)ABMultiValueCopyLabelAtIndex(phones,x);
            const NSString *value = (const NSString *)ABMultiValueCopyValueAtIndex(phones,x);
            if ([label isEqualToString:(NSString *)kABPersonPhoneMobileLabel]) {
                [s appendString:@"Mobile: "];
            } else if ([label isEqualToString:(NSString *)kABPersonPhoneMainLabel]) {
                [s appendString:@"Main: "];
            } else if ([label isEqualToString:(NSString *)kABPersonPhoneIPhoneLabel]) {
                [s appendString:@"iPhone: "];
            } else if ([label isEqualToString:(NSString *)kABPersonPhoneWorkFAXLabel]) {
                [s appendString:@"Work: "];
            } else {
                [s appendString:(NSString *)label];
                [s appendString:@": "];
            }
            
            [s appendString:(NSString *)value];
            [s appendString:@"\r\n"];

            [label release];
            [value release];
        }
        
        CFRelease(phones);
    }

	return s;
}

-(void) loadView {
	self.sectionKey = @"special";
    people = [[NSMutableArray alloc] init];
	[self loadViewFromContent];
    self.tableView.editing = TRUE;
    self.tableView.allowsSelectionDuringEditing = TRUE;
}

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
	return 2;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0) {
        if (indexPath.row == people.count) {
            return UITableViewCellEditingStyleInsert;
        } else {
            return UITableViewCellEditingStyleDelete;
        }
    }
    return UITableViewCellEditingStyleNone;
}

-(void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0) {
        if (indexPath.row == people.count) {
            [self addPerson];
        }
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0) {
        if (indexPath.row == people.count) {
            [self addPerson];
        } else {
            [people removeObjectAtIndex:indexPath.row];
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self setEnables];
        }
    }
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0) {
        if (indexPath.row == people.count) {
            cell.textLabel.text = @"Add a person";
            cell.shouldIndentWhileEditing = YES;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
        } else {
            cell.shouldIndentWhileEditing = NO;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.textLabel.text = [self nameForContact:indexPath.row];
        }
	} else {
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
		if (activity) {
			cell.textLabel.text = [activity valueForKey:@"displayName"];
		} else {
			cell.textLabel.text = @"Choose activity...";
		}
        cell.shouldIndentWhileEditing = NO;
	}
}

-(void) setEnables {
	scheduleItButton.enabled = people.count && activity;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return people.count + 1;
    }
	return 1;
}

- (void)eventEditViewController:(EKEventEditViewController *)controller didCompleteWithAction:(EKEventEditViewAction)action {
	[controller dismissModalViewControllerAnimated:TRUE];
	if (action == EKEventEditViewActionSaved) {
		[self.masterController buttonSelected:BUTTON_DONE];
	}
}

-(void) configureFromContent {
    hasActivities = [self getChildContentWithName:@"@activities"] != nil;
    hasContacts = [self getChildContentWithName:@"@contacts"] != nil;
	addressBook = ABAddressBookCreate();	

	BOOL isExercise = ([self.content getExtraInt:@"standalone"] == INT_MAX);

	[self baselineConfigureFromContent];
	
	CGRect bounds = [self.contentView bounds];
	CGRect tableFrame = bounds;
	tableFrame.origin.y += 10;
	if (isExercise) tableFrame.size.height -= 40;
//	tableFrame.size.height = 10;
	GTableView *table = [[GTableView alloc] initWithFrame:tableFrame style:UITableViewStyleGrouped];
	table.marginBottom = 15;
//	tableFrame.size.height = 10 + 32.0*(int)[self tableView:table numberOfRowsInSection:0];
//	table.frame = tableFrame;
	table.scrollEnabled = TRUE;
	[table setDelegate:self];
	[table setDataSource:self];
//	table.rowHeight = 32;
	table.opaque = FALSE;
	table.backgroundColor = [UIColor clearColor];	
	[self.contentView addSubview:table];
	tableView = table;
	headerDict = [[NSMutableDictionary alloc] init];
	
	self.dynamicView = tableView;
	self.dynamicView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.contentView.dynamicSubview = self.dynamicView;
	self.contentView.clipDynamicView = TRUE;
//	[contentView addSubview:dynamicView];
	
	
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSManagedObjectContext *context = [iStressLessAppDelegate instance].udManagedObjectContext;
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ContactReference" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"refID" ascending:NO],nil]];
	NSArray *a = contacts = [context executeFetchRequest:fetchRequest error:NULL];
	[fetchRequest release];
	
	[contacts retain];
	
	if (isExercise) {
		[self addThumbs];
        [self addNewToolButton];
		
		NSManagedObject *next = [self nextContent];
		if (next) {
			NSString *s = [next valueForKey:@"displayName"];
			if (!s) s = @"Begin Exercise";
			
			[self addButton:BUTTON_ADVANCE_EXERCISE withText:s];
		}
	}
	
	[self.tableView reloadData];
    NSManagedObject *next = [self getChildContentWithName:@"@scheduleIt"];
    if (next) {
        NSString *s = [next valueForKey:@"displayName"];
        scheduleItButton = [self addButton:BUTTON_ADVANCE_EXERCISE withText:s];
    } else {
        scheduleItButton = [self addButton:BUTTON_ADVANCE_EXERCISE withText:@"Schedule it"];
    }
	[scheduleItButton retain];
	scheduleItButton.enabled = FALSE;
	[self.scrollView setNeedsLayout];
}

-(void) buttonPressed:(UIButton *)button {
	if (button.tag == BUTTON_ADVANCE_EXERCISE) {
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
		[[iStressLessAppDelegate instance] presentModalViewController: evc animated: YES];
		[evc release];
		
		[eventStore release];
	}
}

-(NSString*) getSectionName:(int)section {
	return nil;
}

-(NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (section == 0) {
		return [[self getChildContentWithName:@"@contacts"] valueForKey:@"mainText"];
	} else if (section == 1) {
		return [[self getChildContentWithName:@"@activities"] valueForKey:@"mainText"];
	}
}

-(UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	UIView *v = [headerDict objectForKey:[NSNumber numberWithInt:section]];
	if (!v) {
		NSString *mainText = [self tableView:tableView titleForHeaderInSection:section];
		v = [self createLabel:mainText];
        UILabel* label = [[v subviews] objectAtIndex:0];
//        label.font = [UIFont fontWithName:[label.font fontName] size:[label.font pointSize]*0.8];
        CGRect r = v.frame;
		int offsetAmount = /*(section == 0) ? 0 :*/ 10;
		r.size.height += 5+offsetAmount;
		v.frame = r;
		r = ((UIView*)[v.subviews objectAtIndex:0]).frame;
		r.origin.y += offsetAmount;
		((UIView*)[v.subviews objectAtIndex:0]).frame = r;
		[headerDict setObject:v forKey:[NSNumber numberWithInt:section]];
	}
	
	return v;
}

-(CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	UIView *v = [self tableView:tableView viewForHeaderInSection:section];
	CGRect r = v.frame;
	return r.size.height;
}

-(void) contentLoaded {
	[self.tableView reloadData];
	[self.scrollView setNeedsLayout];
	[super contentLoaded];
}

-(void) addPerson {
    ABPeoplePickerNavigationController *picker = [[ABPeoplePickerNavigationController alloc] init];
    picker.peoplePickerDelegate = self;
    picker.addressBook = addressBook;
    [[iStressLessAppDelegate instance] presentModalViewController: picker animated: YES];
    [picker release];
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	int sections = [self fetchedResultsController].sections.count;
	if (indexPath.section == 0) {
        if (indexPath.row == people.count) {
            [self addPerson];
        } else {
            ABPersonViewController *personViewController = [[ABPersonViewController alloc] init];
            personViewController.addressBook = addressBook;
            personViewController.allowsEditing = TRUE;
            personViewController.personViewDelegate = self;
            personViewController.displayedPerson = [people objectAtIndex:indexPath.row]; // Assume person is already defined.
            [self.navigationController pushViewController:personViewController animated:YES];
            [personViewController release];
        }
	} else {
//		self.masterController.selectionDelegate = self;
		ContentViewController *cvc = [self getChildControllerWithName:@"@activities"];
		[self.navigationController pushViewController:cvc animated:TRUE];
	}
	
	[tableView deselectRowAtIndexPath:indexPath animated:TRUE];
}

- (void) managedObjectSelected:(NSManagedObject*)mo {
//	self.masterController.selectionDelegate = nil;
	activity = mo;
	[activity retain];
	[self setEnables];
	[self.navigationController popViewControllerAnimated:TRUE];
}

-(void) viewWillAppear:(BOOL)animated {
	[super viewWillAppear:(BOOL)animated];
//	self.masterController.selectionDelegate = nil;
}

-(void) dealloc {
	[tableView release];
	[people release];
	[contacts release];
	[headerDict release];
	[activity release];
	[scheduleItButton release];
	if (addressBook) CFRelease(addressBook);
	[super dealloc];
}

@end
#endif
