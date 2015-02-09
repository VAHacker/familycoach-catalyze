//
//  GridView.m
//  iStressLess
//


//

#import "GridView.h"


@implementation GridView

@synthesize cellsPerRow, cellMarginX, cellMarginY, outerMarginX, outerMarginY, includeTopMargin;

- (id)initWithFrame:(CGRect)frame {
    includeTopMargin = YES;
    if ((self = [super initWithFrame:frame])) {
		cellsPerRow = 2;
		cellMarginX = 10;
		cellMarginY = 10;
		outerMarginX = 10;
		outerMarginY = 10;
    }
    return self;
}

-(void) layoutSubviews {
    if (self.inLayout) return;
    self.inLayout = TRUE;
    
	CGRect r = self.bounds;
	r.origin.x += outerMarginX;
	r.size.width -= outerMarginX*2;
    if (includeTopMargin) {
        r.origin.y += outerMarginY;
        r.size.height -= outerMarginY*2;
    } else {
    }

	NSArray *children = [self subviews];
	int rowCount = (children.count + (cellsPerRow-1)) / cellsPerRow;
	float cellWidth = (r.size.width - ((cellsPerRow-1) * cellMarginX)) / cellsPerRow;
	float cellHeight = (r.size.height - ((rowCount-1) * cellMarginY)) / rowCount;
	for (int i=0;i<children.count;i++) {
		UIView *child = [children objectAtIndex:i];
		int row = i / cellsPerRow;
		int column = i % cellsPerRow;
		CGRect cellR = CGRectMake(r.origin.x + column * (cellWidth + cellMarginX), r.origin.y + row * (cellHeight + cellMarginY), cellWidth, cellHeight);
        cellR.origin.x = roundf(cellR.origin.x);
        cellR.origin.y = roundf(cellR.origin.y);
        cellR.size.width = roundf(cellR.size.width);
        cellR.size.height = roundf(cellR.size.height);
		child.frame = cellR;
        [child layoutIfNeeded];
	}
    
    self.inLayout = FALSE;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)dealloc {
    [super dealloc];
}


@end
