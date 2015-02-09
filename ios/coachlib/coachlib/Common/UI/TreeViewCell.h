//
//  ThreeLabelTableViewCell.h
//  coachlib
//
//  Copyright (c) 2012 Department of Veteran's Affairs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CornerButton.h"
#import "GTextView.h"

@class TreeLines;
@class TreeViewCell;

@protocol TreeViewCellDelegate <NSObject>
-(void)itemExpanded:(id)item;
-(void)itemCollapsed:(id)item;
-(void)cellSizeChanged:(TreeViewCell*)cell;
-(void)cellEditingEnded:(TreeViewCell*)cell;
@end

@interface TreeViewCell : UITableViewCell <UITextViewDelegate>

@property (retain,nonatomic) TreeLines *treeLines;
@property (retain,nonatomic) IBOutlet UILabel *itemLabel;
@property (nonatomic,retain) IBOutlet GTextView *editingItemLabel;
@property (retain,nonatomic) IBOutlet UIButton *expandoButtonOverlay;
@property (retain,nonatomic) IBOutlet UIButton *expandoButton;
@property (assign,nonatomic) id item;
@property (assign,nonatomic) id<TreeViewCellDelegate> delegate;
@property (nonatomic) BOOL expanded;
@property (nonatomic,retain) NSArray *lastInParent;
@property (nonatomic) BOOL hasChildren;
@property (nonatomic) BOOL hasAlarm;
@property (nonatomic) BOOL isDue;
@property (nonatomic) int doneState;
@property (nonatomic) BOOL hasHiddenChildren;
@property (nonatomic) BOOL expandoVisible;
@property (nonatomic,retain) NSString *labelText;
@property (nonatomic,retain) UIFont *labelFont;
@property (nonatomic) BOOL editingTitle;

-(void)setExpanded:(BOOL)expanded animated:(BOOL)animated;
- (IBAction)expandoPressed:(id)sender;

-(void)updateExpandoButton;
-(float)getPreferredHeight;

@end

