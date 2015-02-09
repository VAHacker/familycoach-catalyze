//
//  ThreeLabelTableViewCell.m
//  coachlib
//
//  Copyright (c) 2012 Department of Veteran's Affairs. All rights reserved.
//

#import "ThreeLabelTableViewCell.h"

@implementation ThreeLabelTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
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
