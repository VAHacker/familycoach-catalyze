//
//  RelaxationIntroController.m
//  iStressLess
//


//

#import "RadioController.h"
#import "DCRoundSwitch.h"
#import "CenteringView.h"

@implementation RadioController

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    [super configureCell:cell atIndexPath:indexPath];
    Content *content = (Content*)[self managedObjectForIndexPath:indexPath];
    NSString *val = [content getExtraString:@"value"];
    if ([val isEqualToString:self.selection]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    cell.accessibilityTraits = UIAccessibilityTraitButton;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Content *content = (Content*)[self managedObjectForIndexPath:indexPath];
    NSString *val = [content getExtraString:@"value"];
    self.selection = val;
    NSString *var = [self.content getExtraString:@"selectionVariable"];
    if (var) {
        [self setVariable:var to:val];
    }
    [self updateEnablements];
    [tableView reloadData];
    UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, [self.tableView cellForRowAtIndexPath:indexPath]);
}

-(void) configureFromContent {
	[super configureFromContent];
    
    NSString *var = [self.content getExtraString:@"selectionVariable"];
    self.selection = (NSString*)[self getVariable:var];
}

@end
