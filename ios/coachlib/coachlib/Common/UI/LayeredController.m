//
//  SegmentedToggleController.m
//  coachlib
//
//  Copyright (c) 2012 Department of Veteran's Affairs. All rights reserved.
//

#import "LayeredController.h"
#import "iStressLessAppDelegate.h"
#import "GWebView.h"

@implementation LayeredController

- (BOOL)navigateToChildController:(ContentViewController *)childController {
    if (childController == topController) return TRUE;
    [childController preloadAndThen:^{
        UIView *toRemove = nil;
        if (topController) {
            if (topController.view.superview == topView) {
                toRemove = [topController.view retain];
            } else {
                [self dismissModalViewControllerAnimated:TRUE];
            }
            [topController release];
            topController = nil;
        }

        childController.view.frame = topView.bounds;
//        [childController.view layoutIfNeeded];
        if (toRemove) {
//            [UIView transitionFromView:toRemove toView:childController.view duration:0.25 options:UIViewAnimationOptionTransitionFlipFromLeft  completion:NULL];
            [toRemove removeFromSuperview];
            [topView insertSubview:childController.view atIndex:0];
        } else {
            [topView insertSubview:childController.view atIndex:0];
        }
        [toRemove release];
        topController = childController;
        [topController retain];
        [self updateContentVisibilityForChildren];
    }];
    
    return TRUE;
/*
    int i = 0;
    for (ContentViewController *c in rootList) {
        if (childController == c) {
            tabBarController.selectedIndex = i;
            break;
        }
        i++;
    }
*/
}

-(void) gatherNavigationItems:(NSMutableArray *)items {
    if (self.beingRemoved) return;
    if (topController) {
        [topController gatherNavigationItems:items];
    } else {
        [super gatherNavigationItems:items];
    }
}

- (BOOL)branchNavigateToContentWithPath:(NSArray *)path startingAt:(int)index withData:(NSDictionary *)data {
    Content *next = [path objectAtIndex:index];
    if (topController && (topController.content == next)) return FALSE;
    return [self navigateToContentWithPath:path startingAt:index withData:data];
}

-(BOOL)navigateToContentWithPath:(NSArray *)path startingAt:(int)index withData:(NSDictionary *)data {
    Content *next = [path objectAtIndex:index];
    for (ContentViewController *cvc in self.childContentControllers) {
        if (cvc.content == next) {
            BOOL r = [self navigateToChildController:cvc];
            if (!r) return r;
            if (index < path.count-1) {
                return [cvc navigateToContentWithPath:path startingAt:index+1 withData:data];
            }
            return TRUE;
        }
    }
    
    if (self.masterController) {
        BOOL r = [self.masterController navigateToContentWithPath:path startingAt:index from:self withData:data];
        if (r) return r;
    }
    
//    NSLog(@"%@",next);
    if (topController.content == next) {
        if (index < path.count-1) {
            return [topController navigateToContentWithPath:path startingAt:index+1 withData:data];
        }
        return TRUE;
    } else {
        if ([self.content.children containsObject:next]) {
            NSString *style = [next getExtraString:@"layerStyle"];
            if (style && [style isEqualToString:@"modal"]) {
                ContentViewController *controller = [next getViewController];
                if (self.presentedViewController) {
                    [self dismissModalViewControllerAnimated:TRUE];
                }
                
                [controller preloadAndThen:^{
                    [self presentViewController:controller animated:TRUE completion:^{
                        if (topController.view.superview == topView) {
                            [topController.view removeFromSuperview];
                        } else if (topController.navigationController.view.superview == topView) {
                            [topController.navigationController.view removeFromSuperview];
                        }
                        [topController release];
                        topController = controller;
                        [topController retain];
                        [self updateContentVisibilityForChildren];
                        if (index < path.count-1) {
                            [controller navigateToContentWithPath:path startingAt:index+1 withData:data];
                        }
                    }];
                }];
            }
            
            return TRUE;
        }
    }
    
    return FALSE;
}

-(BOOL) dispatchContentEvent:(ContentEvent *)event {
    return [topController dispatchContentEvent:event];
}

-(UINavigationItem *)navigationItem {
    if (topController) return topController.navigationItem;
    return [super navigationItem];
}

-(void)updateContentVisibilityForChild:(ContentViewController *)child {
    child.contentVisible = self.contentVisible && (child == topController);
}

- (void)loadView {
    topController = nil;
    [self configureMetaContent];
    
    for (Content *child in self.content.properChildren) {
        NSString *style = [child getExtraString:@"layerStyle"];
//        NSLog(@"%@",child);
        if (style && [style isEqualToString:@"modal"]) {
            // skip it and instantiate on demand
            continue;
        } else if ([child getExtraString:@"predicate"]) {
            BOOL val = [self evalJSPredicate:[child getExtraString:@"predicate"]];
            if (!val) continue;
        }
        
        ContentViewController *c = [child getViewController];
        c.masterController = self;
        [self addChildContentController:c];
//        [self addChildViewController:nc?nc:c];
    };
    
    CGRect r = [[UIScreen mainScreen] bounds];
	topView = [[UIView alloc] initWithFrame:r];
	self.view = topView;

    [self navigateToChildController:[self.childContentControllers objectAtIndex:0]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)dealloc {
    [topController release];
    
    [super dealloc];
}

@end
