//
//  ToolControllerViewController.h
//  coachlib
//
//  Copyright (c) 2012 Department of Veteran's Affairs. All rights reserved.
//

#import "NavController.h"

@interface ToolController : NavController

@property (nonatomic) BOOL alreadyPrereqed;
@property (nonatomic,retain) NSString *lastCategoryIntroID;
@property (nonatomic,retain) ExerciseRef *lastExercise;

@end
