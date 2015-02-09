//
//  FavoritesListViewController.m
//  iStressLess
//


//

#import "PickMultiController.h"
#import "iStressLessAppDelegate.h"
#import "ExerciseRef.h"
#import "GTableView.h"
#import "ThemeManager.h"

@interface UILabel (BPExtensions)
- (void)sizeToFitFixedWidth:(CGFloat)fixedWidth;
@end

@implementation UILabel (BPExtensions)


- (void)sizeToFitFixedWidth:(CGFloat)fixedWidth
{
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, fixedWidth, 0);
    self.lineBreakMode = UILineBreakModeWordWrap;
    self.numberOfLines = 0;
    [self sizeToFit];
}
@end

@implementation PickMultiController

-(void)configureFromContent {
    [super configureFromContent];
    self.itemContent = [self.content getChildByName:@"@item"];
    self.selectionVariable = [self.content getExtraString:@"selectionVariable"];
    ThemeManager *theme = [ThemeManager sharedManager];
	NSString *fontName = [theme stringForName:@"listTextFont"];
	float fontSize = [theme floatForName:@"listTextSize"];
    self.font = [UIFont fontWithName:fontName size:fontSize];
}

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

-(NSString*)makeLabel {
    NSArray *selections = (NSArray*)[self getVariable:self.selectionVariable];
    if (selections && selections.count) {
        NSMutableString *label = [NSMutableString string];
        BOOL first = TRUE;
        for (NSManagedObject *selection in selections) {
            NSString *name = [selection valueForKey:@"displayName"];
            if (!first) {
                [label appendString:@", "];
            }
            first = FALSE;
            [label appendString:name];
        }
        return label;
    } else {
        return self.itemContent.displayName;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *label = [self makeLabel];
    
    // Calculate the margin between the cell frame and the tableView
    // frame in a grouped table view style.
    float groupedStyleMarginWidth,tableViewWidth = tableView.frame.size.width;
    if (tableView.style == UITableViewStyleGrouped) {
        if (tableViewWidth > 20)
            groupedStyleMarginWidth = (tableViewWidth < 400) ? 10 : MAX(31, MIN(45, tableViewWidth*0.06));
        else
            groupedStyleMarginWidth = tableViewWidth - 10;
    }
    else
        groupedStyleMarginWidth = 0.0;
    
    float width = tableViewWidth - groupedStyleMarginWidth*2 - 40;
    
    CGSize size = [label sizeWithFont:self.font constrainedToSize:CGSizeMake(width, 9999) lineBreakMode:UILineBreakModeWordWrap];
    float height = fmax(44,size.height+10);
    NSLog(@"width=%f, height=%f (label=%@)",width,height,label);
    return height;
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleNone;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;

    NSString *label = [self makeLabel];
    cell.textLabel.font = self.font;
    cell.textLabel.text = label;
    cell.textLabel.numberOfLines = 9999;
    cell.textLabel.adjustsFontSizeToFitWidth = TRUE;
    cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
    cell.textLabel.minimumFontSize = 10;
    float width = cell.textLabel.frame.size.width;
    CGSize size = [label sizeWithFont:cell.textLabel.font constrainedToSize:CGSizeMake(width, 9999) lineBreakMode:UILineBreakModeWordWrap];
    float height = fmax(44,size.height+10);
    NSLog(@"width2=%f, height=%f (label=%@)",width,height,label);
    CGRect r = cell.frame;
    r.size.height = height;
    cell.frame = r;
    cell.shouldIndentWhileEditing = NO;
}

-(UITableView *)createTableView {
    GTableView *tv = (GTableView*)[super createTableView];
    tv.marginBottom = 10;
    return tv;
}

- (void)contentBecameVisible {
    [self.tableView reloadData];
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 1;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ContentViewController *cvc = [self getChildControllerWithName:@"@item"];
    [self navigateToNext:cvc];
	[tableView deselectRowAtIndexPath:indexPath animated:TRUE];
}

@end
