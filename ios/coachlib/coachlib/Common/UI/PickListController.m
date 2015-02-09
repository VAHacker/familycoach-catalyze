//
//  RelaxationIntroController.m
//  iStressLess
//


//

#import "PickListController.h"
#import "iStressLessAppDelegate.h"
#import "AssessNavigationController.h"
#import "Content+ContentExtensions.h"
#import "ThemeManager.h"

@implementation PickListController

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    NSManagedObject *managedObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
    NSString *value = nil;
    if (self.settingKey) {
        value = [[iStressLessAppDelegate instance] getSetting:self.settingKey];
    }
    NSString *key = [managedObject valueForKey:@"name"];
	cell.accessoryType = (value && key && [value isEqual:key]) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    
    ThemeManager *theme = [ThemeManager sharedManager];
	NSString *fontName = [theme stringForName:@"listTextFont"];
	float fontSize = [theme floatForName:@"listTextSize"];
	UIColor *textColor = [theme colorForName:@"listTextColor"];
	UIColor *bgColor = [theme colorForName:@"listBackgroundColor"];
    
	cell.textLabel.textColor = textColor;
	cell.backgroundColor = bgColor;
    cell.textLabel.text = [managedObject valueForKey:@"displayName"];
    cell.textLabel.minimumFontSize = fontSize*2/3;
    cell.textLabel.font = [UIFont fontWithName:fontName size:fontSize];
    cell.textLabel.adjustsFontSizeToFitWidth = TRUE;
    cell.textLabel.numberOfLines = 1;
	if (self.cellLines != INT_MAX) {
		cell.textLabel.numberOfLines = self.cellLines;
	}
    
}

-(void) configureFromContent {
	[super configureFromContent];
    self.settingKey = [self.content getExtraString:@"settingKey"];
    
/*
	CGRect bounds = [self.view bounds];
	CGRect tableFrame = bounds;
	tableFrame.origin.y += 10;
	UITableView *table = [[UITableView alloc] initWithFrame:tableFrame style:UITableViewStyleGrouped];
	tableFrame.size.height = 10 + 40*(int)[self tableView:table numberOfRowsInSection:0];
	table.frame = tableFrame;
	table.scrollEnabled = FALSE;
	[table setDelegate:self];
	[table setDataSource:self];
    table.backgroundView = nil;
	table.rowHeight = 40;
	table.opaque = FALSE;
	table.backgroundColor = [UIColor clearColor];	
	[self.dynamicView addSubview:table];
	tableView = table;
*/
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSManagedObject *managedObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
    NSString *value = [managedObject valueForKey:@"name"];
    if (self.settingKey) {
        [[iStressLessAppDelegate instance] setSetting:self.settingKey to:value];
    }
	[tableView deselectRowAtIndexPath:(NSIndexPath *)indexPath animated:FALSE];
	[tableView reloadData];
}

-(void) dealloc {
	[super dealloc];
}

@end
