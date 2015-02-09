//
//  SegmentedToggleController.m
//  coachlib
//
//  Copyright (c) 2012 Department of Veteran's Affairs. All rights reserved.
//

#import "PaneledController.h"
#import "PaneledView.h"
#import "iStressLessAppDelegate.h"
#import "GWebView.h"

@implementation PaneledController

-(void) configureBackground {
}

-(void)updatePane {
    PaneledView *pv = (PaneledView*)topView;
    NSString *title = bottomController.content.title;
    if (!title) title = bottomController.content.displayName;
    int badgeValue = bottomController.badgeValue;
    pv.splitTitle = title;
    pv.splitBadgeValue = badgeValue;
    pv.panelHidden = (badgeValue == 0);
    if (badgeValue == 0) {
        [pv setExpanded:FALSE animated:FALSE];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updatePane];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self updatePane];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"badgeValue"]) {
        PaneledView *pv = (PaneledView*)topView;
        int badgeValue = bottomController.badgeValue;
        pv.splitBadgeValue = badgeValue;
        pv.panelHidden = (badgeValue == 0);
        [pv setPanelHidden:(badgeValue == 0) animated:TRUE];
        if (badgeValue == 0) {
            [pv setExpanded:FALSE animated:TRUE];
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

-(BOOL) dispatchContentEvent:(ContentEvent *)event {
    return [topController dispatchContentEvent:event];
}

-(void)updateContentVisibilityForChild:(ContentViewController *)child {
    PaneledView *pv = (PaneledView*)topView;
    child.contentVisible = self.contentVisible && ((child == topController) || ((child == bottomController) && !pv.expanded));
}

- (void)loadViewFromContent {
    topController = nil;
    [self configureMetaContent];
    
    NSArray *children = self.content.properChildren;

    Content *child = [children objectAtIndex:0];
    ContentViewController *c = [child getViewController];
    c.masterController = self;
    [self addChildContentController:c];
    topController = c;
    [topController retain];
    [self addChildViewController:topController];

    child = [children objectAtIndex:1];
    c = [child getViewController];
    c.masterController = self;
    bottomController = c;
    [bottomController retain];
    [self addChildContentController:c];
    [self addChildViewController:c];
    
    [bottomController addObserver:self forKeyPath:@"badgeValue" options:NSKeyValueChangeSetting context:NULL];
    
    CGRect r = [[UIScreen mainScreen] bounds];
	PaneledView *pv = [[PaneledView alloc] initWithFrame:r];
    topView = pv;
	self.view = pv;

    pv.top = topController.view;
    pv.bottom = bottomController.view;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)dealloc {
    [topController release];
    [bottomController removeObserver:self forKeyPath:@"badgeValue"];
    [bottomController release];
    
    [super dealloc];
}

@end
