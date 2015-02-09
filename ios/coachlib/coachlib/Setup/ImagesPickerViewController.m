//
//  ChosenImagesViewController.m
//  iStressLess
//


//

#import "ImagesPickerViewController.h"
#import "ImageDemoViewController.h"
//#import "AssetsLibrary/AssetsLibrary.h"
#import "CheckableImageGridCell.h"
#import "iStressLessAppDelegate.h"

@implementation ImagesPickerViewController

- (NSUInteger) numberOfItemsInGridView: (AQGridView *) aGridView {
	return [imageURLList count];
}

- (AQGridViewCell *)createCell NS_RETURNS_RETAINED {
	return [[CheckableImageGridCell alloc] initWithFrame:[self gridCellFrame]
											 reuseIdentifier: @"CheckableImageGridCell"];
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

-(void) gridView:(AQGridView *)gridView didSelectItemAtIndex:(NSUInteger)index {
	NSURL *url = [imageURLList objectAtIndex:index];

	NSManagedObjectContext *context = [iStressLessAppDelegate instance].udManagedObjectContext;
	CheckableImageGridCell *cell = (CheckableImageGridCell*)[gridView cellForItemAtIndex:index];
	if (cell.checked) {
		NSManagedObject *imageRef = [self refForImageURL:url];
		[context deleteObject:imageRef];
		cell.checked = FALSE;
	} else {
		NSManagedObject *newImageRef = [NSEntityDescription insertNewObjectForEntityForName:@"ImageReference" inManagedObjectContext:context];
		[newImageRef setValue:[url absoluteString] forKey:@"url"];
		cell.checked = TRUE;
	}
	[context save:nil];
	
	[gridView deselectItemAtIndex:index animated:TRUE];
}

-(void)viewDidLoad {
	imageURLList = [[NSMutableArray alloc] initWithCapacity:32];
/*	
	library = [[ALAssetsLibrary alloc] init];
	[library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop){
		NSLog(@"startGroup");
		[group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop){
			NSDictionary *dict = [result valueForProperty:ALAssetPropertyURLs];
			for (NSString *s in dict) {
				if ([s hasPrefix:@"public."]) {
					NSString *val = [dict valueForKey:s];
					NSLog(@"%@ => %@",s,val);
					[imageURLList addObject:val];
				}
			}
		}];
		NSLog(@"endGroup");
		[self.gridView reloadData];
	} failureBlock:nil];
*/
	[super viewDidLoad];
}

- (void)configureCell:(UITableViewCell *)cell atIndex:(int)index {
//	NSURL *url = [imageURLList objectAtIndex:index];

//	BOOL isChecked = [self refForImageURL:url] != nil;
/*
	[library assetForURL:url resultBlock:^(ALAsset *asset){
		CGImageRef cgi = [asset thumbnail];
		[cell setImage:[UIImage imageWithCGImage:cgi]];
		[cell setChecked:isChecked];
	} failureBlock:nil];
*/	
//	plainCell.image = [UIImage imageNamed: [_imageNames objectAtIndex: index]];
}

-(void) dealloc {
	[imageURLList release];
//	[library release];
	[super dealloc];
}

@end
