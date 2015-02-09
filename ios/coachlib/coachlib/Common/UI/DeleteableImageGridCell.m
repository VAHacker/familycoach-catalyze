//
//  CheckableImageGridCell.m
//  iStressLess
//


//

#import "CheckableImageGridCell.h"
#import "DeleteableImageGridCell.h"

@implementation DeleteableImageGridCell

@synthesize blockOnDelete;

-(id) initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)aReuseIdentifier {
	self=[super initWithFrame:frame reuseIdentifier:aReuseIdentifier];

	UIButton *b = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
	[b setImage:[UIImage imageNamed:@"delete-icon.png"] forState:UIControlStateNormal];
	[b addTarget:self action:@selector(deleteTapped) forControlEvents:UIControlEventTouchUpInside];
	[self.contentView addSubview:b];
	
	return self;
}

-(void)deleteTapped {
	if (blockOnDelete) blockOnDelete();
}

-(void) dealloc {
	[blockOnDelete release];
	[super dealloc];
}

@end
