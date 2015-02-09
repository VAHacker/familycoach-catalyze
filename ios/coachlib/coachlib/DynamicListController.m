//
//  FavoritesListViewController.m
//  iStressLess
//


//

#import "DynamicListController.h"
#import "iStressLessAppDelegate.h"
#import "ExerciseRef.h"
#import "ThreeLabelTableViewCell.h"

@implementation DynamicListController

-(void) startEditing:(id)origin {
    [self.tableView beginUpdates];
        self.tableView.editing = TRUE;
        if (!self.addWhenNotEditing) {
            if (addStyle==ADD_STYLE_FIRST) {
                [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
            } else if (addStyle==ADD_STYLE_LAST) {
                int count = [[self.fetchedResultsController.sections objectAtIndex:0] numberOfObjects];
                [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:count inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
            }
        }
    [self.tableView endUpdates];

    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneEditing:)] autorelease];
}

-(void) doneEditing:(id)origin {
    [self.tableView beginUpdates];
        self.tableView.editing = FALSE;
        if (!self.addWhenNotEditing) {
            if (addStyle==ADD_STYLE_FIRST) {
                [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
            } else if (addStyle==ADD_STYLE_LAST) {
                int count = [[self.fetchedResultsController.sections objectAtIndex:0] numberOfObjects];
                [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:count inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
            }
        }
    [self.tableView endUpdates];
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(startEditing:)] autorelease];
}

-(void)viewWillAppear:(BOOL)animated {
    NSFetchedResultsController *frc = self.fetchedResultsController;
    if (frc.fetchedObjects.count > 0) {
        [self setVariable:@"listHasItems" to:@true];
    } else {
        [self setVariable:@"listHasItems" to:@false];
    }
    [super viewWillAppear:animated];
}

-(void) configureFromContent {
    addStyle = ADD_STYLE_NONE;
    self.selectionVariable = [self.content getExtraString:@"selectionVariable"];
    self.entityName = [self.content getExtraString:@"entityName"];
    self.cellType = [self.content getExtraString:@"cellType"];
    self.selectMulti = [self.content getExtraBoolean:@"selectMulti"];
    self.addWhenNotEditing = [self.content getExtraBoolean:@"addWhenNotEditing"];
    BOOL editOnly = [self.content getExtraBoolean:@"editOnly"];
    BOOL canEdit = [self.content getExtraBoolean:@"canEdit"];
    NSString *addStyleStr = [self.content getExtraString:@"addStyle"];
    if (addStyleStr) {
        if ([addStyleStr isEqualToString:@"first"]) {
            addStyle = ADD_STYLE_FIRST;
        } else if ([addStyleStr isEqualToString:@"last"]) {
            addStyle = ADD_STYLE_LAST;
        }
    }
    self.editing = editOnly;
    
    NSFetchedResultsController *frc = self.fetchedResultsController;
    if (frc.fetchedObjects.count > 0) {
        [self setVariable:@"listHasItems" to:@true];
    } else {
        [self setVariable:@"listHasItems" to:@false];
    }
    
    [super configureFromContent];
    self.hideSingleSectionHeader = TRUE;

    UITableView *tv = self.tableView;
    tv.editing = editOnly;
    tv.allowsSelectionDuringEditing = TRUE;
    
    if (!editOnly && canEdit) {
        self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(startEditing:)] autorelease];
    }
}

-(BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return TRUE;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    int row = indexPath.row;
    int count = [[self.fetchedResultsController.sections objectAtIndex:indexPath.section] numberOfObjects];
    if ((tableView.editing || self.addWhenNotEditing) &&
        (((addStyle==ADD_STYLE_LAST) && (row == count)) ||
        ((addStyle==ADD_STYLE_FIRST) && (row == 0)))) {
        return YES;
    }
    
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    int row = indexPath.row;
    int count = [[self.fetchedResultsController.sections objectAtIndex:indexPath.section] numberOfObjects];
	[tableView deselectRowAtIndexPath:(NSIndexPath *)indexPath animated:TRUE];

    if ((tableView.editing || self.addWhenNotEditing) &&
        (((addStyle==ADD_STYLE_LAST) && (row == count)) ||
         ((addStyle==ADD_STYLE_FIRST) && (row == 0)))) {
        [self tableView:tableView commitEditingStyle:UITableViewCellEditingStyleInsert forRowAtIndexPath:indexPath];
        return;
    }
    
    if ((tableView.editing|| self.addWhenNotEditing) && (addStyle==ADD_STYLE_FIRST)) {
        indexPath = [NSIndexPath indexPathForRow:row-1 inSection:0];
    }
    
    NSManagedObject *selectedObject = (NSManagedObject*)[self managedObjectForIndexPath:indexPath];

    if (self.selectMulti) {
        NSMutableOrderedSet *selections = (NSMutableOrderedSet*)[self getVariable:self.selectionVariable];
        if (!selections) {
            selections = [NSMutableOrderedSet orderedSet];
            [self setVariable:self.selectionVariable to:selections];
        }
        if ([selections containsObject:selectedObject]) {
            [selections removeObject:selectedObject];
        } else {
            [selections addObject:selectedObject];
            NSMutableArray *a = [[selections array] mutableCopy];
            [a sortUsingDescriptors:self.sortDescriptors];
            selections = [NSMutableOrderedSet orderedSetWithArray:a];
            [a release];
            [self setVariable:self.selectionVariable to:selections];
        }
        [self.tableView reloadData];
    } else {
        BOOL selectOnly = [self.content getExtraBoolean:@"selectOnly"];
        if (selectOnly) {
            [self managedObjectSelected:selectedObject];
        } else {
            self.privateContext = [[[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType] autorelease];
            self.privateContext.parentContext = self.fetchedResultsController.managedObjectContext;
            selectedObject = [self.privateContext objectWithID:[selectedObject objectID]];

            Content *addContent = [self.content getChildByName:@"@add"];
            ContentViewController *cvc = [addContent getViewController];
            [cvc setVariable:@"@binding" to:selectedObject];
            [cvc setVariable:@"formOperation" to:@"Edit"];
            [self navigateToNext:cvc];
        }
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    int row = indexPath.row;
    int count = [[self.fetchedResultsController.sections objectAtIndex:indexPath.section] numberOfObjects];
    if ((tableView.editing || self.addWhenNotEditing) &&
        (((addStyle==ADD_STYLE_LAST) && (row == count)) ||
         ((addStyle==ADD_STYLE_FIRST) && (row == 0)))) {
        return UITableViewCellEditingStyleInsert;
    }

    NSManagedObject *selectedObject = (NSManagedObject*)[self managedObjectForIndexPath:indexPath];
    id permanentProp = [[[selectedObject entity] propertiesByName] objectForKey:@"permanent"];
    if (permanentProp) {
        NSNumber *permanent = (NSNumber*)[selectedObject valueForKey:@"permanent"];
        if ([permanent boolValue]) return UITableViewCellEditingStyleNone;
    }
    
    return UITableViewCellEditingStyleDelete;
}

-(void)navigationDataReceived:(NSDictionary *)data {
    NSDictionary *addDict = [data objectForKey:@"add"];
    if (addDict) {
        Content *addContent = [self.content getChildByName:@"@add"];
        ContentViewController *cvc = [addContent getViewController];
        [cvc setVariable:@"formOperation" to:@"Add"];
        
        [addDict enumerateKeysAndObjectsUsingBlock: ^(NSString* key, NSObject *obj, BOOL *stop) {
            [cvc setVariable:key to:obj];
        }];
        
        [self navigateToNext:cvc];
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleInsert) {
        Content *addContent = [self.content getChildByName:@"@add"];
        ContentViewController *cvc = [addContent getViewController];
        [cvc setVariable:@"formOperation" to:@"Add"];
        [self navigateToNext:cvc];
        return;
    }
    if (self.tableView.editing && (addStyle==ADD_STYLE_FIRST)) {
        indexPath = [NSIndexPath indexPathForRow:indexPath.row-1 inSection:0];
    }
    
    NSManagedObject *selectedObject = (NSManagedObject*)[self managedObjectForIndexPath:indexPath];
    id permanentProp = [[[selectedObject entity] propertiesByName] objectForKey:@"permanent"];
    if (permanentProp) {
        NSNumber *permanent = (NSNumber*)[selectedObject valueForKey:@"permanent"];
        if ([permanent boolValue]) return;
    }

    [super tableView:tableView commitEditingStyle:editingStyle forRowAtIndexPath:indexPath];
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [super tableView:tableView numberOfRowsInSection:section] + (((self.tableView.editing||self.addWhenNotEditing) && ((addStyle==ADD_STYLE_FIRST)||(addStyle==ADD_STYLE_LAST))) ? 1 : 0);
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    int row = indexPath.row;
    int count = [[self.fetchedResultsController.sections objectAtIndex:indexPath.section] numberOfObjects];
    NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if ((tableView.editing || self.addWhenNotEditing) &&
        (((addStyle==ADD_STYLE_LAST) && (row == count)) ||
         ((addStyle==ADD_STYLE_FIRST) && (row == 0)))) {
        cellIdentifier = @"add";
    }
    if (cell == nil) {
        cell = [[self createCell:cellIdentifier] autorelease];
    }
    // Configure the cell.
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

-(UITableViewCell *)createCell:(NSString*)typeIdentifier NS_RETURNS_RETAINED {
    if (!self.cellType || [typeIdentifier isEqualToString:@"add"]) {
        return [super createCell:typeIdentifier];
    }

    NSArray *a = [[NSBundle mainBundle] loadNibNamed:self.cellType owner:self options:nil];
    UITableViewCell *cell = [[a objectAtIndex:0] retain];
    CGRect r = cell.frame;
    r.origin.y = r.size.height-1;
    r.size.height = 1;
    UIView *separator = [[[UIView alloc] initWithFrame:r] autorelease];
    separator.backgroundColor = self.backgroundColor;
    separator.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    cell.autoresizesSubviews = TRUE;
    [cell addSubview:separator];
    return cell;
}

- (void)configureCell:(UITableViewCell *)_cell atIndexPath:(NSIndexPath *)indexPath {
    int row = indexPath.row;
    int count = [[self.fetchedResultsController.sections objectAtIndex:indexPath.section] numberOfObjects];
    _cell.shouldIndentWhileEditing = YES;
    if ((self.tableView.editing || self.addWhenNotEditing) &&
        (((addStyle==ADD_STYLE_LAST) && (row == count)) ||
         ((addStyle==ADD_STYLE_FIRST) && (row == 0)))) {
        _cell.textLabel.text = @"Add an entry";
        _cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        _cell.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
//        _cell.editing = TRUE;
        return;
    }

    if ((self.tableView.editing||self.addWhenNotEditing) && (addStyle==ADD_STYLE_FIRST)) {
        row--;
        indexPath = [NSIndexPath indexPathForRow:row inSection:0];
    }
    NSManagedObject *managedObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    if ([_cell isKindOfClass:[ThreeLabelTableViewCell class]]) {
        ThreeLabelTableViewCell *cell = (ThreeLabelTableViewCell*)_cell;
        cell.titleLabel.text = [managedObject valueForKey:@"displayName"];
        if ([managedObject respondsToSelector:@selector(subLabel)]) {
            cell.subtitleLabel.text = [managedObject performSelector:@selector(subLabel)];
        } else {
            cell.subtitleLabel.text = nil;
        }
        if ([managedObject respondsToSelector:@selector(detailLabel)]) {
            cell.rightLabel.text = [managedObject performSelector:@selector(detailLabel)];
        } else {
            cell.rightLabel.text = nil;
        }
    } else {
        _cell.textLabel.text = [managedObject valueForKey:@"displayName"];
    }
    
    if (self.selectMulti) {
        NSOrderedSet *selections = (NSOrderedSet*)[self getVariable:self.selectionVariable];
        if (selections && [selections containsObject:managedObject]) {
            _cell.accessoryType = UITableViewCellAccessoryCheckmark;
            _cell.editingAccessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            _cell.accessoryType = UITableViewCellAccessoryNone;
            _cell.editingAccessoryType = UITableViewCellAccessoryNone;
        }
    } else {
        _cell.accessoryType = UITableViewCellAccessoryNone;
        _cell.editingAccessoryType = UITableViewCellAccessoryNone;
    }
}

- (NSFetchedResultsController *)createFetchedResultsController {
	NSManagedObjectContext *udContext = [iStressLessAppDelegate instance].udManagedObjectContext;

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:self.entityName inManagedObjectContext:udContext];
	if (self.fetchPredicate) [fetchRequest setPredicate:self.fetchPredicate];
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchBatchSize:100];

    NSMutableArray *sortDescriptors = [NSMutableArray array];
    NSString *sortOrder = [self.content getExtraString:@"sortOrder"];
//    [sortDescriptors addObject:[NSSortDescriptor sortDescriptorWithKey:@"section" ascending:TRUE]];
    if (sortOrder) {
        NSArray *components = [sortOrder componentsSeparatedByString:@","];
        for (NSString *c in components) {
            c = [c stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            NSArray *subcomponents = [c componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            NSString *property = [subcomponents objectAtIndex:0];
            BOOL ascending = TRUE;
            if (subcomponents.count > 1) {
                if ([[[subcomponents objectAtIndex:1] uppercaseString] isEqualToString:@"DESC"]) {
                    ascending = FALSE;
                }
            }
            [sortDescriptors addObject:[NSSortDescriptor sortDescriptorWithKey:property ascending:ascending]];
        }
    }

    if (sortDescriptors.count == 0) {
        [sortDescriptors addObject:[NSSortDescriptor sortDescriptorWithKey:@"displayName" ascending:TRUE]];
    }
    [fetchRequest setSortDescriptors:sortDescriptors];
    self.sortDescriptors = sortDescriptors;

    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:udContext sectionNameKeyPath:nil cacheName:nil];
    aFetchedResultsController.delegate = self;
    [fetchRequest release];
    
    NSError *error = nil;
    if (![aFetchedResultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return aFetchedResultsController;
}

@end
