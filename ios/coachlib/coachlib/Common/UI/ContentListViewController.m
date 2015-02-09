//
//  RootViewController.m
//  iStressLess
//


//

#import "ContentListViewController.h"
#import "ContentViewController.h"
#import "iStressLessAppDelegate.h"
#import "GTableView.h"
#import "ThemeManager.h"
#import "LayoutableProxyView.h"

@interface ContentListViewController ()
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@end


@implementation ContentListViewController

@synthesize fetchedResultsController=fetchedResultsController_;
@synthesize sectionKey,hideSingleSectionHeader,cellLines;

- (NSManagedObjectContext*)managedObjectContext {
	return [iStressLessAppDelegate instance].managedObjectContext; 
}

#pragma mark -
#pragma mark View lifecycle

-(void) configureMetaContent {
    ThemeManager *theme = [ThemeManager sharedManager];
	[super configureMetaContent];
	cellHeight = [self.content getExtraInt:@"cellHeight"];
	cellLines = [self.content getExtraInt:@"cellLines"];
    self.backgroundColor = [theme colorForName:@"backgroundColor"];
	NSString *s = [self.content getExtraString:@"selectOnly"];
	if (s && [s isEqualToString:@"true"]) {
		selectOnly = TRUE;
	}
	if (cellHeight != INT_MAX) {
		self.tableView.rowHeight = cellHeight;
	}
}

-(Class) tableViewClass {
    return [GTableView class];
}

-(BOOL)tableHasSections {
    return [self.content getExtraString:@"sectionKey"];
}
    
-(UITableView*) createTableView {
	CGRect r = [[UIScreen mainScreen] bounds];
    UITableViewStyle style = UITableViewStyleGrouped;
    
	UITableView *tv = [[[self tableViewClass] alloc] initWithFrame:r style:style];
    tv.separatorColor = [UIColor clearColor];
    tv.separatorStyle = UITableViewCellSeparatorStyleNone;
	tv.delegate = self;
	tv.dataSource = self;
    if (!self.isInlineContent && !interior) {
        if ([iStressLessAppDelegate deviceMajorVersion] >= 7) {
            if (![self tableHasSections]) {
                tv.contentInset = UIEdgeInsetsMake(-35, 0, -37, 0);
            } else {
                tv.contentInset = UIEdgeInsetsMake(0, 0, -37, 0);
            }
        } else {
            tv.contentInset = UIEdgeInsetsMake(0, 0, -15, 0);
        }
        UIView *bgView = [self backgroundViewToUse];
        if (bgView) {
            tv.backgroundView = bgView;
            tv.opaque = TRUE;
        } else {
            tv.backgroundView = nil;
            tv.backgroundColor = [self backgroundColorToUse];
            tv.opaque = TRUE;
        }
    } else {
        if ([iStressLessAppDelegate deviceMajorVersion] >= 7) {
            tv.contentInset = UIEdgeInsetsMake(-20, 0, 0, 0);
        }
        tv.backgroundView = nil;
        tv.backgroundColor = 0;
        tv.opaque = FALSE;
        tv.scrollEnabled = FALSE;
    }
    
    self.tableView = tv;
    return tv;
}

-(BOOL) hasNonListContent {
    return self.content.mainText || [self.content getChildrenByName:@"@inline"].count;
}

-(void) configureFromContent {
    NSString *_sectionKey = [self.content getExtraString:@"sectionKey"];
    if (_sectionKey && !self.sectionKey) self.sectionKey = _sectionKey;
    
    if ([self hasNonListContent]) {
        [super configureFromContent];
        UITableView *tv = [self createTableView];
        [dynamicView addSubview:tv];
        [tv release];
    } else {
        NSString *onload = [self.content getExtraString:@"onload"];
        if (onload) {
            [self runJS:onload];
        }
        [self configureMetaContent];
    }
    
    Content *headerContent = [self.content getChildByName:@"@header"];
    if (headerContent) {
        ContentViewController *cvc = headerContent.getViewController;
        cvc.masterController = self;
        cvc.isInlineContent = TRUE;
        [self addChildViewController:cvc];
        [self addChildContentController:cvc];
        LayoutableProxyView *lpv = [[[LayoutableProxyView alloc] init] autorelease];
        lpv.proxyUp = self.tableView;
        self.headerView = lpv;
        [lpv addSubview:[cvc view]];
        [self.headerView setToPreferredHeight];
        self.tableView.tableHeaderView = self.headerView;
        UIEdgeInsets insets = self.tableView.contentInset;
        insets.top = 0;
        self.tableView.contentInset = insets;
    }
    
}

- (void)loadView {
    ThemeManager *theme = [ThemeManager sharedManager];
    NSString *fontName = [theme stringForName:@"listTextFont"];
    float fontSize = [theme floatForName:@"listTextSize"];
    self.listFont = [UIFont fontWithName:fontName size:fontSize];

    interior = FALSE;
    if ([self hasNonListContent]) {
        interior = TRUE;
        [super loadView];
    } else {
        topView = [self createTableView];
        self.view = topView;
        [self configureFromContent];
    }
}


-(void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:(BOOL)animated];
	if (self.tableView.scrollEnabled) [self.tableView flashScrollIndicators];
}

- (void)viewDidLoad {
    [super viewDidLoad];
/*
    // Set up the edit and add buttons.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject)];
    self.navigationItem.rightBarButtonItem = addButton;
    [addButton release];
*/
}


// Implement viewWillAppear: to do additional setup before the view is presented.
- (void)viewWillAppear:(BOOL)animated {
    if (self.headerView) {
        [self.headerView setToPreferredHeight];
        self.tableView.tableHeaderView = self.headerView;
    }
    [super viewWillAppear:animated];
	[self.tableView reloadData];
}


/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
*/

/*
 // Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
 */


- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    NSManagedObject *managedObject = [self managedObjectForIndexPath:indexPath];
	cell.accessoryType = selectOnly ? UITableViewCellAccessoryNone : UITableViewCellAccessoryDisclosureIndicator;
	
    ThemeManager *theme = [ThemeManager sharedManager];
	NSString *fontName = [theme stringForName:@"listTextFont"];
	float fontSize = [theme floatForName:@"listTextSize"];
	UIColor *textColor = [theme colorForName:@"listTextColor"];
	UIColor *bgColor = [theme colorForName:@"listBackgroundColor"];

	cell.textLabel.textColor = textColor;
	cell.backgroundColor = bgColor;
    cell.textLabel.text = [managedObject valueForKey:@"displayName"];
    cell.textLabel.minimumFontSize = fontSize*2/3;
    cell.textLabel.font = [UIFont fontWithName:fontName size:fontSize];
    cell.textLabel.adjustsFontSizeToFitWidth = TRUE;
    cell.textLabel.numberOfLines = 1;
	if (self.cellLines != INT_MAX) {
		cell.textLabel.numberOfLines = cellLines;
	}
    cell.accessibilityTraits = UIAccessibilityTraitButton;
}

/*
#pragma mark -
#pragma mark Add a new object

- (void)insertNewObject {
    
    // Create a new instance of the entity managed by the fetched results controller.
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
    NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
    
    // If appropriate, configure the new managed object.
//    [newManagedObject setValue:[NSDate date] forKey:@"timeStamp"];
    
    // Save the context.
    NSError *error = nil;
    if (![context save:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
}
*/

#pragma mark -
#pragma mark Table view data source

- (NSManagedObject*)managedObjectForIndexPath:(NSIndexPath*)indexPath {
    NSManagedObject *managedObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
    return managedObject;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (section > [self numberOfSectionsInTableView:tableView]-1) return 0;
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    int count = [sectionInfo numberOfObjects];
	return count;
}

-(NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (hideSingleSectionHeader && ([self numberOfSectionsInTableView:tableView] <= 1)) return nil;

	if (section > [self.fetchedResultsController sections].count-1) return nil;
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
	NSArray *a = [sectionInfo.name componentsSeparatedByString:@"|"];
	return [a lastObject];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (hideSingleSectionHeader && ([self numberOfSectionsInTableView:tableView] <= 1)) return nil;
    if ([self numberOfSectionsInTableView:tableView] == 0) return nil;
    
    NSString *header = [self tableView:tableView titleForHeaderInSection:section];
    if (!header) return nil;
    if ([header length] == 0) return nil;

    ThemeManager *theme = [ThemeManager sharedManager];
	UIColor *textColor = [theme colorForName:@"textColor"];

    UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
    l.text = [NSString stringWithFormat:@"  %@",header];
	l.backgroundColor = [UIColor clearColor];
    l.opaque = FALSE;
    l.textColor = textColor;
    l.font = [UIFont fontWithName:@"Helvetica-Bold" size:17];
    
    [l autorelease];
    return l;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (hideSingleSectionHeader && ([self numberOfSectionsInTableView:tableView] <= 1)) return 0;
    if ([self numberOfSectionsInTableView:tableView] == 0) return 0;
    NSString *header = [self tableView:tableView titleForHeaderInSection:section];
    if (!header || ([header length] == 0)) return 0;
    return 40;
}

-(UITableViewCell *)createCell:(NSString*)typeIdentifier NS_RETURNS_RETAINED {
	UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:typeIdentifier];
    CGRect r = cell.frame;
    r.origin.y = r.size.height-1;
    r.size.height = 1;
    UIView *separator = [[UIView alloc] initWithFrame:r];
    separator.backgroundColor = self.backgroundColor;
    separator.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    cell.autoresizesSubviews = TRUE;
    [cell addSubview:separator];
    [separator release];
    return cell;
}

// Customize the appearance of table view cells.
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

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the managed object for the given index path
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
        
        // Save the context.
        NSError *error = nil;
        if (![context save:&error]) {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }   
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return FALSE;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // The table view should not be re-orderable.
    return NO;
}

- (void) configureContentViewController:(ContentViewController*)contentController {
    NSString *mainText = [contentController.content valueForKey:@"mainText"];
	if (mainText) [contentController addHTMLText:mainText];
	NSString * title = [contentController.content valueForKey:@"title"];
	if (!title) title = [contentController.content valueForKey:@"displayName"];
	contentController.navigationItem.title = title;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSManagedObject *selectedObject = [self managedObjectForIndexPath:indexPath];

	[tableView deselectRowAtIndexPath:(NSIndexPath *)indexPath animated:TRUE];
    [self managedObjectSelected:selectedObject];
}


#pragma mark -
#pragma mark Fetched results controller

- (NSFetchedResultsController *)createFetchedResultsController {
    /*
     Set up the fetched results controller.
	 */
	
	// Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Content" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchBatchSize:20];
	[fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"parent == %@ AND NOT name BEGINSWITH %@",self.content,@"@"]];
	
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES];
    NSSortDescriptor *sortDescriptor2 =  nil;
    NSArray *sortDescriptors = nil;
	
	NSString *sectionKeyToUse = nil;
	if (sectionKey != nil) sectionKeyToUse = [NSString stringWithFormat:@"%@",sectionKey];
	
	if (sectionKey == nil) {
		sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor1, nil];    
	} else {
		sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:[NSString stringWithFormat:@"%@",sectionKey] ascending:YES];
		sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor2, sortDescriptor1, nil];    
	}
    [fetchRequest setSortDescriptors:sortDescriptors];
	
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.content.managedObjectContext sectionNameKeyPath:sectionKeyToUse cacheName:nil];
    aFetchedResultsController.delegate = self;

//    NSArray *a = [NSArray arrayWithArray:[self.managedObjectContext executeFetchRequest:fetchRequest error:NULL]];
    
    [fetchRequest release];
    [sortDescriptor1 release];
    [sortDescriptor2 release];
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

- (NSFetchedResultsController *)fetchedResultsController {
    
    if (fetchedResultsController_ == nil) {
		fetchedResultsController_ = [self createFetchedResultsController];
        fetchedResultsController_.delegate = self;
    }
	
	return fetchedResultsController_;
}    


#pragma mark -
#pragma mark Fetched results controller delegate


- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self willChangeValueForKey:@"badgeValue"];
//    [self.tableView beginUpdates];
}
/*
- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = self.tableView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}
*/
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
//    [self.tableView endUpdates];
    [self.tableView reloadData];
    [self didChangeValueForKey:@"badgeValue"];
}

+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)theKey {
    
    BOOL automatic = NO;
    if ([theKey isEqualToString:@"badgeValue"]) {
        automatic = NO;
    }
    else {
        automatic = [super automaticallyNotifiesObserversForKey:theKey];
    }
    return automatic;
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}


- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}

- (BOOL)hasAnyContent {
    return self.badgeValue > 0;
}

- (int)badgeValue {
    int count = 0;
    for (id section in self.fetchedResultsController.sections) {
        count += [section numberOfObjects];
    }
    return count;
}

- (void)dealloc {
    if (fetchedResultsController_) {
        fetchedResultsController_.delegate = nil;
        [fetchedResultsController_ release];
    }
    
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;

	[sectionKey release];
    [super dealloc];
}


@end

