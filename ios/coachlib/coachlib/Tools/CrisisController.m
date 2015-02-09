//
//  RelaxationIntroController.m
//  iStressLess
//
//

#if 0
#import "CrisisController.h"
#import "NSManagedObject+MOExtensions.h"
#import "HorizontalLayout.h"
#import "iStressLessAppDelegate.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "ManageSymptomsNavController.h"
#import "GTableView.h"

#define BUTTON_DIAL_PREARRANGED_NUMBER 5000
#define BUTTON_CONTACT 10000

@implementation CrisisController
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

-(NSString*)checkPrerequisite {
	NSManagedObjectContext *context = [iStressLessAppDelegate instance].udManagedObjectContext;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ContactReference" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
	fetchRequest.returnsObjectsAsFaults = TRUE;
	if ([context countForFetchRequest:fetchRequest error:NULL] == 0) {
		return @"You haven't chosen any support contacts.  Go to Settings and choose some contacts before you can use this tool.";
	}
	
	return nil;
}

- (BOOL)personViewController:(ABPersonViewController *)personViewController shouldPerformDefaultActionForPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifierForValue {
	return TRUE;
}

-(NSString *)nameForContact:(NSManagedObject*)contact {
	NSManagedObject *managedObject = contact;
	NSNumber *refID = [managedObject valueForKey:@"refID"];
	ABRecordRef rec = ABAddressBookGetPersonWithRecordID(addressBook, [refID intValue]);
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
//			NSString *phoneNumber = ABRecordCopyValue(rec, kABPersonPhoneProperty);
}

-(void) loadView {
	self.sectionKey = @"special";
	[self loadViewFromContent];
}

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
	int num = [super numberOfSectionsInTableView:(UITableView *)tableView];
	return num;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
	if ([[self getSectionName:indexPath.section] isEqual:@"contacts"]) {
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		cell.textLabel.text = [self nameForContact:[contacts objectAtIndex:indexPath.row]];
	} else {
		NSManagedObject *managedObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
		cell.accessoryType = UITableViewCellAccessoryNone;
		cell.textLabel.text = [managedObject valueForKey:@"displayName"];
	}
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if ([[self getSectionName:section] isEqual:@"contacts"]) {
		return contacts.count;
	} else {
		return [super tableView:tableView numberOfRowsInSection:section];
	}
}

-(void) configureFromContent {
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
	[self.scrollView setNeedsLayout];

}

-(NSString*) getSectionName:(int)section {
	id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
	NSArray *a = [sectionInfo.name componentsSeparatedByString:@"|"];
	NSString* sectionName = (NSString*)[a lastObject];
	return sectionName;
}

-(UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	UIView *v = [headerDict objectForKey:[NSNumber numberWithInt:section]];
	if (!v) {
		NSString *sectionName = [self getSectionName:section];
        NSString *contentName = [NSString stringWithFormat:@"@%@",sectionName];
        if ([sectionName isEqualToString:@"contacts"] && !contacts.count) {
            contentName = [NSString stringWithFormat:@"@%@.none",sectionName];
        }
		NSManagedObject *o = [self getChildContentWithName:contentName];
		NSString *mainText = (NSString*)[o valueForKey:@"mainText"];
        if (mainText) {
            v = [self createLabel:mainText];
            CGRect r = v.frame;
            int offsetAmount = /*(section == 0) ? 0 :*/ 10;
            r.size.height += 5+offsetAmount;
            v.frame = r;
            r = ((UIView*)[v.subviews objectAtIndex:0]).frame;
            r.origin.y += offsetAmount;
            ((UIView*)[v.subviews objectAtIndex:0]).frame = r;
            [headerDict setObject:v forKey:[NSNumber numberWithInt:section]];
            return v;
        }
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

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//	int sections = [self fetchedResultsController].sections.count;
	if (![[self getSectionName:indexPath.section] isEqual:@"contacts"]) {
		int i = indexPath.section;
		NSArray *a = [self getChildContentList];
		Content *o = [a objectAtIndex:i];
		NSString *number = [o getExtraString:@"phoneNumber"];
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@",number]];
        [self visitLink:url];
	} else {
		NSManagedObject *managedObject = [contacts objectAtIndex:indexPath.row];
		NSNumber *refID = [managedObject valueForKey:@"refID"];
		ABRecordRef rec = ABAddressBookGetPersonWithRecordID(addressBook, [refID intValue]);
		ABPersonViewController *pvc = [[ABPersonViewController alloc] init];
		pvc.displayedPerson = rec;
		pvc.personViewDelegate = self;
		pvc.navigationItem.title = @"Get Support";
		[self.navigationController pushViewController:pvc animated:TRUE];
	}
	
	[tableView deselectRowAtIndexPath:indexPath animated:TRUE];
}

-(void) dealloc {
	[contacts release];
	[headerDict release];
	if (addressBook) CFRelease(addressBook);
	[super dealloc];
}

@end
#endif
