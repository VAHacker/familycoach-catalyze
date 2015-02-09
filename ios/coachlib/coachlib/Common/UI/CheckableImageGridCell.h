//
//  CheckableImageGridCell.h
//  iStressLess
//


//

#import <Foundation/Foundation.h>
#import "ImageDemoGridViewCell.h"

@interface CheckableImageGridCell : ImageDemoGridViewCell {
	UIImageView *checkmark;
}

@property (nonatomic) BOOL checked;

@end
