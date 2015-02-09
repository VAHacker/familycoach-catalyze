//
//  ChoosenAudioListViewController.m
//  iStressLess
//


//

#import "ChosenAudioListViewController.h"
#import "iStressLessAppDelegate.h"
#import "MediaPlayer/MediaPlayer.h"

@implementation ChosenAudioListViewController

- (NSManagedObjectContext*)managedObjectContext {
	return [iStressLessAppDelegate instance].udManagedObjectContext; 
}

-(UITableViewCell *)createCell:(NSString*)typeIdentifier NS_RETURNS_RETAINED {
	return [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:typeIdentifier];
}

- (MPMediaQuery*)queryForAudio:(NSManagedObject*)audioObject {
    NSNumber *refID = [audioObject valueForKey:@"refID"];
	MPMediaQuery *query = [[MPMediaQuery alloc] init];
	[query addFilterPredicate:[MPMediaPropertyPredicate predicateWithValue:refID forProperty:MPMediaItemPropertyPersistentID]];
	return [query autorelease];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    NSManagedObject *managedObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
	MPMediaQuery *query = [self queryForAudio:managedObject];
	NSArray *a = [query items];
	if (a && a.count) {
		MPMediaItem *item = [a objectAtIndex:0];
		cell.textLabel.text = [item valueForProperty:MPMediaItemPropertyTitle];
		NSString *albumArtist = [item valueForProperty:MPMediaItemPropertyAlbumArtist];
		NSString *albumTitle = [item valueForProperty:MPMediaItemPropertyAlbumTitle];
		NSString *artist = [item valueForProperty:MPMediaItemPropertyArtist];
		if (!albumArtist && !albumTitle && artist) {
			cell.detailTextLabel.text = artist;
		} else if (albumArtist && albumTitle) {
			cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ - %@",albumTitle,albumArtist];
		} else if (albumTitle) {
			cell.detailTextLabel.text = albumTitle;
		} else if (albumArtist) {
			cell.detailTextLabel.text = albumArtist;
		} else {
			cell.detailTextLabel.text = nil;
		}
	} else {
		cell.textLabel.text = @"(Unknown song)";
	}
}

- (void) mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker {
	[mediaPicker dismissModalViewControllerAnimated:TRUE];
}

- (void)mediaPicker: (MPMediaPickerController *)mediaPicker didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection {
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];

	for (int i=0;i<mediaItemCollection.count;i++) {
		MPMediaItem *item = [[mediaItemCollection items] objectAtIndex:i];
		NSNumber *number = [item valueForProperty:MPMediaItemPropertyPersistentID];
		NSManagedObject *newAudio = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
		[newAudio setValue:number forKey:@"refID"];
	}
    
    // If appropriate, configure the new managed object.
	//    [newManagedObject setValue:[NSDate date] forKey:@"timeStamp"];
    
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
	
	[mediaPicker dismissModalViewControllerAnimated:TRUE];
}

- (void) tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath {
	
	if (appMusicPlayer) {
		[appMusicPlayer stop];
		[appMusicPlayer release];
	}
	
	NSManagedObject *selectedObject = [[self fetchedResultsController] objectAtIndexPath:indexPath];
	appMusicPlayer = [MPMusicPlayerController applicationMusicPlayer];
	[appMusicPlayer retain];
	[appMusicPlayer setShuffleMode: MPMusicShuffleModeOff];
	[appMusicPlayer setRepeatMode: MPMusicRepeatModeNone];
	MPMediaQuery *query = [self queryForAudio:selectedObject];
	[appMusicPlayer setQueueWithQuery: query];
	[appMusicPlayer play];
    [tableView deselectRowAtIndexPath: indexPath animated: YES];
}

- (void)addAudioReference {
	MPMediaPickerController *picker =
    [[MPMediaPickerController alloc]
	 initWithMediaTypes: MPMediaTypeAnyAudio];                   // 1
	
	[picker setDelegate: self];                                         // 2
	[picker setAllowsPickingMultipleItems: YES];                        // 3
	picker.prompt =
    NSLocalizedString (@"Choose soothing songs or audio clips",
					   "Prompt in media item picker");
	
    [[iStressLessAppDelegate instance] presentModalViewController: picker animated: YES];
	[picker release];
}

-(void) viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	if (!firstTimeDisplayed) {
		firstTimeDisplayed = TRUE;
		if ([self tableView:self.tableView numberOfRowsInSection:0] == 0) {
			[self addAudioReference];
		}
	}
}

- (void)loadView {
	[super loadView];
	self.tableView.rowHeight = 50;
	self.tableView.editing = TRUE;
	self.tableView.allowsSelectionDuringEditing = TRUE;
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addAudioReference)] autorelease];
}

- (NSFetchedResultsController *)createFetchedResultsController {
    /*
     Set up the fetched results controller.
	 */
	
	// Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"AudioReference" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchBatchSize:20];
	
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"refID" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor1, nil];    
    [fetchRequest setSortDescriptors:sortDescriptors];

    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:[self.content valueForKey:@"name"]];
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
	if (appMusicPlayer) {
		[appMusicPlayer stop];
		[appMusicPlayer release];
		appMusicPlayer = nil;
	}
}

- (void)dealloc {
	if (appMusicPlayer) {
		[appMusicPlayer stop];
		[appMusicPlayer release];
		appMusicPlayer = nil;
	}

    [super dealloc];
}


@end

