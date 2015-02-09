//
//  SUDSViewController.m
//  iStressLess
//


//

#import "UIAlertView+MKBlockAdditions.h"
#import "SUDSController.h"
#import "SUDSView.h"
#import "heartbeat.h"
#import "PreExerciseSudsEvent.h"
#import "PostExerciseSudsEvent.h"
#import "SymptomRef.h"

@implementation SUDSController

- (int)suds {
	[self view];
	return sudsView.rating;
};

- (void) setSuds:(int)sud {
	[self view];
	sudsView.rating = sud;
}

- (void) recordSUDS {
    int suds = sudsView.rating;
    
    [PreExerciseSudsEvent logWithPreExerciseSudsScore:suds];
    
    [heartbeat
     logEvent:@"SUDS_READING"
     withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"suds",[NSString stringWithFormat:@"%d",suds], nil]];
    
    if (suds != -1) {
        [self setVariable:@"suds" to:[NSNumber numberWithInt:suds]];
    } else {
        [self clearVariable:@"suds"];
    }
}

- (void) recordReSUDS {
    NSNumber *sudsNum =(NSNumber*)[self getVariable:@"suds"];
    int suds = sudsNum ? [sudsNum intValue] : -1;
    int newSuds = sudsView.rating;
    
    [PostExerciseSudsEvent logWithInitialSudsScore:suds withPostExerciseSudsScore:newSuds];
    
    [heartbeat
     logEvent:@"RESUDS_READING"
     withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"suds",[NSString stringWithFormat:@"%d",suds], @"resuds",[NSString stringWithFormat:@"%d",newSuds],nil]];
    
    if (newSuds != -1) {
        [self setVariable:@"resuds" to:[NSNumber numberWithInt:newSuds]];
    } else {
        [self clearVariable:@"resuds"];
    }
}

-(void)journalIt:(Content*)source {
    SymptomRef *symptom = nil;
    NSNumber *severity = nil;

    Content *symptomContent = (Content*)[self getVariable:@"symptom"];
    if (symptomContent) symptom = [symptomContent refForSymptom];

    severity = (NSNumber*)[self getVariable:@"suds"];
    
    NSMutableDictionary *addDict = [NSMutableDictionary dictionary];
    [addDict setObject:[NSDate date] forKey:@"when"];
    if (symptom) [addDict setObject:symptom forKey:@"symptom"];
    if (severity) [addDict setObject:severity forKey:@"severity"];
    
    [self navigateToContentName:@"manage"];
    [self navigateToContentName:@"journal" withData:@{@"add":addDict}];
}

- (void) configureFromContent {
	NSArray* nibViews =  [[NSBundle mainBundle] loadNibNamed:@"SUDSView" owner:self options:nil];
	sudsView = [nibViews objectAtIndex: 0];
	[sudsView retain];
	[self addRightSideView:sudsView withMargin:CGPointMake(10, 20)];
    
	[super configureFromContent];
    
    if ([[self.content getExtraString:@"resuds"] isEqualToString:@"true"]) {
        [self registerAction:@"journalIt" withSelector:@selector(journalIt:)];
        NSNumber *sudsScore = (NSNumber*)[self getVariable:@"suds"];
        if (!sudsScore) {
            /*
            NSString *label = @"Try Another Tool";
            Content *preselectedExercise = (Content*)[self getVariable:@"preselectedExercise"];
            if (preselectedExercise) {
                if (![preselectedExercise.entity.name isEqualToString:@"ExerciseCategory"]) {
                    label = @"Try This Tool Again";
                }
            }
             */
            
            [self addButtonWithText:@"Journal This" callingBlock:^{
                [self journalIt:nil];
            }];
            /*
            [self addButtonWithText:label callingBlock:^{
                [self clearVariable:@"selectedExercise"];
                [self navigateToContentName:@"exercise"];
            }];*/

            [self addButtonWithText:@"Done" callingBlock:^{
                [self clearVariables];
                [self navigateToContentName:@"manage"];
            }];
        } else {
            sudsView.rating = [sudsScore intValue];
            [self addButtonWithText:@"Next" callingBlock:^{
                [self recordReSUDS];
                [self navigateToNext];
            }];
        }
    } else {
        [self addButtonWithText:@"Skip" callingBlock:^{
            [self navigateToNext];
        }];
        [self addButtonWithText:@"Next" callingBlock:^{
            int distress = sudsView.rating;
            if (distress == -1) {
                [UIAlertView alertViewWithTitle:@"Rate Your Distress"
                                        message:@"Please either rate your distress using the meter or tap 'Skip'."
                              cancelButtonTitle:@"Ok"];
                return;
            }
            [self recordSUDS];
            int sudsScore = sudsView.rating;
            if (sudsScore >= 9) {
                [self navigateToNextContent:[self getContentWithName:@"crisis"]];
                return;
            }
            [self navigateToNext];
        }];
    }

}

- (void)dealloc {
	[sudsView release];
    [super dealloc];
}


@end
