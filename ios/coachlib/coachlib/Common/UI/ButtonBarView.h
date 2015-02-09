//
//  ConstructedView.h
//  iStressLess
//


//

#import <UIKit/UIKit.h>
#import "DynamicSubView.h"

#define BUTTON_LEFT_RIGHT_MARKER 65535

@interface ButtonBarView : DynamicSubView {
	NSMutableArray *buttons;
}

-(void) addButton:(UIView*)button;
-(float) contentHeight;

@end
