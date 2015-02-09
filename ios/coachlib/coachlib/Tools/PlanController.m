//
//  RelaxationIntroController.m
//  iStressLess
//

//

#import "PlanController.h"
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
#define BUTTON_SCHEDULE_IT 20000

@implementation PlanController
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

-(NSString*)composeSetting {
	NSMutableString *s = [NSMutableString string];
    for (int i=0;i<self.people.count;i++) {
        ABRecordRef rec = [self.people objectAtIndex:i];
        ABRecordID recID = ABRecordGetRecordID(rec);
        [s appendFormat:@"%d",recID];
        if (i < self.people.count-1) {
            [s appendString:@","];
        }
    }
    
    return s;
}

-(NSString *)nameForContact:(int)index {
    ABRecordRef rec = [self.people objectAtIndex:index];
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
	[s appendFormat:@"%@ with ",[self.activity valueForKey:@"displayName"]];
    
    for (int i=0;i<self.people.count;i++) {
        [s appendFormat:@"%@",[self nameForContact:i]];
        if (i == self.people.count-2) {
            if (self.people.count > 2) {
                [s appendString:@", and "];
            } else {
                [s appendString:@" and "];
            }
        } else if (i < self.people.count-1) {
            [s appendString:@", "];
        }
    }
    
    return s;
}

-(NSString*)composeNotes {
	NSMutableString *s = [NSMutableString string];
    [s appendFormat:@"%@\r\n",[self composeTitle]];

    NSString *text = [self.activity valueForKey:@"mainText"];
    if (text) {
        [s appendString:@"\r\n"];
        [s appendString:text];
        [s appendString:@"\r\n"];
    }

    for (int i=0;i<self.people.count;i++) {
        [s appendString:@"\r\n"];
        [s appendFormat:@"%@\r\n",[self nameForContact:i]];
        
        ABMutableMultiValueRef phones = ABRecordCopyValue([self.people objectAtIndex:i], kABPersonPhoneProperty);
        
        for(CFIndex x=0;x<ABMultiValueGetCount(phones);x++) {
            NSString *label = (NSString *)ABMultiValueCopyLabelAtIndex(phones,x);
            NSString *value = (NSString *)ABMultiValueCopyValueAtIndex(phones,x);
            if ([label isEqualToString:(NSString *)kABPersonPhoneMobileLabel]) {
                [s appendString:@"Mobile: "];
            } else if ([label isEqualToString:(NSString *)kABPersonPhoneMainLabel]) {
                [s appendString:@"Main: "];
            } else if ([label isEqualToString:(NSString *)kABPersonPhoneIPhoneLabel]) {
                [s appendString:@"iPhone: "];
            } else if ([label isEqualToString:(NSString *)kABPersonPhoneWorkFAXLabel]) {
                [s appendString:@"Work: "];
            } else {
                [s appendString:label];
                [s appendString:@": "];
            }
            
            [s appendString:value];
            [s appendString:@"\r\n"];

            [label release];
            [value release];
        }
        
        CFRelease(phones);
    }

	return s;
}

-(void)navigateToNext {
    NSString *contactsStr = (NSString*)[self.masterController getVariable:@"socialActivitySummaryContactList"];
    self.people = [NSMutableArray array];
    NSArray *ids = [contactsStr componentsSeparatedByString:@","];
    if (ids) {
        for (int i=0;i<[ids count];i++) {
            NSString *idAsString = [ids objectAtIndex:i];
            int recID = [idAsString intValue];
            if (recID) {
                ABRecordRef rec = ABAddressBookGetPersonWithRecordID([iStressLessAppDelegate instance].sharedAddressBook, recID);
                [self.people addObject:rec];
            }
        }
    }
    
    if (!self.people.count) {
        [UIAlertView alertViewWithTitle:@"No contact selected" message:@"Please select some people to make plans with."];
        return;
    }
    
    if (!self.activity) {
        [UIAlertView alertViewWithTitle:@"No activity selected" message:@"Please select an activity."];
        return;
    }

    [self setVariable:@"socialActivitySummary" to:[self composeTitle]];
    [self setVariable:@"socialTitle" to:[self composeTitle]];
    [self setVariable:@"socialNotes" to:[self composeNotes]];

    [super navigateToNext];
}

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleNone;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
    if (self.activity) {
        cell.textLabel.text = [self.activity valueForKey:@"displayName"];
    } else {
        cell.textLabel.text = @"Choose activity...";
    }
    cell.shouldIndentWhileEditing = NO;
}

-(UITableView *)createTableView {
    GTableView *tv = (GTableView*)[super createTableView];
    tv.marginBottom = 10;
    return tv;
}

-(void) maybeStoreSetting {
    NSString *storeAs = [self.content getExtraString:@"storeAs"];
    if (storeAs) {
        NSString *setting = [self composeSetting];
        [[iStressLessAppDelegate instance] setSetting:storeAs to:setting];
    }
}

-(void) setEnables {
	scheduleItButton.enabled = self.people.count && self.activity;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 1;
}

- (void)eventEditViewController:(EKEventEditViewController *)controller didCompleteWithAction:(EKEventEditViewAction)action {
	[controller dismissModalViewControllerAnimated:TRUE];
	if (action == EKEventEditViewActionSaved) {
//		[self.masterController buttonSelected:BUTTON_DONE];
	}
}

-(void) configureFromContent {
    [self clearVariable:@"socialActivitySummaryContactList"];
    [self clearVariable:@"socialActivity"];
    [super configureFromContent];
    [self addButtonWithText:@"Next" callingBlock:^{
        [self navigateToNext];
    }];

/*
	self.sectionKey = @"special";
    people = [[NSMutableArray alloc] init];
    
    hasActivities = [self getChildContentWithName:@"@activities"] != nil;
    hasContacts = [self getChildContentWithName:@"@contacts"] != nil;
	addressBook = ABAddressBookCreate();	

	BOOL isExercise = ([self.content getExtraInt:@"standalone"] == INT_MAX);
	NSString *storeAs = [self.content getExtraString:@"storeAs"];

	[self configureFromContent];
	
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
	self.tableView = table;
	headerDict = [[NSMutableDictionary alloc] init];
    
    self.tableView.editing = TRUE;
    self.tableView.allowsSelectionDuringEditing = TRUE;
	
	self.dynamicView = self.tableView;
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
		
		NSManagedObject *next = [self nextContent];
		if (next) {
			NSString *s = [next valueForKey:@"displayName"];
			if (!s) s = @"Begin Exercise";
			
			[self addButton:BUTTON_ADVANCE_EXERCISE withText:s];
		}
	}
	
    if (storeAs) {
        NSString *list = [[iStressLessAppDelegate instance] getSetting:storeAs];
        if (list) {
            NSArray *ids = [list componentsSeparatedByString:@","];
            for (int i=0;i<[ids count];i++) {
                NSString *idAsString = [ids objectAtIndex:i];
                ABRecordRef rec = ABAddressBookGetPersonWithRecordID(addressBook, [idAsString intValue]);
                [people addObject:rec];
//                [rec release];
            }
        }
    }
    
	[self.tableView reloadData];
    NSManagedObject *next = [self getChildContentWithName:@"@scheduleIt"];
    if (next) {
        NSString *s = [next valueForKey:@"displayName"];
        scheduleItButton = [self addButton:BUTTON_SCHEDULE_IT withText:s];
        [scheduleItButton retain];
        scheduleItButton.enabled = FALSE;
//    } else {
//        scheduleItButton = [self addButton:BUTTON_SCHEDULE_IT withText:@"Schedule it"];
    }
	[self.scrollView setNeedsLayout];
*/ 
}
/*
-(void) buttonPressed:(UIButton *)button {
	if (button.tag == BUTTON_SCHEDULE_IT) {
        NSManagedObject *next = [self getChildContentWithName:@"@scheduleIt"];
        if (next) {
            [self setVariable:@"socialActivitySummary" to:[self composeTitle]];
            [self setVariable:@"socialContacts" to:[self composeSetting]];
            [self setVariable:@"socialTitle" to:[self composeTitle]];
            [self setVariable:@"socialNotes" to:[self composeNotes]];
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
/*
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
 */
/*
-(UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	UIView *v = [headerDict objectForKey:[NSNumber numberWithInt:section]];
	if (!v) {
		NSString *sectionName = [self getSectionName:section];
		NSString *mainText = [self tableView:tableView titleForHeaderInSection:section];
		v = [self createLabel:mainText];
        UILabel* label = [[v subviews] objectAtIndex:0];
//        label.font = [UIFont fontWithName:[label.font fontName] size:[label.font pointSize]*0.8];
        CGRect r = v.frame;
		int offsetAmount =  10;
		r.size.height += 5+offsetAmount;
		v.frame = r;
		r = ((UIView*)[v.subviews objectAtIndex:0]).frame;
		r.origin.y += offsetAmount;
		((UIView*)[v.subviews objectAtIndex:0]).frame = r;
		[headerDict setObject:v forKey:[NSNumber numberWithInt:section]];
	}
	
	return v;
}
*//*
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
*/

-(void)contentBecameVisible {
    [super contentBecameVisible];
    self.activity = (NSManagedObject*)[self getVariable:@"socialActivity"];
	[self setEnables];
    [self.tableView reloadData];
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ContentViewController *cvc = [self getChildControllerWithName:@"@activities"];
    [self navigateToNext:cvc];
	[tableView deselectRowAtIndexPath:indexPath animated:TRUE];
}

-(void) viewWillAppear:(BOOL)animated {
	[super viewWillAppear:(BOOL)animated];
//	self.masterController.selectionDelegate = nil;
}

-(void) dealloc {
	[contacts release];
	[headerDict release];
	[scheduleItButton release];
	[super dealloc];
}

@end

