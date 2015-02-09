//
//  FavoritesListViewController.h
//  iStressLess
//


//

#import <Foundation/Foundation.h>
#import "ContentListViewController.h"
#import "TreeViewCell.h"
#import "ATSDragToReorderTableViewController.h"

@interface TreeView : ATSDragToReorderTableViewController <TreeViewCellDelegate,ATSDragToReorderTableViewControllerDelegate,ATSDragToReorderTableViewControllerDraggableIndicators> {
    NSMutableArray *_flattenedItems;
}

@property (nonatomic, retain) NSString *selectionVariable;
@property (nonatomic, retain) NSString *entityName;
@property (nonatomic, retain) NSManagedObject *root;
@property (nonatomic) int rootLevel;
@property (nonatomic, readonly) NSArray *flattenedItems;
@property (nonatomic, retain) NSString *cellType;
@property (nonatomic) BOOL movingItemExpanded;
@property (nonatomic) BOOL editMode;
@property (nonatomic) BOOL topLevel;
@property (nonatomic, retain) TreeViewCell *movingCell;
@property (nonatomic, retain) TreeViewCell *sizingCell;
@property (nonatomic) int editingRow;
@property (nonatomic, retain) TreeViewCell *editingCell;
@property (nonatomic, retain) NSManagedObject *movingItem;
@property (nonatomic, retain) NSManagedObjectContext *privateContext;
@property (nonatomic, retain) NSManagedObjectContext *demoContext;


@end
