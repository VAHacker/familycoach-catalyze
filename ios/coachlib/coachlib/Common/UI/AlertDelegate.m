//
//  AlertDelegate.m
//  iStressLess
//
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AlertDelegate.h"


@implementation AlertDelegate

@synthesize target, targetSelector;

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (buttonIndex > 0) [target performSelector:targetSelector];
	[self release];
}

- (void)alertViewCancel:(UIAlertView *)alertView {
	[self release];
}

@end
