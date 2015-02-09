//
//  ThreeLabelTableViewCell.m
//  coachlib
//
//  Copyright (c) 2012 Department of Veteran's Affairs. All rights reserved.
//

#import <QuartzCore/CALayer.h>
#import "SelectionCell.h"

@implementation SelectionCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    
    BOOL subviewWasEnabled = self.selectionButton.enabled; //check if the view is enabled
    self.selectionButton.enabled = NO; //disable it anyways
    
    [super setHighlighted:highlighted animated:animated];
    
    self.selectionButton.enabled = subviewWasEnabled; //enable it again (if it was enabled)
}

-(void)didMoveToWindow {
    [super didMoveToWindow];
    [self.contentView.layer setCornerRadius:7.0f];
    [self.contentView.layer setMasksToBounds:YES];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
/*
-(void)willTransitionToState:(UITableViewCellStateMask)state {
    if (state & UITableViewCellStateShowingDeleteConfirmationMask) {
        if (self.rightLabel.alpha != 0) {
            [UIView animateWithDuration:0.5 animations:^{
                self.rightLabel.alpha = 0;
            }];
        }
    } else {
        if (self.rightLabel.alpha != 1) {
            [UIView animateWithDuration:1 animations:^{
                self.rightLabel.alpha = 1;
            }];
        }
    }
    [super willTransitionToState:state];
}
*/
@end
