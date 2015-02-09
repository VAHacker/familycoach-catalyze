    //
//  ButtonGridController.m
//  iStressLess
//


//

#import "ButtonGridController.h"
#import "iStressLessAppDelegate.h"
#import "ConstructedView.h"
#import "GridView.h"
#import "GButton.h"

@implementation ButtonGridController

- (id)init {
	self = [super init];
	[self privateInit];
	return self;
}

-(UIView *) createMainViewWithFrame:(CGRect)frame {
	CGRect r = frame;
	gridView = [[GridView alloc] initWithFrame:r];
	NSString *mainText = [self.content valueForKey:@"mainText"];
//    NSLog(@"mainText: '%@'",mainText);
    if (mainText) {
        DynamicSubView* cview = [[DynamicSubView alloc] initWithFrame:r];
        mainText = [self replaceVariables:mainText];
        cview.matchBounds = TRUE;
        cview.childMargin = 0;
        r.size.height = 10;
        
        UIView *headerView = [self viewForHTML:mainText];
        [cview addSubview:headerView];
        [cview addSubview:gridView];
        return cview;
    } else {
        return gridView;
    }
}

-(void) configureMetaContent {
	[super configureMetaContent];
	int cellsPerRow = [self.content getExtraInt:@"buttongrid_cellsPerRow"];
	int outerMarginX = [self.content getExtraInt:@"buttongrid_outerMarginX"];
	int outerMarginY = [self.content getExtraInt:@"buttongrid_outerMarginY"];
	int cellMarginX = [self.content getExtraInt:@"buttongrid_cellMarginX"];
	int cellMarginY = [self.content getExtraInt:@"buttongrid_cellMarginY"];
	GridView *gv = (GridView*)gridView;
	if (cellsPerRow != INT_MAX) gv.cellsPerRow = cellsPerRow;
	if (outerMarginX != INT_MAX) gv.outerMarginX = outerMarginX;
	if (outerMarginY != INT_MAX) gv.outerMarginY = outerMarginY;
	if (cellMarginX != INT_MAX) gv.cellMarginX = cellMarginX;
	if (cellMarginY != INT_MAX) gv.cellMarginY = cellMarginY;
}

-(void) configureFromContent {
    NSString *onload = [self.content getExtraString:@"onload"];
    if (onload) {
        [self runJS:onload];
    }

	buttonContentList = self.content.properChildren;
	[buttonContentList retain];
	
	NSString *just = [self.content getExtraString:@"buttongrid_buttonjust"];

	for (int i=0;i<buttonContentList.count;i++) {
		Content *child = [buttonContentList objectAtIndex:i];
		UIImage *image = child.uiIcon;
		NSString *text = [child valueForKey:@"displayName"];
        
        ButtonModel *button = [self addButtonWithText:text callingBlock:^{
            [self managedObjectSelected:child];
        }];
        button.label = text;
        button.icon = image;
        button.style = BUTTON_STYLE_GRID;
        if (just != nil) button.style |= BUTTON_STYLE_LEFT_RIGHT;
        [gridView addSubview:button.buttonView];
	}
	
	[self configureMetaContent];
}

- (void)loadView {
	[super loadView];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[buttonContentList release];
	
    [super dealloc];
}


@end
