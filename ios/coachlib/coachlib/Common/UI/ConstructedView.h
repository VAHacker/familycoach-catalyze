//
//  ConstructedView.h
//  iStressLess
//


//

#import <UIKit/UIKit.h>
#import "DynamicSubView.h"

@class ContentViewController;

#define BUTTON_LEFT_RIGHT_MARKER 65535

@interface ConstructedView : UIView <Layoutable> {
	UIView *_rightSideView;
	BOOL clipDynamicView;
    NSArray *_rightButtons;
    NSArray *_leftButtons;
}

@property (nonatomic, retain) UIView *clientView;
@property (nonatomic, retain) UIScrollView *scroller;
@property (nonatomic, retain) UIView *rightSideView;
@property (nonatomic, retain) NSArray *rightButtons;
@property (nonatomic, retain) NSArray *leftButtons;
@property (nonatomic, retain) NSString *dynamicPredicate;
@property (nonatomic, assign) ContentViewController *controller;
@property (nonatomic) BOOL clipDynamicView;
@property (nonatomic) BOOL onTop;

-(float) contentHeightWithFrame:(CGRect)r;

@end
