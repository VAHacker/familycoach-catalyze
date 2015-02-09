//
//  FavoritesListViewController.m
//  iStressLess
//


//

#import "PickOneController.h"
#import "iStressLessAppDelegate.h"
#import "ExerciseRef.h"
#import "GTableView.h"

@implementation PickOneController

-(void)configureFromContent {
    [super configureFromContent];
    self.itemContent = [self.content getChildByName:@"@item"];
    self.selectionVariable = [self.content getExtraString:@"selectionVariable"];
}

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleNone;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
    NSManagedObject *selection = (NSManagedObject*)[self getVariable:self.selectionVariable];
    if (selection) {
        cell.textLabel.text = [selection valueForKey:@"displayName"];
    } else {
        cell.textLabel.text = self.itemContent.displayName;
    }
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
