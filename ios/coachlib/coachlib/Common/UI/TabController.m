//
//  SegmentedToggleController.m
//  coachlib
//
//  Copyright (c) 2012 Department of Veteran's Affairs. All rights reserved.
//

#import "TabController.h"
#import "NavController.h"
#import "ThemeManager.h"
#import "heartbeat.h"

@implementation TabController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (BOOL)navigateToChildController:(ContentViewController *)childController {
    int i = 0;
    for (ContentViewController *c in rootList) {
        if (childController == c) {
            [c view];
            tabBarController.selectedIndex = i;
            [self updateContentVisibilityForChildren];
            return TRUE;
        }
        i++;
    }
    
    return FALSE;
}

- (BOOL)tabBarController:(UITabBarController *)tbc shouldSelectViewController:(UIViewController *)viewController {
    if (viewController == tbc.selectedViewController) {
        if ([viewController isKindOfClass:[NavController class]]) {
            NavController *nc = (NavController*)viewController;
            [self navigateToContent:nc.rootContent];
        }
    } else {
        // we switched tabs
        NSUInteger index = [tbc.viewControllers indexOfObject:viewController];
        UITabBarItem *tabBarItem = [[tbc.tabBar items] objectAtIndex:index];
        [heartbeat logEvent:@"TAB_BAR_ITEM_SELECTED" withParameters:@{@"name":tabBarItem.title}];
    }
    return TRUE;
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    [self updateContentVisibilityForChildren];
}

-(BOOL) dispatchContentEvent:(ContentEvent *)event {
    return [(ContentViewController*)tabBarController.selectedViewController dispatchContentEvent:event];
}

-(void)updateContentVisibilityForChild:(ContentViewController *)child {
    BOOL childVisible = self.contentVisible && (child == tabBarController.selectedViewController);
//    NSLog(@"Setting child %@ visibility to %d",child,childVisible);
    child.contentVisible = childVisible;
}

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

- (UIImage *)tintImage:(UIImage*)untintedImage withColor:(UIColor*)tint {
    UIGraphicsBeginImageContextWithOptions(untintedImage.size, FALSE, untintedImage.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextTranslateCTM(context, 0, untintedImage.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    CGRect rect = CGRectMake(0, 0, untintedImage.size.width, untintedImage.size.height);
    
    // draw black background to preserve color of transparent pixels
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    [[UIColor blackColor] setFill];
    CGContextFillRect(context, rect);
    
    // draw original image
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    CGContextDrawImage(context, rect, untintedImage.CGImage);
    
    // tint image (loosing alpha) - the luminosity of the original image is preserved
    CGContextSetBlendMode(context, kCGBlendModeMultiply);
    [tint setFill];
    CGContextFillRect(context, rect);
    
    // mask by alpha values of original image
    CGContextSetBlendMode(context, kCGBlendModeDestinationIn);
    CGContextDrawImage(context, rect, untintedImage.CGImage);
    
    UIImage *tintedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return tintedImage;
}

- (void)loadView {
    [self configureMetaContent];
    
    tabList = [[NSMutableArray alloc] initWithCapacity:5];
    rootList = [[NSMutableArray alloc] initWithCapacity:5];
    
    UIColor *itemTint = [[ThemeManager sharedManager] colorForName:@"tabBarItemColor"];
    UIColor *itemSelectedTint = [[ThemeManager sharedManager] colorForName:@"tabBarSelectedItemColor"];

    BOOL ios7 = SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0");

    int i=0;
    NSMutableArray *a = [[NSMutableArray alloc] initWithCapacity:5];
    for (Content *child in self.content.properChildren) {
        ContentViewController *c = [child getViewController];
        c.masterController = self;
        
        UIImage *untintedImage = child.uiIcon;
        
        if (ios7) {
            UIImage *tintedImage = [self tintImage:untintedImage withColor:itemTint];
            UIImage *finalImage = [tintedImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
            c.tabBarItem = [[[UITabBarItem alloc] initWithTitle:child.displayName image:finalImage tag:i] autorelease];
            tintedImage = [self tintImage:untintedImage withColor:itemSelectedTint];
            finalImage = [tintedImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
            c.tabBarItem.selectedImage = finalImage;
        } else {
            c.tabBarItem = [[[UITabBarItem alloc] initWithTitle:child.displayName image:untintedImage tag:i] autorelease];
        }
        
        [tabList addObject:c];
        [rootList addObject:c];
        [self addChildContentController:c];
        [a addObject:c];
    };
    
    CGRect r = [[UIScreen mainScreen] bounds];
    tabBarController = [[UITabBarController alloc] init];
    tabBarController.view.frame = r;
    tabBarController.delegate = self;

    CGSize size = CGSizeMake(640, 50);
    CGRect fillRect = CGRectMake(0, 0, 640, 50);
    UIGraphicsBeginImageContext(size);
    CGContextRef c = UIGraphicsGetCurrentContext();
    UIColor *uiColor = [[ThemeManager sharedManager] colorForName:@"tabBarTintColor"];
    CGContextSetFillColorWithColor(c, [uiColor CGColor]);
    CGContextFillRect(c, fillRect);
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [[UITabBarItem appearance] setTitleTextAttributes:@{ UITextAttributeTextColor : [[ThemeManager sharedManager] colorForName:@"tabBarItemColor"] }
                                             forState:UIControlStateNormal];

    [[UITabBarItem appearance] setTitleTextAttributes:@{ UITextAttributeTextColor : [[ThemeManager sharedManager] colorForName:@"tabBarSelectedItemColor"] }
                                             forState:UIControlStateSelected];

    tabBarController.tabBar.backgroundImage = newImage;

    if (!ios7) {
        tabBarController.tabBar.tintColor= [[ThemeManager sharedManager] colorForName:@"tabBarItemColor"];
        tabBarController.tabBar.selectedImageTintColor= [[ThemeManager sharedManager] colorForName:@"tabBarSelectedItemColor"];
    }
	topView = [[UIView alloc] initWithFrame:r];
	self.view = topView;
    [topView addSubview:tabBarController.view];

    [tabBarController setViewControllers:a];
    [a release];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)dealloc {
    [tabList release];
    [rootList release];
    
    [super dealloc];
}

@end
