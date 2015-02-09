//
//  ChoosenAudioListViewController.m
//  iStressLess
//


//

#import "ChosenContactListViewController.h"
#import "iStressLessAppDelegate.h"
#import "SelectionCell.h"

@implementation ChosenContactListViewController

- (NSManagedObjectContext*)managedObjectContext {
    if (_tempContext) return _tempContext;

    if (_picking) {
        NSPersistentStoreCoordinator *psc = [iStressLessAppDelegate instance].tempPersistentStoreCoordinator;
        _tempContext = [[[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType] retain];
        _tempStore = [[psc addPersistentStoreWithType:NSInMemoryStoreType configuration:nil URL:nil options:nil error:NULL] retain];
        [_tempContext setPersistentStoreCoordinator:psc];
        return _tempContext;
    }

	return [iStressLessAppDelegate instance].udManagedObjectContext;
}

-(NSString*)composeValue {
    int count = [[self.fetchedResultsController.sections objectAtIndex:0] numberOfObjects];
	NSMutableString *s = [NSMutableString string];
    for (int i=0;i<count;i++) {
        NSManagedObject *person = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        int refID = [[person valueForKey:@"refID"] intValue];
        [s appendFormat:@"%d",refID];
        if (i < count-1) {
            [s appendString:@","];
        }
    }
    
    return s;
}

-(void) saveIfNeeded {
    if (!_tempContext) {
        [[self managedObjectContext] save:NULL];
    } else {
        NSString *varBinding = [self.content getExtraString:@"variableKey"];
        if (varBinding) {
            [self setVariable:varBinding to:[self composeValue]];
        }
    }
}

-(void)physicianToggle:(UIButton *)button {
    NSManagedObject *contactObj = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:button.tag inSection:0]];
    if (button.selected) {
        [contactObj setValue:[NSNumber numberWithBool:FALSE] forKey:@"preferred"];
        [[iStressLessAppDelegate instance] setSetting:@"preferredContactSet" to:nil];
        [self saveIfNeeded];
        button.selected = FALSE;
    } else {
        NSFetchRequest *req = [NSFetchRequest fetchRequestWithEntityName:@"ContactReference"];
        req.predicate = [NSPredicate predicateWithFormat:@"preferred == TRUE"];
        NSArray *a = [[iStressLessAppDelegate instance].udManagedObjectContext executeFetchRequest:req error:NULL];
        for (NSManagedObject *o in a) {
            [o setValue:[NSNumber numberWithBool:FALSE] forKey:@"preferred"];
        }
        [contactObj setValue:[NSNumber numberWithBool:TRUE] forKey:@"preferred"];
        [[iStressLessAppDelegate instance] setSetting:@"preferredContactSet" to:@"true"];
        [self saveIfNeeded];
        button.selected = TRUE;
    }
}

-(UITableViewCell *)createCell:(NSString*)typeIdentifier NS_RETURNS_RETAINED {
    NSString *selectionIconName = [self.content getExtraString:@"selectionIcon_file"];
    if (selectionIconName) {
        NSArray *a = [[NSBundle mainBundle] loadNibNamed:@"SelectionCell" owner:self options:nil];
        SelectionCell *cell = [[a objectAtIndex:0] retain];
        NSString *selectionIconEmptyName = [self.content getExtraString:@"selectionIconEmpty_file"];
        UIImage *selectionIcon = [Content imageNamed:selectionIconName];
        UIImage *selectionIconEmpty = selectionIconEmptyName ? [Content imageNamed:selectionIconEmptyName] : nil;
        [cell.selectionButton setImage:selectionIconEmpty forState:UIControlStateNormal];
        [cell.selectionButton setImage:selectionIcon forState:UIControlStateSelected];
        [cell.selectionButton addTarget:self action:@selector(physicianToggle:) forControlEvents:UIControlEventTouchUpInside];
        return cell;
    } else {
        return [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"default"];
    }
}

-(void) viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	if (!firstTimeDisplayed) {
		firstTimeDisplayed = TRUE;
		if (self.tableView.editing && [self tableView:self.tableView numberOfRowsInSection:0] == 0) {
			[self addContactReference];
		}
	}
}

- (ABRecordRef)queryForContact:(NSManagedObject*)contactObject {
    NSNumber *refID = [contactObject valueForKey:@"refID"];
	ABRecordRef ref = ABAddressBookGetPersonWithRecordID(addressBook, [refID intValue]);
	return ref;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    int row = indexPath.row;
    int count = [[self.fetchedResultsController.sections objectAtIndex:indexPath.section] numberOfObjects];
    if (row >= count) {
        if (self.isInlineContent) {
            cell.textLabel.text = @"Add a person";
            cell.shouldIndentWhileEditing = YES;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        return;
    }
    NSManagedObject *managedObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
	ABRecordRef rec = [self queryForContact:managedObject];
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
    if ([cell isKindOfClass:[SelectionCell class]]) {
        SelectionCell *scell = (SelectionCell*)cell;
        scell.selectionButton.selected = [((NSNumber*)[managedObject valueForKey:@"preferred"]) boolValue];
        scell.selectionButton.tag = indexPath.row;
        scell.titleLabel.text = text;
    } else {
        cell.textLabel.text = text;
    }
}

/*
if (!tableView.isEditing) {
    NSString *number = [selectedObject getExtraString:@"phoneNumber"];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@",number]];
    [self visitLink:url];
    return;
}
*/

-(BOOL)personViewController:(ABPersonViewController *)personViewController shouldPerformDefaultActionForPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier {
    return FALSE;
}

- (void) tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath {
    int row = indexPath.row;
    int count = [[self.fetchedResultsController.sections objectAtIndex:indexPath.section] numberOfObjects];
    if (row >= count) {
        [self addContactReference];
        return;
    }

    NSManagedObject *selectedObject = [[self fetchedResultsController] objectAtIndexPath:indexPath];
	const ABRecordRef *person = [self queryForContact:selectedObject];
	ABPersonViewController *personViewController = [[ABPersonViewController alloc] init];
	personViewController.addressBook = addressBook;
	personViewController.allowsEditing = TRUE;
	personViewController.personViewDelegate = self;
	personViewController.displayedPerson = person;
/*
    UIView *firstView = [[personViewController.view subviews] objectAtIndex:0];
    if ([firstView isKindOfClass:[UITableView class]]) {
        UITableView *tv = (UITableView*)firstView;
        tv.backgroundColor = [self backgroundColorToUse];
        tv.backgroundView = [self backgroundViewToUse];
    }
*/
	[self.navigationController pushViewController:personViewController animated:YES];
	[personViewController release];
    [tableView deselectRowAtIndexPath: indexPath animated: YES];
}

-(void) addPerson:(ABRecordRef)person {
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
	NSNumber *number = [NSNumber numberWithInt:ABRecordGetRecordID(person)];
	NSManagedObject *newContact = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
    if (_tempStore) [context assignObject:newContact toPersistentStore:_tempStore];
	[newContact setValue:number forKey:@"refID"];
    [self saveIfNeeded];
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person {
	[self addPerson:person];
	[peoplePicker dismissModalViewControllerAnimated:TRUE];
	return FALSE;
}

- (void)newPersonViewController:(ABNewPersonViewController *)newPersonViewController didCompleteWithNewPerson:(ABRecordRef)person {
	if (person) [self addPerson:person];
	[newPersonViewController.navigationController dismissModalViewControllerAnimated:TRUE];
}

-(void) peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker {
	[peoplePicker dismissModalViewControllerAnimated:TRUE];
 }

-(BOOL) peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
	[peoplePicker dismissModalViewControllerAnimated:TRUE];
	return TRUE;
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 0) {
		ABPeoplePickerNavigationController *picker = [[ABPeoplePickerNavigationController alloc] init];
		picker.peoplePickerDelegate = self;
		picker.addressBook = addressBook;
		[[iStressLessAppDelegate instance] presentModalViewController: picker animated: YES];
		[picker release];
	} else if (buttonIndex == 1) {
		ABNewPersonViewController *creator = [[ABNewPersonViewController alloc] init];
		creator.newPersonViewDelegate = self;
		creator.addressBook = addressBook;
		UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:creator];
		[[iStressLessAppDelegate instance] presentModalViewController: nc animated: YES];
		[nc release];
		[creator release];
	}
}

- (void)addContactReference {
	UIActionSheet *choice = [[UIActionSheet alloc] initWithTitle:@"Add Contact" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil
											   otherButtonTitles:@"Pick from contact list", @"Create new contact", nil];
    if (self.navigationItem.rightBarButtonItem) {
        [choice showFromBarButtonItem:self.navigationItem.rightBarButtonItem animated:TRUE];
    } else {
        int lastRow = [[self.fetchedResultsController.sections objectAtIndex:0] numberOfObjects];
        UIView *windowView = self.view.window.rootViewController.view;
        CGRect r = [self.tableView rectForRowAtIndexPath:[NSIndexPath indexPathForRow:lastRow inSection:0]];
        r = [windowView convertRect:r fromView:self.tableView];
        [choice showFromRect:r inView:windowView animated:TRUE];
    }
	[choice release];
}

- (void)loadView {
	addressBook = ABAddressBookCreate();
	[super loadView];
//	self.tableView.rowHeight = 50;
}
        
- (UITableView*) createTableView {
    UITableView* tv = [super createTableView];
    _picking = [self.content getExtraBoolean:@"pick"];
    if ((_picking && self.isInlineContent) || [[self.content getExtraString:@"editing"] isEqualToString:@"true"]) {
        tv.editing = TRUE;
        tv.allowsSelectionDuringEditing = TRUE;
        if (!self.isInlineContent) {
            self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addContactReference)] autorelease];
        }
    }
    return tv;
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [super controllerDidChangeContent:controller];
    if (!_picking) {
        [[iStressLessAppDelegate instance] setSetting:@"contactsCount" to:[NSString stringWithFormat:@"%d",[[controller.sections objectAtIndex:0] numberOfObjects]]];
    } else {
        [self saveIfNeeded];
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    int row = indexPath.row;
    int count = [[self.fetchedResultsController.sections objectAtIndex:indexPath.section] numberOfObjects];
    if (row >= count) {
        if (self.isInlineContent) {
            return UITableViewCellEditingStyleInsert;
        }
    }

    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleInsert) {
        [self addContactReference];
        return;
    }
    [super tableView:tableView commitEditingStyle:editingStyle forRowAtIndexPath:indexPath];
    [self saveIfNeeded];
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [super tableView:tableView numberOfRowsInSection:section] + (([self isInlineContent] && tableView.editing) ? 1 : 0);
}

- (NSFetchedResultsController *)createFetchedResultsController {
    /*
     Set up the fetched results controller.
	 */
	
	// Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ContactReference" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchBatchSize:20];
    
    NSString *show = [self.content getExtraString:@"show"];
    if (show) {
        if ([show isEqualToString:@"preferredOnly"]) {
            fetchRequest.predicate = [NSPredicate predicateWithFormat:@"preferred==true"];
        } else if ([show isEqualToString:@"nonPreferredOnly"]) {
            fetchRequest.predicate = [NSPredicate predicateWithFormat:@"preferred==false or preferred==nil"];
        }
    }
	
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"refID" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor1, nil];    
    [fetchRequest setSortDescriptors:sortDescriptors];

    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    aFetchedResultsController.delegate = self;

    [fetchRequest release];
    [sortDescriptor1 release];
    [sortDescriptors release];

    NSError *error = nil;
    if (![aFetchedResultsController performFetch:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return aFetchedResultsController;
}    

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.tableView.editing;
}

- (void)viewDidLoad {
	[super viewDidLoad];
}

-(void) viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:(BOOL)animated];
}

- (void)dealloc {
	CFRelease(addressBook);
    [_tempContext release];
    if (_tempStore) {
        [[iStressLessAppDelegate instance].tempPersistentStoreCoordinator removePersistentStore:_tempStore error:NULL];
        [_tempStore release];
    }
    [super dealloc];
}


@end

