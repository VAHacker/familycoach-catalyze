//
//  ButtonModel.m
//  coachlib
//
//  Copyright (c) 2012 Department of Veteran's Affairs. All rights reserved.
//

#import "ButtonModel.h"
#import "VaPtsdExplorerProbesCampaign.h"
#import "heartbeat.h"
#import "GButton.h"
#import "ThemeManager.h"
#import "TUNinePatch.h"
#import "ContentViewController.h"

@implementation ButtonModel

+ (ButtonModel*) button {
    return [[[ButtonModel alloc] init] autorelease];
}

+ (ButtonModel*) buttonWithLabel:(NSString*)label {
    return [[[ButtonModel alloc] initWithLabel:label] autorelease];
}

-(void)setLabel:(NSString *)label {
    [_label release];
    _label = [label retain];
    if (_buttonView) {
        _buttonView.label = label;
    }
}

- (GButton*) createButton {
    ThemeManager *theme = [ThemeManager sharedManager];
	NSString *fontName = (self.style & BUTTON_STYLE_GRID) ? [theme stringForName:@"listTextFont"] : [theme stringForName:@"buttonTextFont"];
	float fontSize = (self.style & BUTTON_STYLE_GRID) ? [theme floatForName:@"listTextSize"] : [theme floatForName:@"buttonTextSize"];
	UIColor *textColor = [theme colorForName:@"buttonTextColor"];
	UIColor *tintColor = [theme colorForName:@"navBarTintColor"];
	UIColor *textColorPressed = [theme colorForName:@"buttonTextColorPressed"];
	
	CGRect r = CGRectMake(0, 0, 80, 30);
	GButton *button = [[GButton alloc] initWithFrame:r];

    button.bgNormal= [theme ninePatchForName:@"buttonBackgroundPatch"];
    button.bgPressed= [theme ninePatchForName:@"buttonBackgroundPatchPressed"];
    
	CGSize size;
	
	[button setTitle:self.label forState:UIControlStateNormal];
	[button setTitleColor:textColor forState:UIControlStateNormal];
	[button setTitleColor:textColorPressed forState:UIControlStateHighlighted];
	[button setTitleColor:[UIColor darkGrayColor] forState:UIControlStateDisabled];
    
    if (self.accessibilityLabel) button.accessibilityLabel = self.accessibilityLabel;
    
    if (self.isDefault) {
        [button setBackgroundColor:tintColor];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        button.isDefault = TRUE;
    }

    UIFont *font = [UIFont fontWithName:fontName size:fontSize];
    
	[button.titleLabel setFont:font];
	size = [(self.label ? self.label : @"...") sizeWithFont:font];
    //		[button setTitleShadowColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:0.2] forState:UIControlStateNormal];
    //		[button setTitleShadowOffset:CGSizeMake(1, 1)];
	button.titleLabel.lineBreakMode = UILineBreakModeWordWrap;
	button.titleLabel.textAlignment = UITextAlignmentCenter;
    button.textSize = size;
    
	size.width += 20;
	size.height += 20;
    
	if (self.icon) {
        button.icon = self.toggleState ? self.toggledIcon : self.icon;
	}
	
    if (self.style & BUTTON_STYLE_TOGGLE) {
        button.accessibilityTraits = UIAccessibilityTraitButton | (self.toggleState ? UIAccessibilityTraitSelected : 0);
    }
    
    button.dynamicPredicate = self.dynamicPredicate;
    button.controller = self.controller;
    button.enabled = self.enabled;
	button.tag = self.tag;
	button.titleEdgeInsets = UIEdgeInsetsMake(5,5,5,5);
    button.layoutType = (self.style & BUTTON_STYLE_LEFT_RIGHT) ? GBUTTON_LAYOUT_LEFT_RIGHT : GBUTTON_LAYOUT_CENTER_TOP;
//    button.userInteractionEnabled = TRUE;
	r.size = size;
	button.frame = r;
	
    [button addTarget:self action:@selector(onClick:) forControlEvents:UIControlEventTouchUpInside];    
	return button;
}	

-(void)setButtonView:(GButton *)buttonView {
    [_buttonView release];
    _buttonView = [buttonView retain];
}

-(GButton *)buttonView {
    if (_buttonView == nil) {
        _buttonView = [self createButton];
    }
    return _buttonView;
}

-(void) updateEnablement:(ContentViewController*)cvc {
    if (self.enablement) {
        NSString *s = [self.enablement substringFromIndex:3];
        BOOL r = [cvc evalJSPredicate:s];
        self.enabled = r;
    }
}

-(void) setEnabled:(BOOL)enabled {
    _enabled = enabled;
    if (self.buttonView) {
        self.buttonView.enabled = _enabled;
    }
}

-(BOOL)enabled {
    return _enabled;
}

- (id)init {
    _enabled = TRUE;
    _buttonView = nil;
    return self;
}

- (id)initWithLabel:(NSString*)label {
    self=[self init];
    self.label = label;
    return self;
}

- (void)recordButtonPush {
    NSMutableDictionary *params = self.content ? self.content.contentDescriptor : [NSMutableDictionary dictionary];
    NSString *val;
    
    [ButtonPressedEvent logWithButtonPressedButtonId:[NSString stringWithFormat:@"%d",self.tag] withButtonPressedButtonTitle:self.label];
    
    val = self.label;
    if (val) [params setObject:val forKey:@"buttonName"];
    [params setObject:[NSNumber numberWithInt:self.tag] forKey:@"buttonID"];
    
    [heartbeat
     logEvent:@"BUTTON_PRESS"
     withParameters:params];
}

-(void)setToggleState:(BOOL)toggleState {
    if (_toggleState == toggleState) return;
    _toggleState = toggleState;
    if (_buttonView) {
        _buttonView.icon = _toggleState ? self.toggledIcon : self.icon;
        //_buttonView.accessibilityValue = _toggleState ? @"selected" : nil;
        _buttonView.accessibilityTraits = UIAccessibilityTraitButton | (_toggleState ? UIAccessibilityTraitSelected : 0);
        [_buttonView setNeedsDisplay];
    }
}

- (void)onClick:(UIButton*)button {
    [self recordButtonPush];
    if (self.onClickBlock) {
        self.onClickBlock();
    }
    if (self.style & BUTTON_STYLE_TOGGLE) {
        self.toggleState = !self.toggleState;
        if (self.onToggleBlock) {
            self.onToggleBlock(self.toggleState);
        }
    }
}

-(void)dealloc {
    [_buttonView release];
    [super dealloc];
}

@end
