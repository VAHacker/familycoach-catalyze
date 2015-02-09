//
//  FavoritesListViewController.h
//  iStressLess
//


//

#import <Foundation/Foundation.h>
#import "ContentViewController.h"

@interface FormController : ContentViewController {
}

@property (nonatomic, retain) NSString *entityName;
@property (nonatomic, retain) NSManagedObject *binding;
@property (nonatomic, retain) NSManagedObjectContext *privateContext;
@property (nonatomic, retain) NSManagedObjectContext *parentContext;

@end
