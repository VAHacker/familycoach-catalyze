//
//  FavoritesListViewController.h
//  iStressLess
//


//

#import <Foundation/Foundation.h>
#import "ContentListViewController.h"

@interface PickOneController : ContentListViewController {
}

@property (nonatomic, retain) Content *itemContent;
@property (nonatomic, retain) NSString *selectionVariable;

@end
