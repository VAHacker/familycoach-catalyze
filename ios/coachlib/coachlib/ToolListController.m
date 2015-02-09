//
//  FavoritesListViewController.m
//  iStressLess
//


//

#import "ToolListController.h"
#import "iStressLessAppDelegate.h"
#import "ExerciseRef.h"
#import "heartbeat.h"

@implementation ToolListController

-(void) configureFromContent {
    [super configureFromContent];
    self.hideSingleSectionHeader = TRUE;
}

-(BOOL)tableHasSections {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"ExerciseRef"];
	[fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"addressable == TRUE && sectionOrder != 1"]];
    [fetchRequest setFetchBatchSize:1];
	NSManagedObjectContext *udContext = [iStressLessAppDelegate instance].udManagedObjectContext;
    NSArray *a = [udContext executeFetchRequest:fetchRequest error:NULL];
    return a.count > 0;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [heartbeat logEvent:@"EXERCISE_SELECTED" withParameters:@{@"value":[self tableView:tableView cellForRowAtIndexPath:indexPath].textLabel.text}];
    ExerciseRef *selectedObject = (ExerciseRef*)[self managedObjectForIndexPath:indexPath];
    if ([self.content getExtraBoolean:@"selectionBumpsScore"]) {
        NSNumber *scoreObj = selectedObject.positiveScore;
        int score = scoreObj ? [scoreObj intValue] : 0;
        selectedObject.positiveScore = [NSNumber numberWithInt:score+1];
        [selectedObject.managedObjectContext save:NULL];
    }

	[tableView deselectRowAtIndexPath:(NSIndexPath *)indexPath animated:TRUE];
    [self managedObjectSelected:selectedObject.ref];
}

-(NSArray*) getAllExerciseCategories {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ExerciseCategory" inManagedObjectContext:self.content.managedObjectContext];
    [fetchRequest setEntity:entity];		
	NSArray *a = [self.content.managedObjectContext executeFetchRequest:fetchRequest error:NULL];
	[fetchRequest release];
	return a;
}

-(NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (self.hideSingleSectionHeader && ([self numberOfSectionsInTableView:tableView] <= 1)) return nil;
    ExerciseRef *o = (ExerciseRef*)[self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]];
    return o.sectionName;
}

- (NSFetchedResultsController *)createFetchedResultsController {
	NSManagedObjectContext *udContext = [iStressLessAppDelegate instance].udManagedObjectContext;

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ExerciseRef" inManagedObjectContext:udContext];
	[fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"addressable == TRUE"]];
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchBatchSize:100];

    // Edit the sort key as appropriate.
    NSArray *sortDescriptors = [NSArray arrayWithObjects:
								[NSSortDescriptor sortDescriptorWithKey:@"sectionOrder" ascending:YES],
								[NSSortDescriptor sortDescriptorWithKey:@"displayName" ascending:YES],
								nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
	
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:udContext sectionNameKeyPath:@"sectionOrder" cacheName:nil];
    aFetchedResultsController.delegate = self;
    [fetchRequest release];
    
    NSError *error = nil;
    if (![aFetchedResultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return aFetchedResultsController;
}

@end
