//
//  SettingsController.m
//  iStressLess
//
//  Copyright 2011 Carrier IQ. All rights reserved.
//

#import "SettingsController.h"
#import "iStressLessAppDelegate.h"

@implementation SettingsController

#define ALERT_LOGOUT 100
#define ALERT_LOGOUT_RESET 101

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        if (alertView.tag == ALERT_LOGOUT) {
            [[iStressLessAppDelegate instance] logout];
        } else if (alertView.tag == ALERT_LOGOUT_RESET) {
            [[iStressLessAppDelegate instance] logoutAndReset];
        }
    }
}

-(void) managedObjectSelected:(NSManagedObject*)mo {
	NSString *name = [mo valueForKey:@"name"];
	if ([name isEqual:@"logout"]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log Out" 
                                                        message:@"This will clear your username and password and exit the app.  The next time you launch PTSD Explorer, you will need to log in again." 
                                                       delegate:self
                                              cancelButtonTitle:@"Never mind" otherButtonTitles:@"Do It",nil];
        alert.tag = ALERT_LOGOUT;
        [alert show];
        [alert release];
	} else if ([name isEqual:@"logoutAndReset"]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log Out and Clear App Data" 
                                                        message:@"This will clear your username and password AND ALL OTHER APP DATA and exit.  You can do this to reset the app for another user." 
                                                       delegate:self
                                              cancelButtonTitle:@"Never mind" otherButtonTitles:@"Do It",nil];
        alert.tag = ALERT_LOGOUT_RESET;
        [alert show];
        [alert release];
	} else {
		[super managedObjectSelected:(NSManagedObject *)mo];
	}
}

@end
