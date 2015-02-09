//
//  ChosenImagesViewController.h
//  iStressLess
//


//

#import <Foundation/Foundation.h>
#import "ImageDemoViewController.h"
//#import "AssetsLibrary/AssetsLibrary.h"

@interface ChosenImagesViewController : ImageDemoViewController<UINavigationControllerDelegate,UIImagePickerControllerDelegate,NSFetchedResultsControllerDelegate> {
	//ALAssetsLibrary *library;
	BOOL firstTimeDisplayed;
}

@end
