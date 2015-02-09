//
//  FavoritesListViewController.m
//  iStressLess
//


//

#import "FavoritesListViewController.h"
#import "iStressLessAppDelegate.h"

#if 0
@implementation FavoritesListViewController

-(UITableView *) tableView {
	return nil;
}

-(void) configureFromContent {
	if (showAlternativeText) {
		[self baselineConfigureFromContent];
	} else {
		[super configureFromContent];
	}
}

-(void) loadView {
	NSManagedObjectContext *context = [iStressLessAppDelegate instance].udManagedObjectContext;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ExerciseScore" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
	[fetchRequest setFetchLimit:1];
	[fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"(positiveScore > 0) AND (inFavoriteList == TRUE)"]];
	if ([context countForFetchRequest:fetchRequest error:nil] > 0) {
		showAlternativeText = FALSE;
		[super loadView];
	} else {
		showAlternativeText = TRUE;
		[self loadViewFromContent];
	}
}

-(NSArray*) getAllExerciseCategories {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ExerciseCategory" inManagedObjectContext:self.content.managedObjectContext];
    [fetchRequest setEntity:entity];		
	NSArray *a = [self.content.managedObjectContext executeFetchRequest:fetchRequest error:NULL];
	[fetchRequest release];
	return a;
}
/*
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    NSManagedObject *managedObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    NSString *displayName = [managedObject valueForKey:@"displayName"];
	if (!displayName) {
		NSManagedObject *parent = [managedObject valueForKey:@"parent"];
		NSString *parentDisplayName = parent ? [parent valueForKey:@"displayName"] : nil;
		if (parentDisplayName) displayName = [NSString stringWithFormat:@"%@ #%d",parentDisplayName,([indexPath row]+1)];
	}
    cell.textLabel.text = displayName;
}
*/

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    NSManagedObject *managedObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    NSString *displayName = [managedObject valueForKey:@"displayName"];
	if (!displayName) {
		NSString *parentDisplayName = [managedObject valueForKey:@"parentDisplayName"];
		if (parentDisplayName) displayName = [NSString stringWithFormat:@"%@ #%d",parentDisplayName,([indexPath row]+1)];
	}
    cell.textLabel.text = displayName;
}

- (NSFetchedResultsController *)createFetchedResultsController {
	
	NSManagedObjectContext *context = [iStressLessAppDelegate instance].managedObjectContext;
	NSManagedObjectContext *udContext = [iStressLessAppDelegate instance].udManagedObjectContext;

	// Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ExerciseScore" inManagedObjectContext:udContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchBatchSize:100];
	[fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"(positiveScore > 0) AND (inFavoriteList == TRUE)"]];
	
    // Edit the sort key as appropriate.
    NSArray *sortDescriptors = [NSArray arrayWithObjects:
								[NSSortDescriptor sortDescriptorWithKey:@"parentDisplayName" ascending:YES],
								[NSSortDescriptor sortDescriptorWithKey:@"displayName" ascending:YES],
								nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
	
	//	a = [context executeFetchRequest:fetchRequest error:NULL];
	
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:udContext sectionNameKeyPath:@"parentDisplayName" cacheName:nil];//[self.content valueForKey:@"name"]];
    aFetchedResultsController.delegate = self;
    [fetchRequest release];
    
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

/*
- (NSFetchedResultsController *)createFetchedResultsController {
	
	NSManagedObjectContext *context = [iStressLessAppDelegate instance].managedObjectContext;
	NSManagedObjectContext *udContext = [iStressLessAppDelegate instance].udManagedObjectContext;
	
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"ExerciseScore" inManagedObjectContext:udContext];
	[fetchRequest setEntity:entity];
	[fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"(positiveScore > 0) AND NOT (isCategory == TRUE)"]];
	NSArray *exerciseScores = [udContext executeFetchRequest:fetchRequest error:NULL];
	[fetchRequest release];
	
	NSMutableArray *exerciseURIs = [NSMutableArray arrayWithCapacity:exerciseScores.count];
	for (NSManagedObject *o in exerciseScores) {
		NSString *uri = [o valueForKey:@"refID"];
		NSManagedObjectID *oid = [context.persistentStoreCoordinator managedObjectIDForURIRepresentation:[NSURL URLWithString:uri]];
		if (oid) {
			[exerciseURIs addObject:oid];
		} else {
			[udContext deleteObject:o];
		}
	}
	
	// First get all ExerciseCategories
	NSArray *a = [self getAllExerciseCategories];
	NSMutableSet *individualParents = [NSMutableSet setWithCapacity:a.count];
	NSMutableSet *categoryLevelItems = [NSMutableSet setWithCapacity:a.count];
	for (NSManagedObject *o in a) {
		NSNumber *n = [o valueForKey:@"categoryLevelFavorite"];
		BOOL categoryLevelFavorite = n ? [n boolValue] : FALSE;
		if (categoryLevelFavorite) {
			fetchRequest = [[NSFetchRequest alloc] init];
			entity = [NSEntityDescription entityForName:@"Content" inManagedObjectContext:context];
			[fetchRequest setEntity:entity];
			[fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"parent == %@ AND self IN %@",o,exerciseURIs]];
			[fetchRequest setFetchLimit:1];
			NSArray *a = [context executeFetchRequest:fetchRequest error:NULL];
			[fetchRequest release];

			if (a && a.count) {
				[categoryLevelItems addObject:o];
				NSManagedObjectID *oid = [o objectID];
				[exerciseURIs addObject:oid];
			}
		} else {
			[individualParents addObject:o];
		}
	}
	
	// Create the fetch request for the entity.
    fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    entity = [NSEntityDescription entityForName:@"Content" inManagedObjectContext:self.content.managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchBatchSize:100];
	[fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"((parent IN %@) OR (self IN %@)) AND (self IN %@)",individualParents,categoryLevelItems,exerciseURIs]];
//	[fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"(parent IN %@) OR (self IN %@)",individualParents,categoryLevelItems]];
	
    // Edit the sort key as appropriate.
    NSArray *sortDescriptors = [NSArray arrayWithObjects:
								[NSSortDescriptor sortDescriptorWithKey:@"parent.displayName" ascending:YES],
								[NSSortDescriptor sortDescriptorWithKey:@"displayName" ascending:YES],
								nil];
    [fetchRequest setSortDescriptors:sortDescriptors];

//	a = [context executeFetchRequest:fetchRequest error:NULL];
	
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.content.managedObjectContext sectionNameKeyPath:@"parent.displayName" cacheName:nil];//[self.content valueForKey:@"name"]];
    aFetchedResultsController.delegate = self;
    [fetchRequest release];
    
    NSError *error = nil;
    if (![aFetchedResultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return aFetchedResultsController;
}
*/

@end
#endif

