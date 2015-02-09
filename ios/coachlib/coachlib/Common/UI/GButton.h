//
//  GButton.h
//  iStressLess
//


//

#import <Foundation/Foundation.h>
#import "DynamicSubView.h"

@class TUNinePatch;
@class ContentViewController;

#define GBUTTON_LAYOUT_CENTER_TOP	0
#define GBUTTON_LAYOUT_LEFT_RIGHT	1

@interface GButton : UIButton <Layoutable> {
	int layoutType;
}

@property (nonatomic,retain) NSString *label;
@property (nonatomic,retain) UIImage *icon;
@property (nonatomic,retain) UIImageView *iconView;
@property (nonatomic,retain) TUNinePatch *bgNormal;
@property (nonatomic,retain) TUNinePatch *bgPressed;
@property (nonatomic,retain) TUNinePatch *bgSelected;
@property (nonatomic) int layoutType;
@property (nonatomic) CGSize textSize;
@property (nonatomic) BOOL isDefault;
@property (nonatomic,retain) NSString *dynamicPredicate;
@property (nonatomic,assign) ContentViewController *controller;

@end
