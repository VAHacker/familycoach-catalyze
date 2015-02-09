//
//  NavController.m
//  coachlib
//
//  Copyright (c) 2012 Department of Veteran's Affairs. All rights reserved.
//

#import "iStressLessAppDelegate.h"
#import "NavController.h"
#import "TopNavView.h"
#import "ThemeManager.h"

@implementation NavController

- (void) goBackFrom:(ContentViewController*)src animated:(BOOL)animated {
    if ([self popExecLeaf:src]) return;
    if (self.childNavController) {
        NSMutableArray *a = [NSMutableArray arrayWithArray:self.childNavController.viewControllers];
        int index = [a indexOfObject:src];
        if ((index != NSNotFound) && (index > 0)) {
            [self.childNavController popFromViewController:src animated:animated];
            [self updateNavigationItemsAnimated:animated];
            [self updateContentVisibilityForChildren];
        } else {
            [self goBackAnimated:animated];
        }
    }
}

- (Content*) rootContent {
    return ((ContentViewController*)[self.childNavController.viewControllers objectAtIndex:0]).content;
}

/*
- (void) managedObjectSelected:(NSManagedObject*)mo
                       byChild:(ContentViewController*)child {
    Content *c = (Content*)mo;
    ContentViewController *cvc = c.getViewController;
    if (cvc.shouldExecInsteadOfPush) {
        cvc.masterController = self;
        [self pushExecLeaf:cvc];
    } else {
        [self navigateToNext:cvc from:child animated:TRUE andRemoveOld:FALSE];
    }
}
*/ 

- (void) navigateToNext:(ContentViewController *)next
                   from:(ContentViewController*)from
               animated:(BOOL)animated
           andRemoveOld:(BOOL)removeOld {
    Content *nextContent = nil;
    if (!next) {
        Content *c = from.content;
        NSArray *children = [NSArray arrayWithArray:self.content.properChildren];
        for (Content *candidate in children) {
            if ([candidate isEqual:c]) {
                break;
            }
        }
        int index = [children indexOfObject:c];
        if (index != NSNotFound) {
            if (index == children.count-1) {
                NSLog(@"Next from lastr child?");
            } else {
                while (index < children.count-1) {
                    nextContent = ((Content*)[children objectAtIndex:index+1]);
                    NSString *predicate =  [nextContent getExtraString:@"predicate"];
                    if (predicate) {
                        if (![self evalJSPredicate:predicate]) {
                            index++;
                            nextContent = nil;
                            continue;
                        }
                    }
                    break;
                }
            }
        }
    }
    
    if (disableBack) removeOld = TRUE;
    if (!removeOld) {
        UIViewController *vc = self.childNavController.topViewController;
        if ([vc isKindOfClass:[ContentViewController class]]) {
            ContentViewController *cvc = (ContentViewController*)vc;
            if ([cvc.content getExtraBoolean:@"disableBackTo"]) removeOld = TRUE;
        }
    }
    if (!removeOld) {
        if ([nextContent getExtraBoolean:@"disableBackFrom"]) removeOld = TRUE;
    }

    if (!nextContent && next) nextContent = next.content;
    
    if (!nextContent) {
        if ([self.content getExtraBoolean:@"rollover"]) {
            [self.childNavController popToRootViewControllerAnimated:TRUE];
            return;
        }
        if (self.masterController) {
            [super navigateToNext:next from:self animated:animated andRemoveOld:FALSE];
        } else {
            NSLog(@"No next option");
        }
    } else {
        if (nextContent.ref) {
            [self managedObjectSelected:nextContent];
            return;
        }
        
        if (!next) next = [nextContent getViewController];
        next.masterController = self;
        if (next.shouldExecInsteadOfPush) {
            [self pushExecLeaf:next];
        } else {
            [next view];
            [self.childNavController pushViewController:next animated:animated andRemoveOld:removeOld andThen:nil];
            [self updateNavigationItemsAnimated:animated];
            [self updateContentVisibilityForChildren];
        }
    }
}

- (BOOL)navigateToContentWithPath:(NSArray *)path startingAt:(int)index withData:(NSDictionary *)data {
    Content *next = [path objectAtIndex:index];

    int i=0;
    for (ContentViewController *child in self.childNavController.viewControllers) {
        if ([child.content isEqual:next]) break;
        i++;
    }
    
    if (i == self.childNavController.viewControllers.count) {
        NSArray *children = self.content.properChildren;
        if ([children containsObject:next]) {
            int stackSize=1;
            for (Content *child in children) {
                for (ContentViewController *stacked in self.childNavController.viewControllers) {
                    if ([stacked.content isEqual:child]) {
                        stackSize = [self.childNavController.viewControllers indexOfObject:stacked]+2;
                        goto continueOuter;
                    }
                }
                ContentViewController *cv = child.getViewController;
                while (self.childNavController.viewControllers.count > stackSize-1) {
                    [self.childNavController popViewControllerAnimated:FALSE];
                    [self updateNavigationItemsAnimated:FALSE];
                    [self updateContentVisibilityForChildren];
                }
                
                cv.masterController = self;
                BOOL thisIsNext = [child isEqual:next];
                [self.childNavController pushViewController:cv animated:thisIsNext && (index == (path.count-1))];
                [self updateNavigationItemsAnimated:FALSE];
                [self updateContentVisibilityForChildren];
                if ([child isEqual:next]) break;

                continueOuter: ;

            }
            
            if (index < path.count-1) {
                [((ContentViewController*)self.childNavController.topViewController) navigateToContentWithPath:path startingAt:index+1 withData:data];
            }
            return true;
        }
        
        return false;
    }
    
    Content *lastNext = nil;
    int newStartingAt = index;
    while ((i < self.childNavController.viewControllers.count) && [next isEqual:((ContentViewController*)[self.childNavController.viewControllers objectAtIndex:i]).content]) {
        i++;
        if (newStartingAt >= path.count-1) {
            next = nil;
            break;
        }
        newStartingAt++;
        lastNext = next;
        next = [path objectAtIndex:newStartingAt];
    }
    
    if (lastNext && [((ContentViewController*)[self.childNavController.viewControllers objectAtIndex:i-1]) branchNavigateToContentWithPath:path startingAt:newStartingAt withData:data]) {
        return TRUE;
    }
    
    if (newStartingAt >= path.count-1) {
        newStartingAt = -1;
    } else {
        newStartingAt++;
    }
    
    Content *nextContent = next;
    
    if ([nextContent.name isEqualToString:@"@inline"]) {
        nextContent = nil;
        newStartingAt--;
    }
    
    int nextIndex = newStartingAt;
    void(^afterPush)(void) = ^{
        if (nextContent != nil) {
            ContentViewController *cv = nextContent.getViewController;
            cv.masterController = self;
            [self.childNavController pushViewController:cv animated:TRUE andRemoveOld:FALSE andThen:^{
                if (nextIndex != -1) {
                    [cv navigateToContentWithPath:path startingAt:nextIndex withData:data];
                } else if (data) {
                    [cv navigationDataReceived:data];
                }
            }];
        } else {
            ContentViewController *cv = (ContentViewController*)self.childNavController.topViewController;
            if (nextIndex != -1) {
                [cv navigateToContentWithPath:path startingAt:nextIndex withData:data];
            } else if (data) {
                [cv navigationDataReceived:data];
            }
        }
    };
    
    int targetStackSize = i;
    while (self.childNavController.viewControllers.count > targetStackSize+1) {
        [self.childNavController popViewControllerAnimated:FALSE];
        [self updateNavigationItemsAnimated:FALSE];
        [self updateContentVisibilityForChildren];
    }
    
    if (self.childNavController.viewControllers.count > targetStackSize) {
        [self.childNavController popViewControllerAnimated:TRUE andThen:afterPush];
        [self updateNavigationItemsAnimated:TRUE];
        [self updateContentVisibilityForChildren];
    } else {
        afterPush();
    }
    
    return TRUE;
}

- (void) pushChild:(ContentViewController*)cvc andRemoveOld:(BOOL)removeOld animated:(BOOL)animated {
    cvc.masterController = self;
    [self.childNavController pushViewController:cvc animated:animated andRemoveOld:removeOld andThen:nil];
    [self updateContentVisibilityForChildren];
    [self updateNavigationItemsAnimated:animated];
}

- (void) pushChild:(ContentViewController*)cvc animated:(BOOL)animated {
    [self pushChild:cvc andRemoveOld:FALSE animated:animated];
}

- (void) replaceTopControllerWith:(ContentViewController*)cvc {
    cvc.masterController = self;
    if (self.childNavController.viewControllers.count) {
        [self.childNavController removeAllPreviousViewControllers];
        [self.childNavController flipToNewTopViewController:cvc];
    } else {
        [self.childNavController pushViewController:cvc animated:FALSE andRemoveOld:FALSE andThen:nil];
    }
    [self updateNavigationItemsAnimated:TRUE];
}

- (BOOL)performAction:(NSString*)action withSource:(Content*)source fromChild:(ContentViewController*)child {
    NSArray *a = self.childNavController.viewControllers;
    NSLog(@"%@",a);
    int index = [self.childNavController.viewControllers indexOfObject:child];
    if (index != NSNotFound) {
        index--;
        while (index >= 0) {
            ContentViewController *thisChild = [self.childNavController.viewControllers objectAtIndex:index];
            BOOL r = [thisChild tryPerformAction:action withSource:source];
            if (r) return TRUE;
            index--;
        }
    }
    
    return [super performAction:action withSource:source fromChild:self];
}

-(BOOL)tryPerformAction:(NSString *)action withSource:(Content *)source {
    return FALSE;
}

- (void) clearVariable:(NSString*)key {
	if (!self.localVariables) return;
	[self.localVariables removeObjectForKey:key];
//    NSLog(@"after clear:%@",self.localVariables);
}

- (void) clearVariables {
    self.localVariables = nil;
}

- (void) setVariable:(NSString*)key to:(NSObject*)value {
	if (!self.localVariables) self.localVariables = [NSMutableDictionary dictionaryWithCapacity:1];
//    if (!value) {
//        [self.localVariables removeObjectForKey:key];
//    } else {
        [self.localVariables setObject:value forKey:key];
//    }
}

- (BOOL) shouldUseFirstChildAsRoot {
    return TRUE;
}

- (UINavigationBar*)getExistingNavBar {
    ContentViewController *parent = self.masterController;
    while (parent) {
        if ([parent isKindOfClass:[NavController class]]) {
            return ((NavController*)parent).navBar;
        }
        parent = parent.masterController;
    }
    return nil;
}

- (BOOL) isTopNavController {
    ContentViewController *parent = self.masterController;
    while (parent) {
        if ([parent isKindOfClass:[NavController class]]) {
            return FALSE;
        }
        parent = parent.masterController;
    }
    return TRUE;
}

-(UINavigationItem *)navigationItem {
    return self.leafNavigationItem;
}

-(UINavigationItem*) leafNavigationItem {
    UIViewController *top = self.childNavController.topViewController;
    return top ? top.navigationItem : [super navigationItem];
}

-(void)updateContentVisibilityForChild:(ContentViewController *)child {
    child.contentVisible = self.contentVisible && (child == self.childNavController.topViewController);
}

- (BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item {
    if (guard) return FALSE;
    guard = TRUE;
    ContentEvent *event = [ContentEvent eventOfType:CONTENT_EVENT_BACK_PRESSED];
    /*BOOL r =*/ [self dispatchContentEvent:event];
    guard = FALSE;
    return FALSE;
}

-(void)updateNavigationItemsAnimated:(BOOL)animated {
    ContentViewController *root = self;
    while (root) {
        if ([root isKindOfClass:[NavController class]]) {
            NavController *c = (NavController*)root;
            if (c.ownedNavBar) {
                ContentEvent *event = [ContentEvent eventOfType:CONTENT_EVENT_GATHER_NAV_STACK];
                NSMutableArray *newItems = [NSMutableArray array];
                event.data = newItems;
                [root dispatchContentEvent:event];

                c.ownedNavBar.delegate = nil;

                NSArray *oldItems = c.ownedNavBar.items;
/*
                NSMutableString *buf = [NSMutableString string];
                [buf appendFormat:@"["];
                for (UINavigationItem *item in oldItems) {
                    [buf appendFormat:@"%@ (%@, %@)",item,item.title,item.backBarButtonItem.title];
                }
                [buf appendFormat:@"["];
                NSLog(@"old: %@",buf);
                buf = [NSMutableString string];
                [buf appendFormat:@"[\n"];
                for (UINavigationItem *item in newItems) {
                    [buf appendFormat:@"  %@ (%@, %@)\n",item,item.title,item.backBarButtonItem.title];
                }
                [buf appendFormat:@"]"];
                NSLog(@"new: %@",buf);
*/
                int i = 0;
                while ((i < newItems.count) && (i < oldItems.count) &&
                       ([newItems objectAtIndex:i] == [oldItems objectAtIndex:i])) {
                    i++;
                }
                
                if ((i != newItems.count) || (i != oldItems.count)) {
                    [c.ownedNavBar setItems:newItems animated:animated];
                }
                
/*

                BOOL hasNew = (i < newItems.count);
                if (i < oldItems.count) {
                    for (int j=i;j<oldItems.count;j++) {
                        [c.ownedNavBar popNavigationItemAnimated:(j==oldItems.count-1) && !hasNew && animated];
                    }
                }

                if (i < newItems.count) {
                    for (int j=i;j<newItems.count;j++) {
                        [c.ownedNavBar pushNavigationItem:[newItems objectAtIndex:j] animated:(j==newItems.count-1) && animated];
                    }
                }
*/

                c.ownedNavBar.delegate = self;
                break;
            }
        }
        root = root.masterController;
    }
}

-(void) gatherNavigationItems:(NSMutableArray *)items {
    UINavigationItem *item = self.leafNavigationItem;
    [items addObject:item];
}

-(BOOL) dispatchContentEvent:(ContentEvent *)event {
    UIViewController *controller = (ContentViewController*)self.childNavController.topViewController;
    if (event.eventType == CONTENT_EVENT_GATHER_NAV_STACK) {
        NSMutableArray *items = (NSMutableArray*)event.data;
        for (UIViewController *c in self.childNavController.viewControllers) {
            if (c != controller) {
                if ([c isKindOfClass:[ContentViewController class]]) {
                    ContentViewController *cvc = (ContentViewController *)c;
                    [cvc gatherNavigationItems:items];
                } else {
                    UINavigationItem *item = c.navigationItem;
                    [items addObject:item];
                }
            }
        }
    }
    
    if ([controller respondsToSelector:@selector(dispatchContentEvent:)]) {
        return [(ContentViewController*)controller dispatchContentEvent:event];
    } else if (event.eventType == CONTENT_EVENT_BACK_PRESSED) {
        [self goBackFrom:controller animated:TRUE];
    }
    return TRUE;
}

-(NSArray *)childContentControllers {
    return self.childNavController.viewControllers;
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [self updateNavigationItemsAnimated:FALSE];
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [self updateNavigationItemsAnimated:animated];
}

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

- (UIView*) createMainViewWithFrame:(CGRect)frame {
    disableBack = [[self.content getExtraString:@"disableBack"] isEqualToString:@"true"];
    
    self.childNavController = [[[GNavigationController alloc] init] autorelease];
    self.childNavController.navigationBarHidden = TRUE;
    self.childNavController.externalDelegate = self;
	TopNavView *cv = [[TopNavView alloc] initWithFrame:frame];
    self.navBar = [self getExistingNavBar];
    BOOL ios7 = FALSE;
    if ([iStressLessAppDelegate deviceMajorVersion] >= 7) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.extendedLayoutIncludesOpaqueBars = NO;
        ios7 = TRUE;
    }
    float barBottom = 0;
    float barHeight = [TopNavView navBarHeight];
    if (!self.navBar) {
        self.navBar = [[[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, barHeight)] autorelease];
        self.navBar.translucent = NO;
        
        UIColor *navTextColor = [[ThemeManager sharedManager] colorForName:@"navBarTextColor"];

        CGSize size = CGSizeMake(768, barHeight);
        CGRect r = CGRectMake(0, 0, 768, barHeight);
        UIGraphicsBeginImageContext(size);
        CGContextRef c = UIGraphicsGetCurrentContext();
        UIColor *uiColor = [[ThemeManager sharedManager] colorForName:@"navBarTintColor"];
        CGContextSetFillColorWithColor(c, [uiColor CGColor]);
        CGContextFillRect(c, r);
        UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [[UINavigationBar appearance] setBackgroundImage:newImage forBarMetrics:UIBarMetricsDefault];
        
        NSDictionary *navbarTitleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                                   navTextColor,UITextAttributeTextColor,
                                                   [[ThemeManager sharedManager] colorForName:@"navBarTextShadowColor"], UITextAttributeTextShadowColor,
                                                   [NSValue valueWithUIOffset:UIOffsetMake(1, 1)], UITextAttributeTextShadowOffset, nil];
        [[UINavigationBar appearance] setTitleTextAttributes:navbarTitleTextAttributes];

        if (ios7) {
            [UINavigationBar appearance].tintColor = navTextColor;//[[ThemeManager sharedManager] colorForName:@"navBarTintColor"];
        } else {
            [UINavigationBar appearance].tintColor = [[ThemeManager sharedManager] colorForName:@"navBarTintColor"];
        }
        self.navBar.delegate = self;
        self.ownedNavBar = self.navBar;
        cv.navBar = self.navBar;
        [cv addSubview:self.navBar];
        
        barBottom += barHeight;
    }
    [cv setBackgroundColor:[UIColor clearColor]];
    cv.opaque = FALSE;
    cv.frame = frame;
    frame.origin.x = 0;
    frame.origin.y = barBottom;
    frame.size.height -= barBottom;
    cv.clientView = self.childNavController.view;
    self.childNavController.view.frame = frame;
    [cv addSubview:self.childNavController.view];
    
    if ([self shouldUseFirstChildAsRoot]) {
        for (Content *child in self.content.properChildren) {
            ContentViewController *cvc = [child getViewController];
            cvc.masterController = self;
            [self.childNavController pushViewController:cvc animated:FALSE];
            [self updateNavigationItemsAnimated:FALSE];
            [self updateContentVisibilityForChildren];
            break;
        }
    }

    return cv;
}

@end
