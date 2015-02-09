//
//  ChosenImagesViewController.m
//  iStressLess
//


//

#import "ChosenImagesViewController.h"
#import "ImageDemoViewController.h"
#import "DeleteableImageGridCell.h"
#import "iStressLessAppDelegate.h"
#import "PhotoViewController.h"

#define USE_OLD_API 1

@implementation ChosenImagesViewController

-(void)configureMetaContent {
	[super configureMetaContent];
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addTapped)] autorelease];
}

-(NSManagedObject*)refForImageURL:(NSURL*)url {
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"ImageReference" inManagedObjectContext:[iStressLessAppDelegate instance].udManagedObjectContext];
	[fetchRequest setEntity:entity];
	[fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"url == %@",[url absoluteString]]];
	NSArray *a = [self.managedObjectContext executeFetchRequest:fetchRequest error:NULL];
	[fetchRequest release];
	if (a && a.count) {
		NSManagedObject *o = [a objectAtIndex:0];
		if (o) {
			return o;
		}
	}
	
	return nil;
}

-(void) viewWillDisappear:(BOOL)animated {
	[self.fetchedResultsController.managedObjectContext save:nil];
	[super viewWillDisappear:(BOOL)animated];
}

- (void)configureCell:(DeleteableImageGridCell *)cell atIndex:(int)index {
    NSManagedObject *managedObject = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
	NSURL *url = [NSURL URLWithString:[managedObject valueForKey:@"url"]];
	if (url == nil) {
		NSData *data = [managedObject valueForKey:@"thumbnailData"];
		UIImage *image = data ? [UIImage imageWithData:data] : nil;
		[cell setImage:image];
        NSManagedObjectContext *moc = self.fetchedResultsController.managedObjectContext;
		cell.blockOnDelete = ^{
			[moc deleteObject:managedObject];
		};
	} else {
/*		
		[library assetForURL:url resultBlock:^(ALAsset *asset){
			CGImageRef cgi = [asset thumbnail];
			[cell setImage:[UIImage imageWithCGImage:cgi]];
			cell.blockOnDelete = ^{
				[self.fetchedResultsController.managedObjectContext deleteObject:managedObject];
			};
		} failureBlock:nil];
 */
	}
}

- (AQGridViewCell *)createCell NS_RETURNS_RETAINED {
	return [[DeleteableImageGridCell alloc] initWithFrame:[self gridCellFrame]
										 reuseIdentifier: @"DeleteableImageGridCell"];
}

-(void) loadView {
	[super loadView];
//	library = [[ALAssetsLibrary alloc] init];
}

-(void) addImageReference {
	UIImagePickerController *picker = [[UIImagePickerController alloc] init];
	picker.delegate = self;
	picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [[iStressLessAppDelegate instance] presentModalViewController: picker animated: YES];
	[picker release];
}

-(void)addTapped {
	if (USE_OLD_API) {
		[self addImageReference];
	} else {
//		[super addTapped];
	}
}

-(void) viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	if (!firstTimeDisplayed) {
		firstTimeDisplayed = TRUE;
		if ([self numberOfItemsInGridView:self.gridView] == 0) {
			[self addTapped];
		}
	}
}

-(void) imagePickerControllerDidCancel:(UIImagePickerController *)picker {
	[picker dismissModalViewControllerAnimated:TRUE];
}

-(UIImage *)resizeImage:(UIImage *)image :(NSInteger) width :(NSInteger) height {
	CGSize newSize;
	newSize.width = width;
	newSize.height = height;
	UIGraphicsBeginImageContext( newSize );
	[image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
	UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return newImage;
}

- (UIImage*)resizeIfNeeded:(UIImage*)image {
	int maxSize = 200;
	float h = image.size.height;
	float w = image.size.width;
	if (w > h) {
		if (w > maxSize) {
			h = ((maxSize/w) * h);
			w = maxSize;
		}
	} else {
		if (h > maxSize) {
			w = ((maxSize/h) * w);
			h = maxSize;
		}
	}
		
	NSLog(@"%@",[NSString stringWithFormat:@"Asking for image size: %dx%d",(int)w,(int)h]);
	image = [self resizeImage:image :(int)w :(int)h];

	return image;
}

-(void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	NSManagedObjectContext *context = [iStressLessAppDelegate instance].udManagedObjectContext;
	UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
	NSManagedObject *newImageRef = [NSEntityDescription insertNewObjectForEntityForName:@"ImageReference" inManagedObjectContext:context];

	NSData *data = UIImageJPEGRepresentation(image,1.0);
	[newImageRef setValue:data forKey:@"imageData"];
	data = UIImageJPEGRepresentation([self resizeIfNeeded:image],1.0);
	[newImageRef setValue:data forKey:@"thumbnailData"];
	
	[context save:nil];

	[picker dismissModalViewControllerAnimated:TRUE];
}
/*
-(void) imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo {
	NSURL *url = [editingInfo valueForKey:UIImagePickerControllerMediaURL];
	[picker dismissModalViewControllerAnimated:TRUE];
}
*/
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
	[self.gridView reloadData];
}

-(void) viewWillAppear:(BOOL)animated {
	[super viewWillAppear:(BOOL)animated];
	self.fetchedResultsController = nil;
	[self.gridView reloadData];
}

-(void) gridView:(AQGridView *)gridView didSelectItemAtIndex:(NSUInteger)index {
    NSManagedObject *managedObject = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
	NSURL *url = [NSURL URLWithString:[managedObject valueForKey:@"url"]];
	if (!url) {
		NSData *data = [managedObject valueForKey:@"imageData"];
		UIImage *image = data ? [UIImage imageWithData:data] : nil;
		PhotoViewController *pvc = [[PhotoViewController alloc] init];
		[pvc setImage:image];
		[self.navigationController pushViewController:pvc animated:TRUE];
		[pvc release];
	} else {
/*		
		[library assetForURL:url resultBlock:^(ALAsset *asset){
			CGImageRef cgi = [[asset defaultRepresentation] fullResolutionImage];
			PhotoViewController *pvc = [[PhotoViewController alloc] init];
			[pvc setImage:[UIImage imageWithCGImage:cgi]];
			[self.navigationController pushViewController:pvc animated:TRUE];
			[pvc release];
		} failureBlock:nil];
*/
	}
	
	[gridView deselectItemAtIndex:index animated:TRUE];
}

- (NSFetchedResultsController *)createFetchedResultsController {
    /*
     Set up the fetched results controller.
	 */
	
	// Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ImageReference" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchBatchSize:20];
	
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"url" ascending:YES];
    NSArray *sortDescriptors = nil;
	sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor1, nil];    
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

-(void) dealloc {
//	[library release];
	
	[super dealloc];
}

@end
