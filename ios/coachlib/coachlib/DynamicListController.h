//
//  FavoritesListViewController.h
//  iStressLess
//


//

#import <Foundation/Foundation.h>
#import "ContentListViewController.h"

#define ADD_STYLE_NONE 0
#define ADD_STYLE_FIRST 1
#define ADD_STYLE_LAST 2
#define ADD_STYLE_EXTERNAL 3

@interface DynamicListController : ContentListViewController {
    int addStyle;
}

@property (nonatomic, retain) NSArray *sortDescriptors;
@property (nonatomic, retain) NSString *selectionVariable;
@property (nonatomic, retain) NSString *entityName;
@property (nonatomic, retain) NSString *cellType;
@property (nonatomic,) BOOL addWhenNotEditing;
@property (nonatomic, retain) NSPredicate *fetchPredicate;
@property (nonatomic) BOOL selectMulti;
@property (nonatomic, retain) NSManagedObjectContext *privateContext;
@property (nonatomic, retain) NSManagedObjectContext *demoContext;

@end
