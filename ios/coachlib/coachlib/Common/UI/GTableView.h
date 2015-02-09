//
//  GTableView.h
//  iStressLess
//


//

#import <Foundation/Foundation.h>
#import "DynamicSubView.h"

@interface GTableView : UITableView <Layoutable> {
	int marginBottom;
}

@property (nonatomic) int marginBottom;

-(float) contentHeight;

@end
