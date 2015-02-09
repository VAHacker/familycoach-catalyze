//
//  FavoritesListViewController.m
//  iStressLess
//


//

#import "TreeView.h"
#import "iStressLessAppDelegate.h"
#import "ExerciseRef.h"
#import "ThreeLabelTableViewCell.h"
#import "TreeViewCell.h"
#import "GTreeView.h"
#import "Goal.h"

@interface AddMarker : NSObject
@property (nonatomic, retain) NSManagedObject *addTo;
@end

@implementation AddMarker
-(BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[AddMarker class]]) {
        AddMarker *o = (AddMarker*)object;
        if (o.addTo == self.addTo) return TRUE;
        return [o.addTo isEqual:self.addTo];
    }
    return FALSE;
}
@end

@implementation TreeView

-(void)updateCellAtIndexPath:(NSIndexPath*)indexPath {
    TreeViewCell *cell;
    if (indexPath.row >= [self.tableView numberOfRowsInSection:0]) return;
    if (indexPath.row < 0) return;
    cell = (TreeViewCell*)[self.tableView cellForRowAtIndexPath:indexPath];
    if (cell) [self configureCell:cell atIndexPath:indexPath];
}

-(void)updateCells {
    for (int i=0;i<self.flattenedItems.count;i++){
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        [self updateCellAtIndexPath:indexPath];
    }
}

-(void) startEditing:(id)origin {
    [self.tableView beginUpdates];
    self.tableView.editing = TRUE;
    self.editMode = TRUE;
    [self updateFlattenedItems];
    [self.tableView endUpdates];
    
    [self updateCells];

    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneEditing:)] autorelease];
}

-(void) doneEditing:(id)origin {
    [self.tableView beginUpdates];
    self.tableView.editing = FALSE;
    self.editMode = FALSE;
    [self updateFlattenedItems];
    [self.tableView endUpdates];

    [self updateCells];

    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(startEditing:)] autorelease];
}

-(void)publishTreeState {
    if (self.topLevel) {
        NSOrderedSet *children = ((NSOrderedSet*)[self.root valueForKey:@"children"]);
        BOOL treeHasItems = (children.count > 0);
        NSNumber *oldTreeHasItemsNumber = (NSNumber*)[self getVariable:@"treeHasItems"];
        BOOL oldTreeHasItems = [oldTreeHasItemsNumber boolValue];
        if (treeHasItems != oldTreeHasItems) {
            [self setVariable:@"treeHasItems" to:[NSNumber numberWithBool:treeHasItems]];
        }
    }
}

-(void) relayout {
    [super relayout];
    [self.headerView setNeedsLayout];
    [self.headerView layoutIfNeeded];
    [self.headerView setToPreferredHeight];
    self.tableView.tableHeaderView = nil;
    self.tableView.tableHeaderView = self.headerView;
    [self.tableView setNeedsLayout];
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

-(void) configureFromContent {
    
    self.editingRow = -1;
    self.scoping = TRUE;
    self.editingCell = nil;
    self.dragDelegate = self;
    self.indicatorDelegate = self;
    self.selectionVariable = [self.content getExtraString:@"selectionVariable"];
    self.entityName = [self.content getExtraString:@"entityName"];
    self.cellType = [self.content getExtraString:@"cellType"];
    
    self.root = (NSManagedObject*)[self getVariable:@"@binding"];
    if (!self.root) {
        NSManagedObjectContext *udContext = [iStressLessAppDelegate instance].udManagedObjectContext;
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:self.entityName];
        [fetchRequest setFetchBatchSize:1];
        NSString *rootName = [self.content getExtraString:@"root"];
        if (rootName) {
            [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"(parent == NULL) AND (level == 0) AND (displayName == %@)",rootName]];
        } else {
            self.topLevel = TRUE;
            [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"(parent == NULL) AND (level == 0) AND (displayName == 'ROOT')"]];
        }
        NSArray *a = [udContext executeFetchRequest:fetchRequest error:NULL];
        if (a.count) {
            self.root = [a objectAtIndex:0];
            if (rootName) {
                self.demoContext = [[[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType] autorelease];
                self.demoContext.parentContext = self.root.managedObjectContext;
                self.root = [self.demoContext objectWithID:[self.root objectID]];
            }
        } else {
            self.root = [NSEntityDescription insertNewObjectForEntityForName:self.entityName inManagedObjectContext:udContext];
            [self.root setValue:@"ROOT" forKey:@"displayName"];
            [self.root setValue:@0 forKey:@"level"];
            [self.root setValue:@1 forKey:@"expanded"];
            [udContext save:NULL];
        }
    }
    
    self.rootLevel = [[self.root valueForKey:@"level"] intValue];
    [self publishTreeState];
    
    [super configureFromContent];
    self.hideSingleSectionHeader = TRUE;

    self.editing = TRUE;
    UITableView *tv = self.tableView;
    tv.editing = self.editMode = FALSE;//self.isInlineContent;
    tv.separatorStyle = UITableViewCellSeparatorStyleNone;
    tv.separatorColor = [UIColor clearColor];
    tv.allowsSelectionDuringEditing = TRUE;
    
//    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(startEditing:)] autorelease];
}

-(void)flattenObject:(NSManagedObject*)obj into:(NSMutableArray*)a {
    [a addObject:obj];
    BOOL expanded = FALSE;
    if (self.movingItem) {//self.tableView.editing) {
//        expanded = [((NSNumber*)[obj valueForKey:@"expanded"]) boolValue];
        expanded = (obj != self.movingItem);
    } else {
        expanded = [((NSNumber*)[obj valueForKey:@"expanded"]) boolValue];
    }

    expanded = expanded || UIAccessibilityIsVoiceOverRunning();
    
    if (expanded) {
        BOOL addedAny = FALSE;
        for (NSManagedObject *child in ((NSOrderedSet*)[obj valueForKey:@"children"])) {
            NSLog(@"flattening %@ (parent %@)",child,obj);
            [self flattenObject:child into:a];
            addedAny = TRUE;
        }
        if ((self.editMode && addedAny) || self.movingItem) {
            AddMarker *add = [[[AddMarker alloc] init] autorelease];
            add.addTo = obj;
            [a addObject:add];
        }
    }
}

-(void)updateFlattenedItems {
    [self.tableView beginUpdates];

    NSArray *oldList = _flattenedItems;
    _flattenedItems = nil;
    NSArray *newList = [self flattenedItems];

    int oldCursor = 0;
    int newCursor = 0;
    NSMutableArray *toAdd = [NSMutableArray array];
    NSMutableArray *toAddFade = [NSMutableArray array];
    NSMutableArray *toRemove = [NSMutableArray array];
    NSMutableArray *toRemoveFade = [NSMutableArray array];
    while (true) {
        NSObject *oldItem = (oldCursor >= oldList.count) ? 0 : [oldList objectAtIndex:oldCursor];
        NSObject *newItem = (newCursor >= newList.count) ? 0 : [newList objectAtIndex:newCursor];
        if (!oldItem && !newItem) break;
        if ([oldItem isEqual:newItem]) {
            oldCursor++;
            newCursor++;
            continue;
        } else {
            if (!oldItem || [newList containsObject:oldItem]) {
                // There have been new items inserted before the one we are looking for
                if (!newItem) {
                    NSLog(@"oldList = %@",oldList);
                    NSLog(@"newList = %@",newList);
                    NSLog(@"ruh roh");
                    [self.tableView reloadData];
                    [self.tableView endUpdates];
                    [((GTableView*)self.tableView) setContentSizeChanged];
                    return;
                }
                if (newCursor == 0) {
                    [toAddFade addObject:[NSIndexPath indexPathForRow:newCursor inSection:0]];
                } else {
                    [toAdd addObject:[NSIndexPath indexPathForRow:newCursor inSection:0]];
                }
                newCursor++;
            } else {
                // The old item was removed
                if (oldCursor == 0) {
                    [toRemoveFade addObject:[NSIndexPath indexPathForRow:oldCursor inSection:0]];
                } else {
                    [toRemove addObject:[NSIndexPath indexPathForRow:oldCursor inSection:0]];
                }
                oldCursor++;
            }
        }
    }

    NSLog(@"oldList = %@",oldList);
    NSLog(@"newList = %@",newList);

    [oldList release];

    if (toAdd.count) [self.tableView insertRowsAtIndexPaths:toAdd withRowAnimation:UITableViewRowAnimationTop];
    if (toAddFade.count) [self.tableView insertRowsAtIndexPaths:toAddFade withRowAnimation:UITableViewRowAnimationFade];
    if (toRemove.count) [self.tableView deleteRowsAtIndexPaths:toRemove withRowAnimation:UITableViewRowAnimationTop];
    if (toRemoveFade.count) [self.tableView deleteRowsAtIndexPaths:toRemoveFade withRowAnimation:UITableViewRowAnimationFade];
    
    [self.tableView setNeedsDisplay];
    [self.tableView endUpdates];
    [((GTableView*)self.tableView) setContentSizeChanged];
}

-(NSArray *)flattenedItems {
    if (_flattenedItems == nil) {
        [self fetchedResultsController];
        NSOrderedSet *roots = nil;
//        if (self.selectionVariable) {
//            roots = (NSOrderedSet*)[self getVariable:self.selectionVariable];
//        } else {
            roots = (NSOrderedSet*)[self.root valueForKey:@"children"];
//        }
        
        NSMutableArray *a = [NSMutableArray array];
        for (NSManagedObject *obj in roots) {
            [self flattenObject:obj into:a];
        }
        if (!self.movingCell) {
            AddMarker *add = [[[AddMarker alloc] init] autorelease];
            add.addTo = self.root;
            [a addObject:add];
        }
        _flattenedItems = a;
        [_flattenedItems retain];
    }
    
    return _flattenedItems;
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
/*
    if (_flattenedItems) {
        [_flattenedItems release];
        _flattenedItems = nil;
    }
*/ 
//    [super controllerDidChangeContent:controller];
}

- (NSManagedObject*)managedObjectForIndexPath:(NSIndexPath*)indexPath {
    NSManagedObject *managedObject = [self.flattenedItems objectAtIndex:indexPath.row];
    return managedObject;
}

- (void)voiceOverStatusChanged {
    [self updateFlattenedItems];
    [self updateCells];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(voiceOverStatusChanged) name:UIAccessibilityVoiceOverStatusChanged object:nil];
    
    [self publishTreeState];
    [_flattenedItems release];
    _flattenedItems = nil;
    [self.tableView reloadData];
    NSManagedObjectContext *udContext = [iStressLessAppDelegate instance].udManagedObjectContext;
    [udContext save:NULL];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self];

    NSManagedObjectContext *udContext = [iStressLessAppDelegate instance].udManagedObjectContext;
    [udContext save:NULL];
}

-(void)cellEditingEnded:(TreeViewCell *)cell {
    if (self.editingCell == cell) {
        self.editingRow = -1;
        self.editingCell = nil;
        
        if ([cell.item isKindOfClass:[AddMarker class]]) {
            AddMarker *marker = (AddMarker*)cell.item;
            NSManagedObject *newObject = [NSEntityDescription insertNewObjectForEntityForName:self.entityName inManagedObjectContext:self.root.managedObjectContext];
            NSManagedObject *parent = marker.addTo;
            NSMutableOrderedSet *children = [parent valueForKey:@"children"];
            [newObject setValue:parent forKey:@"parent"];
            [newObject setValue:@1 forKey:@"expanded"];
            [children addObject:newObject];
            int level = [((NSNumber*)[parent valueForKey:@"level"]) intValue]+1;
            [newObject setValue:[NSNumber numberWithInt:level] forKey:@"level"];
            [newObject setValue:cell.labelText forKey:@"displayName"];
            
            [_flattenedItems release];
            _flattenedItems = nil;
            [self.tableView reloadData];

            [self publishTreeState];
        } else {
            NSManagedObject *existingObject = (NSManagedObject*)cell.item;
            [existingObject setValue:cell.labelText forKey:@"displayName"];
        }
        
        [self.root.managedObjectContext save:NULL];
    }
}

- (void)addRowAt:(NSIndexPath *)indexPath {
    NSObject *obj = [self.flattenedItems objectAtIndex:indexPath.row];
    if ([obj isKindOfClass:[AddMarker class]]) {
        TreeViewCell *cell = (TreeViewCell*)[self.tableView cellForRowAtIndexPath:indexPath];
        cell.labelFont = [UIFont systemFontOfSize:17];
        cell.doneState = 0;
        cell.expandoVisible = TRUE;
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.editingAccessoryType = UITableViewCellAccessoryNone;
        self.editingRow = indexPath.row;
        self.editingCell = cell;
        cell.labelText = nil;
        
        int level = [((NSNumber*)[self.root valueForKey:@"level"]) intValue];
        if (level == 0) {
            cell.editingItemLabel.placeholder = @"Short goal title";
        } else {
            cell.editingItemLabel.placeholder = @"Short task title";
        }
        cell.hasChildren = FALSE;
        cell.indentationWidth = 15;
        cell.editingTitle = TRUE;
        return;
        
        Content *addContent = [self.content getChildByName:@"@add"];
        if (addContent) {
            AddMarker *marker = (AddMarker*)obj;
            self.privateContext = [[[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType] autorelease];
            self.privateContext.parentContext = self.root.managedObjectContext;
            
            NSManagedObject *parent = [self.privateContext objectWithID:[marker.addTo objectID]];
            NSManagedObject *newObject = [NSEntityDescription insertNewObjectForEntityForName:self.entityName inManagedObjectContext:self.privateContext];
            NSMutableOrderedSet *children = [parent valueForKey:@"children"];
            NSLog(@"children(%d)=%@",children.count,[children array]);
            [newObject setValue:parent forKey:@"parent"];
            [newObject setValue:@1 forKey:@"expanded"];
            [children addObject:newObject];
            int level = [((NSNumber*)[parent valueForKey:@"level"]) intValue]+1;
            [newObject setValue:[NSNumber numberWithInt:level] forKey:@"level"];

            ContentViewController *cvc = addContent.getViewController;
            [cvc setVariable:@"@binding" to:newObject];
            [cvc setVariable:@"formOperation" to:@"Add"];
            
            [self navigateToNext:cvc];
        }
    }
}

-(void)cellSizeChanged:(TreeViewCell *)cell {
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    int row = indexPath.row;
//    int count = self.flattenedItems.count;
	[tableView deselectRowAtIndexPath:(NSIndexPath *)indexPath animated:TRUE];

    NSObject *obj = [self.flattenedItems objectAtIndex:indexPath.row];
    if ([obj isKindOfClass:[AddMarker class]]) {
        [self addRowAt:indexPath];
    } else {
        NSManagedObject *selectedObject = (NSManagedObject*)obj;
        Content *addContent = [self.content getChildByName:@"@add"];
        if (addContent) {
            self.privateContext = [[[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType] autorelease];
            self.privateContext.parentContext = self.root.managedObjectContext;
            selectedObject = [self.privateContext objectWithID:[selectedObject objectID]];
            
            NSLog(@"binding to %@",selectedObject);
            
            ContentViewController *cvc = addContent.getViewController;
            [cvc setVariable:@"@binding" to:selectedObject];
            [cvc setVariable:@"formOperation" to:@"Edit"];
            [self navigateToNext:cvc];
        }
    }
}
/*
-(NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSObject *obj = [self.flattenedItems objectAtIndex:indexPath.row];
    int baseLevel = [((NSNumber*)[self.root valueForKey:@"level"]) intValue];
    if ([obj isKindOfClass:[AddMarker class]]) {
        AddMarker *marker = (AddMarker*)obj;
        if (marker.addTo) {
            return [((NSNumber*)[marker.addTo valueForKey:@"level"]) intValue]-baseLevel;
        } else {
            return 0;
        }
    } else {
        NSManagedObject *selectedObject = (NSManagedObject*)obj;
        return [((NSNumber*)[selectedObject valueForKey:@"level"]) intValue]-baseLevel-1;
    }
}
*/
-(BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return TRUE;
}

-(void)setTreeLevels:(NSManagedObject*)mo {
    NSNumber *level = [mo valueForKey:@"level"];
    NSMutableOrderedSet *children = [mo valueForKey:@"children"];
    level = [NSNumber numberWithInt:[level intValue]+1];
    for (NSManagedObject *child in children) {
        [child setValue:level forKey:@"level"];
        [self setTreeLevels:child];
    }
    
}

-(void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    int srcRow = sourceIndexPath.row;
    int row = destinationIndexPath.row;
    if (row != srcRow) {
        NSManagedObject *movingObj = (NSManagedObject*)[self.flattenedItems objectAtIndex:sourceIndexPath.row];
        TreeViewCell *srcCell = (TreeViewCell*)[self.tableView cellForRowAtIndexPath:sourceIndexPath];
//        TreeViewCell *destCell = (TreeViewCell*)[self.tableView cellForRowAtIndexPath:destinationIndexPath];
        
        int origRow = row;
        if (srcRow < row) row++;
        NSManagedObject *parent=nil,*oldParent = [movingObj valueForKey:@"parent"];
        NSObject *obj = (row < self.flattenedItems.count-1) ? [self.flattenedItems objectAtIndex:row] : nil;
        NSNumber *level;
        if (obj) {
            if ([obj isKindOfClass:[AddMarker class]]) {
                AddMarker *marker = (AddMarker*)obj;
                parent = marker.addTo;
                level = [NSNumber numberWithInt:[[marker.addTo valueForKey:@"level"] intValue]+1];
            } else {
                parent = [obj valueForKey:@"parent"];
                level = [obj valueForKey:@"level"];
            }
        } else {
            parent = self.root;
            level = [NSNumber numberWithInt:[[parent valueForKey:@"level"] intValue]+1];
        }

        NSMutableOrderedSet *children = [parent valueForKey:@"children"];
        int index = obj ? [children indexOfObject:obj] : NSNotFound;
        if (index == NSNotFound) index = children.count;
        if (parent != oldParent) {
            [movingObj setValue:parent forKey:@"parent"];
            [children addObject:movingObj];
            [children moveObjectsAtIndexes:[NSIndexSet indexSetWithIndex:children.count-1] toIndex:index];
            [parent setValue:children forKey:@"children"];
            [parent.managedObjectContext refreshObject:parent mergeChanges:TRUE];
        } else {
            int oldIndex = [children indexOfObject:movingObj];
            if (oldIndex < index) index--;
            [children moveObjectsAtIndexes:[NSIndexSet indexSetWithIndex:oldIndex] toIndex:index];
            [parent.managedObjectContext refreshObject:parent mergeChanges:TRUE];
        }
        [movingObj setValue:level forKey:@"level"];
        [self setTreeLevels:movingObj];

        int baseLevel = [((NSNumber*)[self.root valueForKey:@"level"]) intValue];
        srcCell.indentationLevel = [level intValue]-baseLevel-1;
        if (srcRow < row) {
            [_flattenedItems insertObject:movingObj atIndex:row];
            [_flattenedItems removeObjectAtIndex:srcRow];
        } else {
            [_flattenedItems removeObjectAtIndex:srcRow];
            [_flattenedItems insertObject:movingObj atIndex:row];
        }
        
        if (self.draggedCell) [self configureCell:self.draggedCell atIndexPath:[NSIndexPath indexPathForRow:origRow inSection:0]];
    }
}

- (UITableViewCell *)cellIdenticalToCellAtIndexPath:(NSIndexPath *)indexPath forDragTableViewController:(ATSDragToReorderTableViewController *)dragTableViewController {
    
    TreeViewCell *inPlaceCell = (TreeViewCell*)[self.tableView cellForRowAtIndexPath:indexPath];
    TreeViewCell *cell = (TreeViewCell*)[self tableView:self.tableView cellForRowAtIndexPath:indexPath];
    cell.indentationLevel = inPlaceCell.indentationLevel;
    cell.lastInParent = inPlaceCell.lastInParent;
    [cell willTransitionToState:UITableViewCellStateShowingEditControlMask];
    cell.editing = inPlaceCell.editing;
    cell.shouldIndentWhileEditing = TRUE;
    [cell didTransitionToState:UITableViewCellStateShowingEditControlMask];
    
//    cell.editingStyle = inPlaceCell.editingStyle;
    return cell;
}

-(NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath {
/*
    //    int srcRow = sourceIndexPath.row;
    int row = proposedDestinationIndexPath.row;
    if (row >= self.flattenedItems.count-1) {
        NSObject *obj = [self.flattenedItems objectAtIndex:row];
        if ([obj isKindOfClass:[AddMarker class]]) {
            return [NSIndexPath indexPathForRow:self.flattenedItems.count-2 inSection:0];
        }
    }
    */
    return proposedDestinationIndexPath;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    NSObject *obj = [self.flattenedItems objectAtIndex:indexPath.row];
    if ([obj isKindOfClass:[AddMarker class]]) {
        return FALSE;
    }
    return TRUE;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return TRUE;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSObject *obj = [self.flattenedItems objectAtIndex:indexPath.row];
    if ([obj isKindOfClass:[AddMarker class]]) {
        return UITableViewCellEditingStyleInsert;
    }

    return UITableViewCellEditingStyleDelete;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return self.movingItem ? 568 : 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    int row = indexPath.row;
    NSObject *obj = [self.flattenedItems objectAtIndex:row];
    if (self.movingCell && [obj isKindOfClass:[AddMarker class]]) {
        return 22;
    } else {
        TreeViewCell *sizingCell = nil;
        if (row == self.editingRow) {
            sizingCell = self.editingCell;
        }
        if (!sizingCell) {
            if (!self.sizingCell) {
                self.sizingCell = (TreeViewCell*)[self tableView:self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];
                CGRect r = CGRectMake(0, 0, self.tableView.bounds.size.width, 44);
                self.sizingCell.frame = r;
            } else {
                [self configureCell:self.sizingCell atIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];
            }
            sizingCell = self.sizingCell;
        }
        
        return [sizingCell getPreferredHeight];
    }
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.flattenedItems.count;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    int row = indexPath.row;
//    int count = [self tableView:tableView numberOfRowsInSection:indexPath.section];
    NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = nil;//[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[self createCell:cellIdentifier] autorelease];
    }
    // Configure the cell.
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

-(UITableViewCell *)createCell:(NSString*)typeIdentifier {
    NSArray *a = [[NSBundle mainBundle] loadNibNamed:@"TreeViewCell" owner:self options:nil];
    return [[a objectAtIndex:0] retain];
//    return [[TreeViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:typeIdentifier];
}

-(NSIndexPath*)beforeMove:(NSIndexPath*)indexPath {
    TreeViewCell *cell = (TreeViewCell*)[self.tableView cellForRowAtIndexPath:indexPath];
    CGRect beforeRect = [self.tableView rectForRowAtIndexPath:indexPath];
    
    [self.tableView beginUpdates];
    self.movingItem = cell.item;
    self.movingCell = cell;
    [self updateFlattenedItems];
    [self.tableView endUpdates];
    [self updateCells];
    
    NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:[self.flattenedItems indexOfObject:cell.item] inSection:0];

    CGRect afterRect = [self.tableView rectForRowAtIndexPath:newIndexPath];

    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
//    CGRect afterRect = beforeRect;
//    afterRect.origin.y += 44*(newIndexPath.row - indexPath.row);
    if (self.isInlineContent) {
        UIView *v = self.tableView.superview;
        while (v) {
            if ([v isKindOfClass:[UIScrollView class]]) {
                UIScrollView *sv = (UIScrollView*)v;
                CGPoint offs = sv.contentOffset;
                offs.y = offs.y + afterRect.origin.y - beforeRect.origin.y;
                sv.contentOffset = offs;
                break;
            }
            v = v.superview;
        }
    } else {
        CGPoint offs = self.tableView.contentOffset;
        offs.y = offs.y + afterRect.origin.y - beforeRect.origin.y;
        self.tableView.contentOffset = offs;
    }
    [UIView commitAnimations];
    
    return newIndexPath;
}

- (void)dragTableViewController:(ATSDragToReorderTableViewController *)dragTableViewController didEndDraggingToRow:(NSIndexPath *)destinationIndexPath {
    self.movingItem = nil;
    self.movingCell = nil;
    [self updateFlattenedItems];
    [self updateCells];
    [[iStressLessAppDelegate instance].udManagedObjectContext save:NULL];
}

-(void)itemExpanded:(id)item {
    NSManagedObject *obj = item;
    [obj setValue:[NSNumber numberWithBool:TRUE] forKey:@"expanded"];
    [self updateFlattenedItems];
    [self updateCells];
}

-(void)itemCollapsed:(id)item {
    NSManagedObject *obj = item;
    [obj setValue:[NSNumber numberWithBool:FALSE] forKey:@"expanded"];
    [self updateFlattenedItems];
    [self updateCells];
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleInsert) {
        [self addRowAt:indexPath];
    } else if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSManagedObjectContext *udContext = self.root.managedObjectContext;
        NSManagedObject *obj = [self.flattenedItems objectAtIndex:indexPath.row];
        NSManagedObject *parent = [obj valueForKey:@"parent"];
        NSMutableOrderedSet *children = [parent valueForKey:@"children"];
        [children removeObject:obj];
        [udContext deleteObject:obj];
        [udContext refreshObject:parent mergeChanges:TRUE];
        [[iStressLessAppDelegate instance].udManagedObjectContext save:NULL];
        [self updateFlattenedItems];
        [self updateCells];
        [self publishTreeState];
    }
}

-(NSManagedObject*)parentOf:(NSObject*)obj {
    if ([obj isKindOfClass:[AddMarker class]]) {
        AddMarker *marker = (AddMarker*)obj;
        return marker.addTo;
    } else {
        NSManagedObject *managedObject = (NSManagedObject*)obj;
        NSManagedObject *parent=[managedObject valueForKey:@"parent"];
        return parent;
    }
}

-(BOOL)dueOrHasAnyDueChildren:(Goal*)goal {
    if (goal.dueDate && ([goal.dueDate compare:[NSDate date]] == NSOrderedAscending)) return TRUE;
    for (Goal *child in goal.children) {
        BOOL r = [self dueOrHasAnyDueChildren:child];
        if (r) return r;
    }
    
    return FALSE;
}

-(int)computeDoneState:(Goal*)goal {
    if (goal.children && goal.children.count) {
        BOOL anyDoneness = FALSE;
        int state = 2;
        for (Goal *child in goal.children) {
            int r = [self computeDoneState:child];
            if (r < 2) state = 1;
            if (r > 0) anyDoneness = TRUE;
        }
        if (!anyDoneness) return 0;
        return state;
    } else {
        return [goal.doneState intValue];
    }
}

- (void)configureCell:(UITableViewCell *)_cell atIndexPath:(NSIndexPath *)indexPath {
    int row = indexPath.row;
//    int count = self.flattenedItems.count;
    TreeViewCell *cell = (TreeViewCell*)_cell;
    cell.shouldIndentWhileEditing = YES;
    NSObject *obj = [self.flattenedItems objectAtIndex:row];
    NSMutableArray *lastInParent = [NSMutableArray array];
    if ([obj isKindOfClass:[AddMarker class]]) {
        AddMarker *marker = (AddMarker*)obj;
        if (self.movingCell) {
            cell.labelText = nil;
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.editingAccessoryType = UITableViewCellAccessoryNone;
        } else {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
            if (!marker.addTo || (marker.addTo == self.root)) {
                int level = [((NSNumber*)[marker.addTo valueForKey:@"level"]) intValue];
                if (level == 0) {
                    cell.labelText = @"Add goal...";
                } else {
                    cell.labelText = @"Add task...";
                }
            } else {
                cell.labelText = @"Add task...";
            }
        }
        cell.delegate = self;
        cell.item = marker;
        [lastInParent addObject:[NSNumber numberWithBool:TRUE]];
        cell.hasChildren = FALSE;
        cell.labelFont = self.listFont;
        cell.expandoVisible = FALSE;
        cell.indentationWidth = 15;
        cell.doneState = 2;
    } else {
        NSManagedObject *managedObject = (NSManagedObject*)obj;
        NSObject *nextObj = (row >= self.flattenedItems.count-1) ? nil : [self.flattenedItems objectAtIndex:row+1];
        NSManagedObject *parent=[managedObject valueForKey:@"parent"];
        NSMutableOrderedSet *children = [parent valueForKey:@"children"];
        NSMutableOrderedSet *myChildren = [managedObject valueForKey:@"children"];
        Goal *goal = (Goal*)managedObject;
        cell.labelText = [managedObject valueForKey:@"displayName"];
        cell.delegate = nil;
        cell.expanded = [((NSNumber*)[managedObject valueForKey:@"expanded"]) boolValue];
        cell.delegate = self;
        
        cell.doneState = [self computeDoneState:goal];
        //cell.hasAlarm = goal.alarmID != nil;
        cell.isDue = [self dueOrHasAnyDueChildren:goal];

        cell.expandoVisible = TRUE;//myChildren.count > 0;
        cell.hasHiddenChildren = myChildren.count > 0;
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.editingAccessoryType = UITableViewCellAccessoryNone;
        cell.indentationWidth = 15;
        [lastInParent addObject:[NSNumber numberWithBool:(([children indexOfObject:managedObject] == children.count-1) && !self.editMode && !self.movingCell)]];
        if (nextObj) {
            if ([nextObj isKindOfClass:[AddMarker class]]) {
                AddMarker *marker = (AddMarker*)nextObj;
                cell.hasChildren = marker.addTo == managedObject;
            } else {
                NSMutableOrderedSet *myChildren = [managedObject valueForKey:@"children"];
                cell.hasChildren = [myChildren indexOfObject:nextObj] != NSNotFound;
            }
        } else {
            cell.hasChildren = FALSE;
        }
        cell.item = managedObject;
    }
    
    int indentLevel = 0;
    NSManagedObject *parent,*mo = [self parentOf:obj];
    while (mo && ([[self.root valueForKey:@"level"] intValue] != [[mo valueForKey:@"level"] intValue])) {
        parent = [self parentOf:mo];
        NSMutableOrderedSet *children = [parent valueForKey:@"children"];
        [lastInParent insertObject:[NSNumber numberWithBool:(([children indexOfObject:mo] == children.count-1) && !self.editMode && !self.movingCell)] atIndex:0];
        indentLevel++;
        mo = parent;
    }
    cell.indentationLevel = indentLevel;
    cell.lastInParent = lastInParent;
    
//    NSLog(@"cell '%@' = %@",cell.itemLabel.text,lastInParent);
}

-(void)dealloc {
    [_flattenedItems release];
    _flattenedItems = nil;
    [super dealloc];
}

- (void)dragTableViewController:(ATSDragToReorderTableViewController *)dragTableViewController didBeginDraggingAtRow:(NSIndexPath *)dragRow {
    
}

- (void)dragTableViewController:(ATSDragToReorderTableViewController *)dragTableViewController willEndDraggingToRow:(NSIndexPath *)destinationIndexPath {
    
}

@end
