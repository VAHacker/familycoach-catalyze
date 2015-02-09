//
//  RelaxationIntroController.m
//  iStressLess
//


//

#import "RelaxationController.h"
#import "ManageSymptomsNavController.h"
#import "heartbeat.h"

@implementation RelaxationController

-(BOOL)shouldAddListenButton {
    return FALSE;
}

-(void) viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[[UIApplication sharedApplication] setIdleTimerDisabled:NO];
	[[UIApplication sharedApplication] setIdleTimerDisabled:YES];
	[self playAudio];
    [heartbeat logEvent:@"AudioExerciseBegin" withParameters:@{@"value":[[self content] title]}];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
	[[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

@end
