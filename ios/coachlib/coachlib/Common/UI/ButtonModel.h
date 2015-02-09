//
//  ButtonModel.h
//  coachlib
//
//  Copyright (c) 2012 Department of Veteran's Affairs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Content+ContentExtensions.h"
#import "GButton.h"

@class ContentViewController;

@interface ButtonModel : NSObject {
    GButton *_buttonView;
    BOOL _enabled;
}

@property (nonatomic,retain) NSString *label;
@property (nonatomic,retain) NSString *accessibilityLabel;
@property (nonatomic,retain) GButton *buttonView;
@property (nonatomic,assign) ContentViewController *controller;
@property (nonatomic,retain) UIImage *icon;
@property (nonatomic,retain) UIImage *toggledIcon;
@property (nonatomic,retain) Content *content;
@property (nonatomic,copy) void (^onClickBlock)();
@property (nonatomic,copy) void (^onToggleBlock)(BOOL state);
@property (nonatomic) BOOL toggleState;
@property (nonatomic) BOOL enabled;
@property (nonatomic) BOOL isDefault;
@property (nonatomic, retain) NSString *dynamicPredicate;
@property (nonatomic, retain) NSString *enablement;
@property (nonatomic) int style;
@property (nonatomic) int tag;

+ (ButtonModel*) button;
+ (ButtonModel*) buttonWithLabel:(NSString*)label;

- (id)initWithLabel:(NSString*)label;

- (void)onClick:(UIButton*)button;
- (void) updateEnablement:(ContentViewController*)cvc;

#define BUTTON_STYLE_LEFT       0x01
#define BUTTON_STYLE_RIGHT      0x02
#define BUTTON_STYLE_INLINE     0x04
#define BUTTON_STYLE_TOGGLE     0x08
#define BUTTON_STYLE_GRID       0x10
#define BUTTON_STYLE_LEFT_RIGHT 0x20

@end
