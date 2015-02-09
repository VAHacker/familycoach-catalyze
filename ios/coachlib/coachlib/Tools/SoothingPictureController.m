//
//  SoothingPictureController.m
//  iStressLess
//


//

#import "SoothingPictureController.h"
#import "iStressLessAppDelegate.h"
//#import "AssetsLibrary/AssetsLibrary.h"
#import "PhotoViewController.h"

@implementation SoothingPictureController

-(NSString*)checkPrerequisite {
	NSManagedObjectContext *context = [iStressLessAppDelegate instance].udManagedObjectContext;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"ImageReference"];
	fetchRequest.returnsObjectsAsFaults = TRUE;
	if ([context countForFetchRequest:fetchRequest error:NULL] == 0) {
        NSString *msg = [self.content getExtraString:@"prereq"];
        if (!msg) msg = @"You haven't chosen any soothing pictures from your photo library.  Go to Settings and choose some pictures before you can use this tool.";
		return msg;
	}
	
	return nil;
}

-(UIImage*)fetchAttachedImage {
	NSManagedObjectContext *context = [iStressLessAppDelegate instance].udManagedObjectContext;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"ImageReference"];
	fetchRequest.returnsObjectsAsFaults = TRUE;
	NSArray *a = [context executeFetchRequest:fetchRequest error:NULL];

	int index = rand() % a.count; 
	NSManagedObject *managedObject = [a objectAtIndex:index];
	
	NSURL *url = [NSURL URLWithString:[managedObject valueForKey:@"url"]]; 
	if (!url) {
		NSData *data = [managedObject valueForKey:@"imageData"];
		UIImage *image = data ? [UIImage imageWithData:data] : nil;
		return image;
	} else {
/*		
		ALAssetsLibrary * library = [[ALAssetsLibrary alloc] init];
		[library assetForURL:url resultBlock:^(ALAsset *asset){
			CGImageRef cgi = [[asset defaultRepresentation] fullResolutionImage];
			returnedImage = [UIImage imageWithCGImage:cgi];
		} failureBlock:nil];
		[library release];
		return returnedImage;
*/
        return nil;
	}
}

-(void)configureFromContent {
    self.inlineImage = TRUE;
    [super configureFromContent];
    
}

-(UIImage *)backgroundBlendedImageToUse {
    return nil;
}

- (void) zoomIn {
	UIImage *image = self.attachedImage;
	PhotoViewController *pvc = [[PhotoViewController alloc] init];
	[pvc setImage:image];
	[self.navigationController pushViewController:pvc animated:TRUE];
	[pvc release];
}

- (UIView*) createImageView:(UIImage*)image {
	UIView *v = [super createImageView:image];
	UIButton *b = [UIButton buttonWithType:UIButtonTypeCustom];
	UIImage *zoomImage = [UIImage imageNamed:@"zoom_image.png"];
	[b setImage:zoomImage forState:UIControlStateNormal];
    [b setContentMode:UIViewContentModeBottomLeft];
    b.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    b.contentVerticalAlignment = UIControlContentVerticalAlignmentBottom;
	CGRect r = ((UIView*)[v.subviews objectAtIndex:0]).frame;
    r = CGRectInset(r, 4, 4);
	//r.origin.y = r.size.height - zoomImage.size.height - 4;
	//r.origin.x += 4;
    //r.size = zoomImage.size;
    //r.origin.x = 0;
    //r.origin.y = 0;//r.origin.y + r.size.height - zoomImage.size.height - 4;
	b.frame = r;
	[v addSubview:b];
	[b addTarget:self action:@selector(zoomIn) forControlEvents:UIControlEventTouchUpInside];
	return v;
}

@end
