//
//  NavController.h
//  coachlib
//
//  Copyright (c) 2012 Department of Veteran's Affairs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ContentViewController.h"
#import "GNavigationController.h"

@interface NavController : ContentViewController <UINavigationBarDelegate,UINavigationControllerDelegate> {
    BOOL guard;
    BOOL disableBack;
}

@property (nonatomic,retain) UINavigationBar *navBar;
@property (nonatomic,retain) UINavigationBar *ownedNavBar;
@property (nonatomic,retain) GNavigationController *childNavController;
@property (nonatomic,readonly) Content* rootContent;

-(void)updateNavigationItemsAnimated:(BOOL)animated;
- (void) replaceTopControllerWith:(ContentViewController*)cvc;
- (void) pushChild:(ContentViewController*)cvc animated:(BOOL)animated;
- (void) pushChild:(ContentViewController*)cvc andRemoveOld:(BOOL)removeOld animated:(BOOL)animated;

@end
