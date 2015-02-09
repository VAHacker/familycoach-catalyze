//
//  SegmentedToggleController.m
//  coachlib
//
//  Copyright (c) 2012 Department of Veteran's Affairs. All rights reserved.
//

#import "iStressLessAppDelegate.h"
#import "SegmentedToggleController.h"
#import "ThemeManager.h"

@interface SegmentedToggleController ()

@end

@implementation SegmentedToggleController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)segmentChanged {
    if (selectedController == segmentedControl.selectedSegmentIndex) return;
    UIPageViewControllerNavigationDirection dir =
        (segmentedControl.selectedSegmentIndex > selectedController) ?
        UIPageViewControllerNavigationDirectionForward :
        UIPageViewControllerNavigationDirectionReverse;
    selectedController = segmentedControl.selectedSegmentIndex;
    [self.pageViewController setViewControllers:@[[controllers objectAtIndex:selectedController]]
                                 direction:dir
                                  animated:TRUE
                                completion:NULL];
    [self updateContentVisibilityForChildren];
}

-(BOOL)navigateToChildController:(ContentViewController *)childController {
    int index = [controllers indexOfObject:childController];
    selectedController = index;
    [self.pageViewController setViewControllers:@[childController]
                                 direction:UIPageViewControllerNavigationDirectionForward
                                  animated:NO
                                completion:NULL];
    [self updateContentVisibilityForChildren];
    return TRUE;
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed {
    if (!completed) return;
    ContentViewController *to = [pageViewController.viewControllers objectAtIndex:0];
    int i = 0;
    for (ContentViewController *c in controllers) {
        if (c == to) break;
        i++;
    }
    if (i == selectedController) return;
    selectedController = i;
    segmentedControl.selectedSegmentIndex = selectedController;
}

-(void)updateContentVisibilityForChild:(ContentViewController *)child {
    child.contentVisible = self.contentVisible && (child == [controllers objectAtIndex:selectedController]);
}

-(void)contentBecameVisible {
    [super contentBecameVisible];
    [self clearVariable:@"preselectedExercise"];  // XXX hackity hack
    [self clearVariable:@"symptom"]; // XXX hackity hack
    [self clearVariables];
}

-(BOOL) dispatchContentEvent:(ContentEvent *)event {
    if (event.eventType == CONTENT_EVENT_GATHER_NAV_STACK) {
        NSMutableArray *items = (NSMutableArray*)event.data;
        [super gatherNavigationItems:items];
        return TRUE;
    }
    
    return [(ContentViewController*)[controllers objectAtIndex:selectedController] dispatchContentEvent:event];
}

- (void)loadView {
    [self configureMetaContent];
    controllers = [[NSMutableArray array] retain];
    NSMutableArray *itemArray = [NSMutableArray array];
    
    for (Content *c in self.content.properChildren) {
        [itemArray addObject:c.displayName];
        ContentViewController *controller = [c getViewController];
        controller.masterController = self;
        [self addChildContentController:controller];
        [controllers addObject:controller];
    }
    segmentedControl = [[UISegmentedControl alloc] initWithItems:itemArray];
    [segmentedControl setSegmentedControlStyle:UISegmentedControlStyleBar];
    [segmentedControl setSelectedSegmentIndex:0];
    
    if ([iStressLessAppDelegate deviceMajorVersion] >= 7) {
        segmentedControl.tintColor = [[ThemeManager sharedManager] colorForName:@"navBarTextColor"];
    } else {
        segmentedControl.tintColor = [[ThemeManager sharedManager] colorForName:@"navBarTintColor"];
    }
    
    selectedController = 0;
    [segmentedControl addTarget:self action:@selector(segmentChanged) forControlEvents:UIControlEventValueChanged];

    self.navigationItem.titleView = segmentedControl;
    
    self.pageViewController = [[[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil] autorelease];
    self.pageViewController.dataSource = self;
    
    [self.pageViewController setViewControllers:@[[controllers objectAtIndex:0]]
                                 direction:UIPageViewControllerNavigationDirectionForward
                                  animated:NO
                                completion:NULL];

    self.pageViewController.delegate = self;

    CGRect r = [[UIScreen mainScreen] bounds];
    self.pageViewController.view.frame = r;
	topView = [[UIView alloc] initWithFrame:r];
	self.view = topView;
    [topView addSubview:self.pageViewController.view];
    [self addChildViewController:self.pageViewController];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pvc viewControllerBeforeViewController:(ContentViewController *)vc
{
    int index = [controllers indexOfObject:vc];
    if (index <= 0) return nil;
    index--;
    return [controllers objectAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pvc viewControllerAfterViewController:(ContentViewController *)vc
{
    int index = [controllers indexOfObject:vc];
    if (index >= controllers.count-1) return nil;
    index++;
    return [controllers objectAtIndex:index];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc {
    [controllers release];
    [segmentedControl release];
    
    [super dealloc];
}

@end
