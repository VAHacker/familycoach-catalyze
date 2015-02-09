//
//  GNavigationController.m
//  iStressLess
//


//

#import "GNavigationController.h"
#import "iStressLessAppDelegate.h"
#import "UIAlertView+MKBlockAdditions.h"
#import "Flurry.h"
#import "VaPtsdExplorerProbesCampaign.h"
#import "NavController.h"

@implementation BlockNavigationDelegate

+ (BlockNavigationDelegate*) navigationDelegateWithBlock:(VoidBlock)block {
    BlockNavigationDelegate *d = [[BlockNavigationDelegate alloc] init];
    d.block = block;
    return [d autorelease];
}

-(void)navigationController:(GNavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [self retain];
    navigationController.internalDelegate = nil;
    self.block();
    [self release];
}

@end

@implementation GNavigationController

@synthesize selectionDelegate;

-(instancetype)initWithNavigationBarClass:(Class)navigationBarClass toolbarClass:(Class)toolbarClass {
    id _self = [super initWithNavigationBarClass:navigationBarClass toolbarClass:toolbarClass];
    self.delegate = self;
    return _self;
}

-(id)initWithRootViewController:(UIViewController *)rootViewController {
    id _self = [super initWithRootViewController:rootViewController];
    self.delegate = self;
    return _self;
}

-(id)init {
    id _self = [super init];
    self.delegate = self;
    return _self;    
}
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (self.internalDelegate) {
//        [self.internalDelegate navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated];
    }
    if (self.externalDelegate) {
        [self.externalDelegate navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated];
    }
   
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (self.internalDelegate) {
        [self.internalDelegate navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated];
        self.internalDelegate = nil;
    }
    if (self.externalDelegate) {
        [self.externalDelegate navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated];
    }
}

-(UIViewController *)popViewControllerAnimated:(BOOL)animated {
    self.internalDelegate = nil;
    return [super popViewControllerAnimated:animated];
}

-(NSArray *)popToRootViewControllerAnimated:(BOOL)animated {
    self.internalDelegate = nil;
    return [super popToRootViewControllerAnimated:animated];
}

-(NSArray *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated {
    self.internalDelegate = nil;
    return [super popToViewController:viewController animated:animated];
}

-(void)setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated {
    self.internalDelegate = nil;
    [super setViewControllers:viewControllers animated:animated];
}

- (void) pushViewControllerAndRemoveOldOne:(UIViewController *)viewController {
	if ([viewController isKindOfClass:[ContentViewController class]]) {
		[[iStressLessAppDelegate instance] preloadContentViewFor:(ContentViewController*)viewController andThenRunBlock:^{
			[self popViewControllerAnimated:FALSE];
			[self pushViewController:viewController animated:YES];
		}];
	} else {
		[self popViewControllerAnimated:FALSE];
		[self pushViewController:viewController animated:YES];
	}
}

- (void) pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    self.internalDelegate = nil;
	if ((self.viewControllers.count > 0) && [viewController isKindOfClass:[ContentViewController class]]) {
		[[iStressLessAppDelegate instance] preloadContentViewFor:(ContentViewController*)viewController andThenRunBlock:^{
			[super pushViewController:viewController animated:animated];
		}];
	} else {
		[super pushViewController:viewController animated:animated];
	}
}

- (void) flipToNewTopViewController2:(UIViewController *)viewController {
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.5];
	[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.view cache:YES];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(enableInputOnTop)];
    if (self.viewControllers.count <= 1) {
        [self setViewControllers:@[viewController] animated:FALSE];
    } else {
        [self popViewControllerAnimated:FALSE];
        [self pushViewController:viewController animated:FALSE];
    }
	[UIView commitAnimations];
}

- (void) enableInputOnTop {
    self.topViewController.view.userInteractionEnabled = TRUE;
}

- (void) flipToNewTopViewController:(UIViewController *)viewController {
    viewController.view.userInteractionEnabled = FALSE;
    self.topViewController.view.userInteractionEnabled = FALSE;
	if ([viewController isKindOfClass:[ContentViewController class]]) {
		[[iStressLessAppDelegate instance] preloadContentViewFor:(ContentViewController*)viewController andThenRunBlock:^{
			[self flipToNewTopViewController2:viewController];
		}];
	} else {
		[self flipToNewTopViewController2:viewController];
	}
}

- (void) pushViewControllerAndRemoveAllPrevious2:(UIViewController *)viewController {
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(removeAllPreviousViewControllers)];
	[self pushViewController:viewController animated:TRUE];
	[UIView commitAnimations];
}

- (void) pushViewControllerAndRemoveAllNonRootPrevious2:(UIViewController *)viewController {
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(removeAllNonRootPreviousViewControllers)];
	[self pushViewController:viewController animated:TRUE];
	[UIView commitAnimations];
}

- (void) pushViewControllerAndRemoveAllPrevious:(UIViewController *)viewController {
	if ([viewController isKindOfClass:[ContentViewController class]]) {
		[[iStressLessAppDelegate instance] preloadContentViewFor:(ContentViewController*)viewController andThenRunBlock:^{
			[self pushViewControllerAndRemoveAllPrevious2:viewController];
		}];
	} else {
		[self pushViewControllerAndRemoveAllPrevious2:viewController];
	}
}

- (void) pushViewControllerAndRemoveAllNonRootPrevious:(UIViewController *)viewController {
	if ([viewController isKindOfClass:[ContentViewController class]]) {
		[[iStressLessAppDelegate instance] preloadContentViewFor:(ContentViewController*)viewController andThenRunBlock:^{
			[self pushViewControllerAndRemoveAllNonRootPrevious2:viewController];
		}];
	} else {
		[self pushViewControllerAndRemoveAllNonRootPrevious2:viewController];
	}
}

- (void) pushViewController:(UIViewController *)viewController animated:(BOOL)animated andRemoveOld:(BOOL)removeOld andThen:(void (^)())afterPush {
    self.internalDelegate = nil;

    if (self.viewControllers.count > 0) {
        UIViewController *vc = [self.viewControllers objectAtIndex:self.viewControllers.count-1];
        if ([vc isKindOfClass:[ContentViewController class]]) {
            ContentViewController *cvc = (ContentViewController*)vc;
            cvc.inTransition = YES;
        }
    }

    BOOL needPostPush = FALSE;
    if (removeOld) {
        if (self.viewControllers.count > 1) {
            [self popViewControllerAnimated:FALSE];
        } else {
            if ([self.topViewController isKindOfClass:[ContentViewController class]]) {
                ContentViewController *cvc = (ContentViewController*)self.topViewController;
                cvc.beingRemoved = TRUE;
            }
            needPostPush = TRUE;
        }
    }

    if (afterPush || needPostPush) {
        self.internalDelegate = [[BlockNavigationDelegate navigationDelegateWithBlock:^{
            if (needPostPush) {
                if (self.viewControllers.count > 1) {
                    [self removeViewController:[self.viewControllers objectAtIndex:self.viewControllers.count-2]];
                }
            }
            if (afterPush) {
                afterPush();
            }
        }] retain];
    }

//    [UIView beginAnimations:nil context:NULL];
//	[UIView setAnimationDelegate:self];
//	[UIView setAnimationDidStopSelector:@selector(removeAllNonRootPreviousViewControllers)];

    if ([viewController isKindOfClass:[NavController class]]) {
        self.navigationBarHidden = true;
    }
    
	[super pushViewController:viewController animated:animated];
//	[UIView commitAnimations];
}

- (void) popToViewController:(UIViewController*)popTo animated:(BOOL)animated andThen:(void (^)())afterPop {
    self.internalDelegate = nil;
    
    while (self.topViewController != popTo) {
        [self popViewControllerAnimated:FALSE];
    }

    if (afterPop) {
        self.internalDelegate = [[BlockNavigationDelegate navigationDelegateWithBlock:afterPop] retain];
    }
    
    [super popViewControllerAnimated:animated];
}

- (void) popViewControllerAnimated:(BOOL)animated andThen:(void (^)())afterPop {
    self.internalDelegate = nil;

    if (afterPop) {
        self.internalDelegate = [[BlockNavigationDelegate navigationDelegateWithBlock:afterPop] retain];
    }
    
    [super popViewControllerAnimated:animated];
}


- (void) popFromViewController:(UIViewController *)viewController animated:(BOOL)animated {
	NSMutableArray *a = [NSMutableArray arrayWithArray:self.viewControllers];
    int index = [a indexOfObject:viewController];
    if (index >= 1) {
        [self popToViewController:[a objectAtIndex:index-1] animated:animated];
    }
}

- (void) removeViewController:(UIViewController*)vc; {
	NSMutableArray *a = [NSMutableArray arrayWithArray:self.viewControllers];
	[a removeObject:vc];
	[self setViewControllers:a animated:FALSE];
}

- (void) removeLastViewController {
	NSMutableArray *a = [NSMutableArray arrayWithArray:self.viewControllers];
	[a removeObject:[a objectAtIndex:[a count]-2]];
	[self setViewControllers:a animated:FALSE];
}

- (void) removeAllPreviousViewControllers {
	NSMutableArray *a = [NSMutableArray arrayWithArray:self.viewControllers];
	while (a.count > 1) {
		[a removeObject:[a objectAtIndex:0]];
	}
	[self setViewControllers:a animated:FALSE];
}

- (void) removeAllNonRootPreviousViewControllers {
	NSMutableArray *a = [NSMutableArray arrayWithArray:self.viewControllers];
	while (a.count > 2) {
		[a removeObject:[a objectAtIndex:1]];
	}
	[self setViewControllers:a animated:FALSE];
}

- (void) replaceRootViewControllerWith:(UIViewController*)vc {
	NSMutableArray *a = [NSMutableArray arrayWithArray:self.viewControllers];
	[a replaceObjectAtIndex:0 withObject:vc];
	[self setViewControllers:a animated:FALSE];
}

- (void) insertNewRootViewController:(UIViewController*)vc {
	NSMutableArray *a = [NSMutableArray arrayWithArray:self.viewControllers];
	[a insertObject:vc atIndex:0];
	[self setViewControllers:a animated:FALSE];
}

- (BOOL) onAppSuspend {
    [self popToRootViewControllerAnimated:FALSE];
    return FALSE;
}

- (void) visitLink:(NSURL*)url {
    BOOL is911 = FALSE;
    if ([[url scheme] isEqualToString:@"tel"]) {
        NSString *number = [url resourceSpecifier];
        if ([number isEqualToString:@"911"]) {
            is911 = TRUE;
        }
    }
    
    void (^block)(int buttonIndex);
    block = ^(int buttonIndex) {
        UIApplication *app = [UIApplication sharedApplication];
        if (![app openURL:url]) {
            if ([[url scheme] isEqualToString:@"tel"]) {
                UIAlertView *alert2 = [[UIAlertView alloc] initWithTitle:@"Cannot dial number"
                                                                 message:@"Cannot dial out.  This may be because you are on an iPod or iPad rather than an iPhone.  Please use a phone, computer, or other device to call this number." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alert2 show];
                [alert2 release];
            }
        }
    };

    if (UIAccessibilityIsVoiceOverRunning() || is911) {
        NSString *title = @"Visit link?";
        NSString *body = @"This will leave the application.  Are you sure?";
        if ([[url scheme] isEqualToString:@"tel"]) {
            title = @"Dial number?";
            NSString *number = [url resourceSpecifier];
            if ([number isEqualToString:@"911"]) {
                title = @"Dial 911?";
                body = @"This will leave the application and dial 911.  Are you sure?";
            }
        }
        
        [UIAlertView alertViewWithTitle:title message:body cancelButtonTitle:@"Never mind" otherButtonTitles:@[@"Yes, I'm sure"] onDismiss:block onCancel:NULL];
    } else {
        block(0);
    }
}

-(void) dealloc {
	[variables release];
	[selectionDelegate release];
	
	[super dealloc];
}

@end
