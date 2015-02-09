//
//  SimpleExerciseController.m
//  iStressLess
//


//

#import "ExerciseInitialController.h"
#import "ManageSymptomsNavController.h"

@implementation ExerciseInitialController

-(void) viewWillAppear:(BOOL)animated {
	[super viewWillAppear:(BOOL)animated];
/*
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(deviceShaken) name:@"DeviceShaken" object:nil];
*/
}

-(void) viewWillDisappear:(BOOL)animated {
//	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[super viewWillDisappear:(BOOL)animated];
}

@end
