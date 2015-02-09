//
//  ToolControllerViewController.m
//  coachlib
//
//  Copyright (c) 2012 Department of Veteran's Affairs. All rights reserved.
//

#import "iStressLessAppDelegate.h"
#import "ToolController.h"
#import "CategoryIntroController.h"
#import "ToolAbortedEvent.h"
#import "UIAlertView+MKBlockAdditions.h"

@interface ToolController ()

@end

@implementation ToolController

#define foo4random() (arc4random() % ((unsigned)RAND_MAX + 1))

- (ExerciseRef *)chooseRandomExerciseWithPredicate:(NSPredicate*)predicate {
	NSManagedObjectContext *context = [iStressLessAppDelegate instance].udManagedObjectContext;
	
	NSFetchRequest *fetchRequest;
    
	fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"ExerciseRef"];
	[fetchRequest setPredicate:predicate];
	[fetchRequest setIncludesPropertyValues:YES];
	[fetchRequest setPropertiesToFetch:@[@"weight",@"positiveScore"]];
	NSArray *a = [context executeFetchRequest:fetchRequest error:NULL];
	
	float total = 0;
	for (int i=0;i<a.count;i++) {
		ExerciseRef *o = [a objectAtIndex:i];
		total += o.weight.floatValue * (o.positiveScore.intValue ? 2 : 1);
	}
    
    ExerciseRef *ref = nil;
	int selectedIndex = 0;
	int r = foo4random();
	float selection = r * total / INT_MAX;
	total = 0;
	for (int i=0;i<a.count;i++) {
		ExerciseRef *o = [a objectAtIndex:i];
		float current = o.weight.floatValue * (o.positiveScore.intValue ? 2 : 1);
		if ((selection > total) && (selection <= (total + current))) {
			selectedIndex = i;
			ref = o;
			break;
		}
		total += current;
	}
	NSLog(@"%d %f %d %@ %@",r,selection,selectedIndex,ref,[[ref ref] mainText]);
    
    [self setVariable:@"numExerciseOptions" to:[NSNumber numberWithInt:a.count]];
    
    return ref;
}

-(void)refreshContent {
    ContentViewController *newTool = [self selectExerciseController];
    if (newTool) {
        [self augmentExercise:newTool];
        [self replaceTopControllerWith:newTool];
    }
}

-(BOOL)navigateToContentWithPath:(NSArray *)path startingAt:(int)index {
    Content *next = [path objectAtIndex:path.count-1];
    [self setVariable:@"preselectedExercise" to:next];
    [self refreshContent];
    return TRUE;
}

- (ContentViewController*) selectExerciseController {
    int repeats = 0;
    ContentViewController *cvc = nil;

    Content *symptomContent = (Content*)[self getVariable:@"symptom"];
    SymptomRef *symptom = [symptomContent refForSymptom];
    Content *preselectedExerciseContent = (Content*)[self getVariable:@"preselectedExercise"];
    ExerciseRef *preselectedExercise = [preselectedExerciseContent refForExercise];
    ExerciseRef *exerciseRef = nil;
    Content *exercise = nil;

    while (cvc == nil) {
        
        if (preselectedExercise) {
            if (preselectedExercise.isCategory.boolValue) {
                if (self.lastExercise) {
                    exerciseRef = [self chooseRandomExerciseWithPredicate:[NSPredicate predicateWithFormat:@"(self != %@) AND (weight > 0) AND (negativeScore == 0) AND (parent == %@)",self.lastExercise,preselectedExercise]];
                } else {
                    exerciseRef = [self chooseRandomExerciseWithPredicate:[NSPredicate predicateWithFormat:@"(weight > 0) AND (negativeScore == 0) AND (parent == %@)",preselectedExercise]];
                }
            } else {
                exerciseRef = preselectedExercise;
            }
        } else if (symptom) {
            NSPredicate *predicate;
            if (self.lastExercise) {
                predicate = [NSPredicate predicateWithFormat:@"(self != %@) AND (weight > 0) AND (negativeScore == 0) AND (%@ in helpsWithSymptoms)",self.lastExercise,symptom];
            } else {
                predicate = [NSPredicate predicateWithFormat:@"(weight > 0) AND (negativeScore == 0) AND (%@ in helpsWithSymptoms)",symptom];
            }
            exerciseRef = [self chooseRandomExerciseWithPredicate:predicate];
        } else {
            return nil;
        }
        
        if (exerciseRef == self.lastExercise) {
            repeats++;
            exerciseRef = nil;
            if (self.alreadyPrereqed && (repeats > 2)) return nil;
            if (repeats > 100) {
                [UIAlertView alertViewWithTitle:@"Error"
                                        message:@"Sorry, I couldn't find a skill right now."
                              cancelButtonTitle:@"Ok" otherButtonTitles:nil onDismiss:nil onCancel:^{
                                  [self goBack];
                              }];
                return nil;
            }
            continue;
        }
        
        self.lastExercise = exerciseRef;
        if (exerciseRef == nil) continue;
        
        exercise = [exerciseRef ref];
        
        Content *parent = [exercise valueForKey:@"parent"];
        NSString *parentID = [parent uniqueID];
        cvc = [[iStressLessAppDelegate instance] getContentControllerForObject:exercise withDefaultUI:@"ContentViewController"];
        NSString *prereq = [cvc checkPrerequisite];
        if (!prereq) {
            if ([parent valueForKey:@"ui"] && ![parentID isEqual:self.lastCategoryIntroID]) {
                // There is a category intro UI first...
                cvc = [[iStressLessAppDelegate instance] getContentControllerForObject:parent withDefaultUI:@"ContentViewController"];
                ((CategoryIntroController*)cvc).selectedContent = exercise;
                self.lastCategoryIntroID = parentID;
            }
        } else {
            if (preselectedExercise) {
                if (!self.alreadyPrereqed) {
                    [UIAlertView alertViewWithTitle:@"Tool Not Yet Set Up"
                                            message:prereq
                                  cancelButtonTitle:@"Ok" otherButtonTitles:nil onDismiss:nil onCancel:^{
                                      [self goBack];
                                  }];
                    self.alreadyPrereqed = TRUE;
                }
                return nil;
            }
            cvc = nil;
        }
        
        if (cvc == nil) continue;
    }
    
    [self.masterController setVariable:@"selectedExercise" to:exercise];
    cvc.masterController = self;
    return cvc;
}

- (void)augmentExercise:(ContentViewController *)cv {
    Content *preselectedExercise = (Content*)[self getVariable:@"preselectedExercise"];
    NSNumber *numExerciseOptions = (NSNumber*)[self getVariable:@"numExerciseOptions"];
    if ((!preselectedExercise || [preselectedExercise.entity.name isEqualToString:@"ExerciseCategory"]) &&
        (numExerciseOptions && ([numExerciseOptions intValue] > 1))) {
        [cv addButtonWithText:@"New Tool" callingBlock:^{
            [ToolAbortedEvent logWithToolId:[cv.content valueForKey:@"uniqueID"] withToolName:[cv.content valueForKey:@"name"]];
            ContentViewController *newTool = [self selectExerciseController];
            if (newTool) {
                [self augmentExercise:newTool];
                [self replaceTopControllerWith:newTool];
            }
        }];
    }
}

-(void)navigateToNext:(ContentViewController *)next from:(ContentViewController *)src animated:(BOOL)animated andRemoveOld:(BOOL)removeOld {
    if (next) [self augmentExercise:next];
    [super navigateToNext:next from:src animated:animated andRemoveOld:removeOld];
}

- (void)contentBecameVisible {
    [super contentBecameVisible];
    Content *exercise = (Content*)[self getVariable:@"selectedExercise"];
    if (!exercise) {
        [self refreshContent];
    }
}

- (BOOL) shouldUseFirstChildAsRoot {
    return FALSE;
}

-(void)configureFromContent {
    [super configureFromContent];
    ContentViewController *newTool = [self selectExerciseController];
    if (newTool) {
        [self augmentExercise:newTool];
        [newTool view];
        newTool.masterController = self;
        [self pushChild:newTool animated:FALSE];
    }
}

@end
