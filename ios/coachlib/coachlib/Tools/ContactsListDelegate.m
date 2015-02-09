//
//  RelaxationIntroController.m
//  iStressLess
//


//

#import "ContactsListDelegate.h"
#import "NSManagedObject+MOExtensions.h"
#import "HorizontalLayout.h"
#import "iStressLessAppDelegate.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import <EventKit/EventKit.h>
#import <EventKitUI/EventKitUI.h>
#import "ManageSymptomsNavController.h"
#import "GTableView.h"

@implementation ContactsListDelegate

@synthesize owner;

-(void) createTable:(boolean_t)editing {
    CGRect tableFrame;
    tableFrame.origin.x = tableFrame.origin.y = 0;
    tableFrame.size.width = 320;
    tableFrame.size.height = 100;
    GTableView *tv = [[[GTableView alloc] initWithFrame:tableFrame style:UITableViewStyleGrouped] autorelease];
    if ([iStressLessAppDelegate deviceMajorVersion] >= 7) {
        tv.contentInset = UIEdgeInsetsMake(-20, 0, 0, 0);
    }
    self.tableView = tv;
    tv.marginBottom = 10;
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    self.tableView.opaque = FALSE;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundView = nil;
    self.tableView.scrollEnabled = NO;
    self.tableView.editing = editing;
    self.tableView.allowsSelectionDuringEditing = editing;
    [self.tableView reloadData];
}

-(id) initWithStorageID:(NSString*)_storageID andAllowEditing:(BOOL)editing {
    self=[super init];
    addressBook = ABAddressBookCreate();
    NSArray *ids = nil;
    people = [[NSMutableArray alloc] init];
    if (_storageID) {
        storageID = _storageID;
        [storageID retain];
        NSString *list = [[iStressLessAppDelegate instance] getSetting:_storageID];
        ids = [list componentsSeparatedByString:@","];
        if (ids) {
            for (int i=0;i<[ids count];i++) {
                NSString *idAsString = [ids objectAtIndex:i];
                int recID = [idAsString intValue];
                if (recID) {
                    ABRecordRef rec = ABAddressBookGetPersonWithRecordID(addressBook, recID);
                    [people addObject:rec];
                } 
            }
        }
    }

    [self createTable:editing];
    return self;
}

-(id) initWithData:(NSString*)_value {
    self=[super init];
    addressBook = ABAddressBookCreate();
    NSArray *ids = nil;
    people = [[NSMutableArray alloc] init];
    ids = [_value componentsSeparatedByString:@","];
    if (ids) {
        for (int i=0;i<[ids count];i++) {
            NSString *idAsString = [ids objectAtIndex:i];
            int recID = [idAsString intValue];
            if (recID) {
                ABRecordRef rec = ABAddressBookGetPersonWithRecordID(addressBook, recID);
                [people addObject:rec];
            } 
        }
    }
    
    [self createTable:FALSE];
    return self;
}

-(id) initWithStorageID:(NSString*)_storageID {
    return [self initWithStorageID:_storageID andAllowEditing:true];
}

- (BOOL)personViewController:(ABPersonViewController *)personViewController shouldPerformDefaultActionForPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifierForValue {
	return TRUE;
}

- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker {
	[peoplePicker dismissModalViewControllerAnimated:TRUE];
}

-(void) maybeStoreSetting {
    if (storageID) {
        NSString *setting = [self composeSetting];
        [[iStressLessAppDelegate instance] setSetting:storageID to:setting];
    }
}

- (void)newPersonViewController:(ABNewPersonViewController *)newPersonViewController didCompleteWithNewPerson:(ABRecordRef)person {
    [people addObject:person];
    [self.tableView reloadData];
    [owner relayout];
	[newPersonViewController.navigationController dismissModalViewControllerAnimated:TRUE];
	[owner setEnables];
    [self maybeStoreSetting];
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier {
    [people addObject:person];
    [self.tableView reloadData];
    [owner relayout];
	[peoplePicker dismissModalViewControllerAnimated:TRUE];
	[owner setEnables];
    [self maybeStoreSetting];
	return NO;
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)_person {
    [people addObject:_person];
    [self.tableView reloadData];
    [owner relayout];
	[peoplePicker dismissModalViewControllerAnimated:TRUE];
	[owner setEnables];
    [self maybeStoreSetting];
	return NO;
}

-(NSString*)composeSetting {
	NSMutableString *s = [NSMutableString string];
    for (int i=0;i<people.count;i++) {
        ABRecordRef rec = [people objectAtIndex:i];
        ABRecordID recID = ABRecordGetRecordID(rec);
        [s appendFormat:@"%d",recID];
        if (i < people.count-1) {
            [s appendString:@","];
        }
    }
    
    return s;
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

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
   if (indexPath.row == people.count) {
        return UITableViewCellEditingStyleInsert;
    } else {
        return UITableViewCellEditingStyleDelete;
    }
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
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [owner performSelector:@selector(relayout) withObject:nil afterDelay:0.5];
            [owner setEnables];
            [self maybeStoreSetting];
        }
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 0) {
        ABPeoplePickerNavigationController *picker = [[ABPeoplePickerNavigationController alloc] init];
        picker.peoplePickerDelegate = self;
        picker.addressBook = addressBook;
        [[iStressLessAppDelegate instance] presentModalViewController: picker animated: YES];
        [picker release];
	} else {
		ABNewPersonViewController *creator = [[ABNewPersonViewController alloc] init];
		creator.newPersonViewDelegate = self;
		creator.addressBook = addressBook;
		UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:creator];
		[[iStressLessAppDelegate instance] presentModalViewController: nc animated: YES];
		[nc release];
		[creator release];
	}
}

- (void)addPerson {
	UIActionSheet *choice = [[UIActionSheet alloc] initWithTitle:@"Add Contact" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil 
											   otherButtonTitles:@"Pick from contact list", @"Create new contact", nil];
    CGRect r = [self.tableView rectForRowAtIndexPath:[NSIndexPath indexPathForRow:people.count inSection:0]];
    [choice showFromRect:r inView:self.tableView animated:YES];
	[choice release];
}

-(UITableViewCell *)createCell:(NSString*)typeIdentifier NS_RETURNS_RETAINED {
	return [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:typeIdentifier];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
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
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[self createCell:CellIdentifier] autorelease];
    }
    
    // Configure the cell.
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return people.count + (tableView.editing ? 1 : 0);
}

- (void)eventEditViewController:(EKEventEditViewController *)controller didCompleteWithAction:(EKEventEditViewAction)action {
	[controller dismissModalViewControllerAnimated:TRUE];
	if (action == EKEventEditViewActionSaved) {
		[owner goBack];
	}
}

-(NSString*) getSectionName:(int)section {
	return nil;
}

-(NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return nil;
}

-(UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	return nil;
}

-(CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 0;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == people.count) {
        [self addPerson];
    } else {
        ABPersonViewController *personViewController = [[ABPersonViewController alloc] init];
        personViewController.addressBook = addressBook;
        personViewController.allowsEditing = TRUE;
        personViewController.personViewDelegate = self;
        personViewController.displayedPerson = [people objectAtIndex:indexPath.row]; // Assume person is already defined.
        [owner.navigationController pushViewController:personViewController animated:YES];
        [personViewController release];
    }
	
	[tableView deselectRowAtIndexPath:indexPath animated:TRUE];
}

-(void) dealloc {
	[people release];
	[contacts release];
	[headerDict release];
    [storageID release];
	if (addressBook) CFRelease(addressBook);
	[super dealloc];
}

@end
