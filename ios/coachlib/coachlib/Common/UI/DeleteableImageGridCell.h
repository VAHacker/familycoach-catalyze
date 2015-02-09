//
//  CheckableImageGridCell.h
//  iStressLess
//


//

#import <Foundation/Foundation.h>
#import "ImageDemoGridViewCell.h"

@interface DeleteableImageGridCell : ImageDemoGridViewCell {
	void (^blockOnDelete)();
}

@property (nonatomic,copy) void (^blockOnDelete)();

@end
