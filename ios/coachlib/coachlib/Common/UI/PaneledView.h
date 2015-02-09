//
//  PaneledView.h
//  coachlib
//
//  Copyright (c) 2012 Department of Veteran's Affairs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PaneledView : UIView {
    BOOL expanded;
    BOOL _panelHidden;
    NSString *_splitTitle;
    int _splitBadgeValue;
}

@property (nonatomic,retain) UIView *top;
@property (nonatomic,retain) UIView *bottom;
@property (nonatomic,retain) UIView *bottomPane;
@property (nonatomic,retain) UIView *collapseButton;
@property (nonatomic,retain) UILabel *splitLabel;
@property (nonatomic,retain) UIButton *splitView;

@property (nonatomic,retain) NSString *splitTitle;
@property (nonatomic) int splitBadgeValue;

@property (nonatomic) BOOL expanded;
@property (nonatomic) BOOL panelHidden;
@property (nonatomic) float bottomMinHeight;
@property (nonatomic) float bottomMaxHeight;

-(void)setExpanded:(BOOL)isExpanded animated:(BOOL)animated;
-(void)setPanelHidden:(BOOL)panelHidden animated:(BOOL)animated;

@end
