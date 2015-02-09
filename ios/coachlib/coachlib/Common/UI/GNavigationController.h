//
//  GNavigationController.h
//  iStressLess
//


//

#import <Foundation/Foundation.h>
#import "GNavigationBar.h"
#import "UIAlertView+MKBlockAdditions.h"

@interface BlockNavigationDelegate : NSObject <UINavigationControllerDelegate>
@property (nonatomic,copy) VoidBlock block;
@end

@class ContentViewController;

@interface GNavigationController : UINavigationController <UINavigationControllerDelegate> {
	NSMutableDictionary *variables;
	id selectionDelegate;
}

@property (nonatomic, retain) id selectionDelegate;
@property (nonatomic, retain) BlockNavigationDelegate *internalDelegate;
@property (nonatomic, assign) id<UINavigationControllerDelegate> externalDelegate;

- (void) removeViewController:(UIViewController*)vc;
- (void) removeLastViewController;
- (void) replaceRootViewControllerWith:(UIViewController*)vc;
- (void) insertNewRootViewController:(UIViewController*)vc;
- (void) removeAllPreviousViewControllers;

- (void) flipToNewTopViewController:(UIViewController *)viewController;

- (void) pushViewController:(UIViewController *)viewController animated:(BOOL)animated andRemoveOld:(BOOL)removeOld andThen:(void (^)())afterPush;
- (void) popViewControllerAnimated:(BOOL)animated andThen:(void (^)())afterPop;

- (void) popToViewController:(UIViewController*)popTo animated:(BOOL)animated andThen:(void (^)())afterPop;

- (void) popFromViewController:(UIViewController *)viewController animated:(BOOL)animated;

- (BOOL) onAppSuspend;

@end
