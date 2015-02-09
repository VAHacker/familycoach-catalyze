//
//  RootViewController.h
//  iStressLess
//


//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "GNavigationController.h"
#import "BaseExerciseController.h"
#import "LayoutableProxyView.h"

@interface ContentListViewController : ContentViewController <UITableViewDelegate, UITabBarControllerDelegate, NSFetchedResultsControllerDelegate, UITableViewDataSource> {
	
@private
    BOOL hideSingleSectionHeader;
    NSFetchedResultsController *fetchedResultsController_;
	NSString *sectionKey;
	int cellHeight;
	int cellLines;
	BOOL selectOnly;
    BOOL interior;
}

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSString *sectionKey;
@property (nonatomic, retain) LayoutableProxyView *headerView;
@property (nonatomic) BOOL hideSingleSectionHeader;
@property (nonatomic) int cellLines;
@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) UIFont *listFont;

- (UITableView*) createTableView NS_RETURNS_RETAINED;
- (UITableViewCell *)createCell:(NSString*)typeIdentifier NS_RETURNS_RETAINED;
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (NSManagedObject*)managedObjectForIndexPath:(NSIndexPath*)indexPath;
- (BOOL)tableHasSections;

@end
