//
//  ManageSymptomsMasterController.m
//  iStressLess
//

#if 0
//

#import "ManageSymptomsNavController.h"
#import "ConstructedViewController.h"
#import "SUDSView.h"
#import "iStressLessAppDelegate.h"
#import "SUDSController.h"
#import "FavoritesListViewController.h"
#import "CategoryIntroController.h"
#import "heartbeat.h"
#import "VaPtsdExplorerProbesCampaign.h"

#define STATE_CHOOSE_SYMPTOM	1
#define STATE_SUDS				2
#define STATE_SKILL				3
#define STATE_RESUDS			4
#define STATE_SUDS_RESULT		5
#define STATE_CRISIS			6

#define DO_DEMO					0
#define DEMO_EXERCISE_NAME1		@"planToReduceIsolation"
#define DEMO_EXERCISE_NAME2		@"progressiveRelaxation"

static int demoState = 0;

@implementation ManageSymptomsNavController

@synthesize exerciseOrCategory, timerStartTime;

-(id)initWithCoder:(NSCoder *)aDecoder {
	[super initWithCoder:(NSCoder *)aDecoder];
	
	state = STATE_CHOOSE_SYMPTOM;
	suds = -1;
	symptom = nil;
    timerStartTime = 0;
	self.delegate = self;
	return self;
}

-(BOOL)isInExercise {
	return state == STATE_SKILL;
}

- (ConstructedViewController*) makeSUDSController:(NSString*)prompt {
	SUDSController *sudsViewController = [[iStressLessAppDelegate instance] getContentControllerWithName:prompt];
	sudsViewController.masterController = self;
//	sudsViewController.suds = suds;
	return sudsViewController;
}

- (void) slaveViewDidAppear:(UIViewController*)slave {
	if ([slave isKindOfClass:[SUDSController class]]) {
		if (state != STATE_RESUDS) state = STATE_SUDS;
	} else if ([slave isKindOfClass:[ButtonGridController class]]) {
		state = STATE_CHOOSE_SYMPTOM;
        timerStartTime = 0;
	} else if ([slave isKindOfClass:[FavoritesListViewController class]]) {
		state = STATE_CHOOSE_SYMPTOM;
        timerStartTime = 0;
	} else if ([slave isKindOfClass:[ContentViewController class]]) {
        ContentViewController* cvc = (ContentViewController*)slave;
        cvc.viewTypeID = 0; // tool
    }
}

- (void) backTapped {
	[self popViewControllerAnimated:TRUE];
	if (state == STATE_SUDS) {
		state = STATE_CHOOSE_SYMPTOM;
	} else if (state == STATE_SKILL) {
		state = STATE_SUDS;
	}
}

- (void) enterCrisis {
	state = STATE_CRISIS;
	ContentViewController *vc = [[iStressLessAppDelegate instance] getContentControllerWithName:@"crisis"];
	vc.masterController = self;
	[self pushViewController:vc animated:TRUE];
}

#define POSITIVE_WEIGHT 1.5
#define NEGATIVE_WEIGHT 0.75

- (NSManagedObject *)chooseRandomCategory {
	NSManagedObjectContext *context = [iStressLessAppDelegate instance].managedObjectContext;
	NSManagedObjectContext *udContext = [iStressLessAppDelegate instance].udManagedObjectContext;

	NSFetchRequest *fetchRequest;
	int positives = 0;
	int negatives = 0;
	int total = 0;
	
	fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"ExerciseScore" inManagedObjectContext:udContext]];
	[fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"((positiveScore+negativeScore) > 0) AND (isCategory == TRUE)"]];
	positives = [udContext countForFetchRequest:fetchRequest error:NULL];
	[fetchRequest release];

	fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"ExerciseScore" inManagedObjectContext:udContext]];
	[fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"((positiveScore+negativeScore) < 0) AND (isCategory == TRUE)"]];
	negatives = [udContext countForFetchRequest:fetchRequest error:NULL];
	[fetchRequest release];

	fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"ExerciseCategory" inManagedObjectContext:context]];
	total = [context countForFetchRequest:fetchRequest error:NULL];
	[fetchRequest release];
	
	
}

#define foo4random() (arc4random() % ((unsigned)RAND_MAX + 1))

- (NSManagedObject *)chooseRandomExerciseWithPredicate:(NSPredicate*)predicate {
	NSManagedObjectContext *context = [iStressLessAppDelegate instance].managedObjectContext;
	NSManagedObjectContext *udContext = [iStressLessAppDelegate instance].udManagedObjectContext;
	
	NSFetchRequest *fetchRequest;

	fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"Content" inManagedObjectContext:context]];
	[fetchRequest setPredicate:predicate];
	[fetchRequest setIncludesPropertyValues:YES];
	[fetchRequest setPropertiesToFetch:[NSArray arrayWithObject:@"weight"]];
	NSArray *a = [context executeFetchRequest:fetchRequest error:NULL];
	[fetchRequest release];
	
	float total = 0;
	for (int i=0;i<a.count;i++) {
		NSManagedObject *o = [a objectAtIndex:i];
		total += [[o valueForKey:@"weight"] floatValue];
	}

	int selectedIndex = 0;
	int r = foo4random();
	NSManagedObjectID *objectID = nil;
	float selection = r * total / INT_MAX;
	total = 0;
	for (int i=0;i<a.count;i++) {
		NSManagedObject *o = [a objectAtIndex:i];
		float current = [[o valueForKey:@"weight"] floatValue];
		if ((selection > total) && (selection <= (total + current))) {
			selectedIndex = i;
			objectID = [o objectID];
			break;
		}
		total += current;
	}
	NSLog(@"%d %f %d",r,selection,selectedIndex);

	if (objectID) return [context objectWithID:objectID];
	return nil;
}

- (BOOL) navigateToContentWithPath:(NSArray *)path startingAt:(int)index from:(ContentViewController*)cvc {
    Content *c = [path objectAtIndex:path.count-1];
    
    NSFetchRequest *req = [NSFetchRequest fetchRequestWithEntityName:@"ExerciseRef"];
    req.fetchLimit = 1;
    req.predicate = [NSPredicate predicateWithFormat:@"refID == %@",c.uniqueID];
    NSArray *a = [[iStressLessAppDelegate instance].udManagedObjectContext executeFetchRequest:req error:NULL];
    if (a.count) {
        [self popToRootViewControllerAnimated:FALSE];
        [self managedObjectSelected:[a objectAtIndex:0]];
        return TRUE;
    }

    return FALSE;
}

- (void) launchExerciseAvoiding:(NSManagedObject*)toAvoid andRemovingLast:(boolean_t)removeLast {
    NSFetchRequest *fetchRequest = nil;
    NSEntityDescription *entity = nil;
    NSArray *learnArray = nil;
    int count=0,index;
    int repeats = 0;
    
    NSManagedObjectContext *context = [iStressLessAppDelegate instance].managedObjectContext;
    NSManagedObjectContext *udContext = [iStressLessAppDelegate instance].udManagedObjectContext;
    BaseExerciseController *cvc = nil;
    NSManagedObject *lastExercise = nil;
    
    while (cvc == nil) {
        NSManagedObject *category = nil;
        NSManagedObject *exercise = nil;
        
        if (exerciseOrCategory) {
            BOOL isCategory = [[exerciseOrCategory valueForKey:@"isCategory"] boolValue];
            NSString *oidStr = [exerciseOrCategory valueForKey:@"refID"];
            if (isCategory) {
                fetchRequest = [[NSFetchRequest alloc] init];
                [fetchRequest setEntity:[NSEntityDescription entityForName:@"ExerciseCategory" inManagedObjectContext:context]];
                [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"uniqueID == %@",oidStr]];
                [fetchRequest setFetchLimit:1];
                NSArray *a = [context executeFetchRequest:fetchRequest error:NULL];
                if (a && a.count) category = [a objectAtIndex:0];
                [fetchRequest release];

                exercise = [self chooseRandomExerciseWithPredicate:[NSPredicate predicateWithFormat:@"(weight > 0) AND (category == %@)",category]];
            } else {
                fetchRequest = [[NSFetchRequest alloc] init];
                [fetchRequest setEntity:[NSEntityDescription entityForName:@"Content" inManagedObjectContext:context]];
                [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"uniqueID == %@",oidStr]];
                [fetchRequest setFetchLimit:1];
                NSArray *a = [context executeFetchRequest:fetchRequest error:NULL];
                if (a && a.count) exercise = [a objectAtIndex:0];
                [fetchRequest release];
            }
        } else if (DO_DEMO) {
            exercise = [[iStressLessAppDelegate instance] getContentWithName:demoState ? DEMO_EXERCISE_NAME2 : DEMO_EXERCISE_NAME1];
            demoState++;
        } else if (symptom) {
            NSPredicate *predicate;
            if (toAvoid) {
                predicate = [NSPredicate predicateWithFormat:@"(self != %@) AND (weight > 0) AND (%@ in helpsWithSymptoms)",toAvoid,symptom];
            } else {
                predicate = [NSPredicate predicateWithFormat:@"(weight > 0) AND (%@ in helpsWithSymptoms)",symptom];
            }
            exercise = [self chooseRandomExerciseWithPredicate:predicate];
            /*
             // Choose a random category
             fetchRequest = [[NSFetchRequest alloc] init];
             entity = [NSEntityDescription entityForName:@"ExerciseCategory" inManagedObjectContext:context];
             [fetchRequest setEntity:entity];
             [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"%@ in helpsWithSymptoms",symptom]];
             [fetchRequest setFetchLimit:100];
             learnArray = [context executeFetchRequest:fetchRequest error:NULL];
             count = learnArray.count;
             if (count == 0) continue;
             index = rand() % count;
             category = [learnArray objectAtIndex:index];
             [fetchRequest release];
             
             fetchRequest = [[NSFetchRequest alloc] init];
             entity = [NSEntityDescription entityForName:@"Content" inManagedObjectContext:context];
             [fetchRequest setEntity:entity];
             [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"parent==%@",category]];
             [fetchRequest setFetchLimit:1000];
             learnArray = [context executeFetchRequest:fetchRequest error:NULL];
             count = learnArray.count;
             
             if (count == 0) continue;
             
             index = rand() % count;
             exercise = [learnArray objectAtIndex:index];
             [fetchRequest release];
             */ 
        }
        
        if (exercise == lastExercise) {
            repeats++;
            if (repeats > 100) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Sorry, I couldn't find a skill right now." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alert show];
                [alert release];
                [self popToRootViewControllerAnimated:TRUE];
                return;
            }
            
            continue;
        }
        lastExercise = exercise;
        if (exercise == nil) continue;
        
        NSManagedObject *parent = [exercise valueForKey:@"parent"];
        NSURL *parentID = [[parent objectID] URIRepresentation];
        cvc = [[iStressLessAppDelegate instance] getContentControllerForObject:exercise withDefaultUI:@"ContentViewController"];
        ContentViewController *cvcProxy = [cvc checkProxy];
        if (cvcProxy) {
            ((BaseExerciseController*)cvcProxy).exerciseContent = exercise;
            cvc = cvcProxy;
        }
        NSString *prereq = [cvc checkPrerequisite];
        if (!prereq) {
            if ([parent valueForKey:@"ui"] && ![parentID isEqual:lastCategoryIntroID]) {
                // There is a category intro UI first...
                cvc = [[iStressLessAppDelegate instance] getContentControllerForObject:parent withDefaultUI:@"ContentViewController"];
                ((CategoryIntroController*)cvc).selectedContent = exercise;
                [lastCategoryIntroID release];
                lastCategoryIntroID = parentID;
                [lastCategoryIntroID retain];
            }
        } else {
            if (exerciseOrCategory) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Tool Not Yet Set Up" message:prereq delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alert show];
                [alert release];
                [self popViewControllerAnimated:TRUE];
                return;
            }
            cvc = nil;
        }
        
        //NSLog(@"%@",cvc);
        
        if (cvc == nil) continue;
    }
    
    cvc.masterController = self;
    
    state = STATE_SKILL;
    if (removeLast) {
        [self flipToNewTopViewController:cvc];
    } else {
        [self pushViewController:cvc animated:TRUE];
    }    
}

- (void) managedObjectSelected:(NSManagedObject*)mo {
	if ([mo.entity.name isEqualToString:@"Symptom"] || [mo.entity.name isEqualToString:@"ExerciseRef"]) {
        [lastCategoryIntroID release];
        lastCategoryIntroID = nil;

		[symptom release];
		symptom = nil;
		[exerciseOrCategory release];
		exerciseOrCategory = nil;
		if ([[[mo entity] name] isEqual:@"ExerciseRef"]) {
			exerciseOrCategory = mo;
			[exerciseOrCategory retain];
		} else {
			symptom = mo;
			[symptom retain];
		}
		ConstructedViewController *sudsViewController = [self makeSUDSController:@"sudsprompt"];
        if (sudsViewController) {
            state = STATE_SUDS;
            [sudsViewController addButton:BUTTON_SKIP_SUDS withText:@"Skip"];
            [sudsViewController addButton:BUTTON_DONE_SUDS withText:@"Next"];
            [self pushViewController:sudsViewController animated:TRUE];
        } else {
            [self launchExerciseAvoiding:nil andRemovingLast:FALSE];
        }
     } else {
        [super managedObjectSelected:(NSManagedObject *)mo];
     }
}
             


- (void) buttonSelected:(int)buttonID {
	BOOL removeLast = NO;
	NSManagedObject *toAvoid = nil;

	if (buttonID == BUTTON_DONE_EVERYTHING) {
		ContentViewController *vc = [[iStressLessAppDelegate instance] getContentControllerWithName:@"manage"];
        if (vc) {
            vc.masterController = self;
            [self insertNewRootViewController:vc];
        }
		state = STATE_CHOOSE_SYMPTOM;
		suds = -1;
		[self popToRootViewControllerAnimated:TRUE];
		return;
	}

	if ((buttonID == BUTTON_CHOOSE_ANOTHER) && (state == STATE_SKILL)) {
		toAvoid = ((BaseExerciseController*)[self topViewController]).exerciseContent;
        [ToolAbortedEvent logWithToolId:[toAvoid valueForKey:@"uniqueID"] withToolName:[toAvoid valueForKey:@"name"]];
	}
		
	if (buttonID == BUTTON_TRY_ANOTHER) {
		state = STATE_SUDS;
		removeLast = YES;
	}
	
	if (buttonID == BUTTON_DONE) {
		ConstructedViewController *sudsViewController = [self makeSUDSController:(suds == -1)?@"sudsprompt":@"sudsreprompt"];
        if (sudsViewController) {
            state = STATE_RESUDS;
            if (suds == -1) {
                if (!exerciseOrCategory) {
                    [sudsViewController addButton:BUTTON_SKIP_SUDS withText:@"Try Another Tool"];
                }
                [sudsViewController addButton:BUTTON_DONE_EVERYTHING withText:@"Done"];
            } else {
                [sudsViewController addButton:BUTTON_DONE_SUDS withText:@"Next"];
            }
            [self pushViewControllerAndRemoveAllPrevious:sudsViewController];
            return;
        } else {
            [self popViewControllerAnimated:TRUE];
            state = STATE_CHOOSE_SYMPTOM;
        }
	} else if (buttonID == BUTTON_CHOOSE_ANOTHER) {
		state = STATE_SUDS;
		removeLast = YES;
	}
	
	if (state == STATE_RESUDS) {
		SUDSController *sudsViewController = self.topViewController;
		if (buttonID == BUTTON_DONE_SUDS) {
			int newSuds = sudsViewController.suds;

            [PostExerciseSudsEvent logWithInitialSudsScore:suds withPostExerciseSudsScore:newSuds];

            [heartbeat
             logEvent:@"RESUDS_READING" 
             withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"suds",[NSString stringWithFormat:@"%d",suds], @"resuds",[NSString stringWithFormat:@"%d",newSuds],nil]];

			NSString *resultName = @"sudssame";
			if (newSuds > suds) resultName = @"sudsup";
			else if (newSuds < suds) resultName = @"sudsdown";
			NSLog(@"%@",resultName);
			ContentViewController *sudsResultController = [[iStressLessAppDelegate instance] getContentControllerWithName:resultName];
			sudsResultController.masterController = self;
			[sudsResultController addButton:BUTTON_TRY_ANOTHER withText:@"Try Another Tool"];
			[sudsResultController addButton:BUTTON_DONE_EVERYTHING withText:@"Done"];
			suds = newSuds;
			state = STATE_SUDS_RESULT;
			[self pushViewControllerAndRemoveAllPrevious:sudsResultController];
			return;
		}
	}
	
	if ((state == STATE_SUDS) || (state == STATE_RESUDS) || (state == STATE_CRISIS)) {
		// Choose a good intervention
		SUDSController *sudsViewController = self.topViewController;
		if (buttonID == BUTTON_DONE_SUDS) {
			suds = sudsViewController.suds;

			if (suds == -1) {
				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Rate Your Distress" message:@"Please either rate your distress on the meter or tap 'Skip'." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
				[alert show];
				[alert release];
				return;
			}

            [PreExerciseSudsEvent logWithPreExerciseSudsScore:suds];
            
            [heartbeat
             logEvent:@"SUDS_READING" 
             withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"suds",[NSString stringWithFormat:@"%d",suds], nil]];
            
			if (suds >= 9) {
				[self enterCrisis];
				return;
			}
		}

        [self launchExerciseAvoiding:toAvoid andRemovingLast:removeLast];
	}
}

-(void) dealloc {
	[symptom release];
	[exerciseOrCategory release];
	
	[super dealloc];
}

@end
#endif

