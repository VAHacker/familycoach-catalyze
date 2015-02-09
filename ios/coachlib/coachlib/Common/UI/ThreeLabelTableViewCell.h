//
//  ThreeLabelTableViewCell.h
//  coachlib
//
//  Copyright (c) 2012 Department of Veteran's Affairs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ThreeLabelTableViewCell : UITableViewCell

@property (nonatomic,retain) IBOutlet UILabel *titleLabel;
@property (nonatomic,retain) IBOutlet UILabel *subtitleLabel;
@property (nonatomic,retain) IBOutlet UILabel *rightLabel;

@end
