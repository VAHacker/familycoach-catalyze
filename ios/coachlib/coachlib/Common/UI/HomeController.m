//
//  HomeController.m
//  iStressLess
//


//

#import "HomeController.h"
#import "iStressLessAppDelegate.h"

@implementation HomeController

- (void) aboutTapped {
	ContentViewController *aboutController = [[iStressLessAppDelegate instance] getContentControllerWithName:@"about"];
	[self.navigationController pushViewController:aboutController animated:TRUE];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
//    [[iStressLessAppDelegate instance] setSetting:@"firstLaunch" to:@"true"];
}

- (void) configureMetaContent {
	[super configureMetaContent];
	self.navigationController.modalTransitionStyle = UIViewAnimationOptionTransitionFlipFromRight;
	self.modalTransitionStyle = UIViewAnimationOptionTransitionFlipFromRight;
}

@end
