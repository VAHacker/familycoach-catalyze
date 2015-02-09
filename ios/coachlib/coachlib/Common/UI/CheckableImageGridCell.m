//
//  CheckableImageGridCell.m
//  iStressLess
//


//

#import "CheckableImageGridCell.h"


@implementation CheckableImageGridCell

-(id) initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)aReuseIdentifier {
	self = [super initWithFrame:frame reuseIdentifier:aReuseIdentifier];

	checkmark = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkmark.png"]];
	[self.contentView addSubview:checkmark];
	
	return self;
}

-(BOOL) checked {
	return !checkmark.hidden;
}

-(void) setChecked:(BOOL)_checked {
	checkmark.hidden = !_checked;
}

-(void) dealloc {
	[checkmark release];
	[super dealloc];
}

@end
