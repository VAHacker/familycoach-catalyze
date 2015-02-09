//
//  FavoritesListViewController.h
//  iStressLess
//


//

#import <Foundation/Foundation.h>
#import "ContentListViewController.h"

@interface PickMultiController : ContentListViewController {
}

@property (nonatomic, retain) Content *itemContent;
@property (nonatomic, retain) NSString *selectionVariable;
@property (nonatomic, retain) UIFont *font;

@end
