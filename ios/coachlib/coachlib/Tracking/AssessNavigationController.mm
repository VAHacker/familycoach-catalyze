//
//  AssessNavigationController.m
//  iStressLess
//


//

#if 0

#import "AssessNavigationController.h"
#import "QPlayer.h"
#import "QUtil.h"
#import "PCLHistoryViewController.h"
#import "ButtonGridController.h"
#import "iStressLessAppDelegate.h"
#import "heartbeat.h"
#import "VaPtsdExplorerProbesCampaign.h"

#define BUTTON_SEE_HISTORY 3000
#define BUTTON_REMIND_ME 3001
#define BUTTON_TAKE_IT_ANYWAY 3002
#define BUTTON_RETURN_TO_ROOT 3003
#define BUTTON_PROMPT_TO_SCHEDULE 3004
#define BUTTON_SCHEDULE_IN_MONTH 3005

#define DEMO_PCL 0
#define DEMO_PCL_MESSAGE @"pclHighLower"

static NSDateFormatter *localDateFormatter;
static NSDateFormatter *timeFormatter;

@implementation AssessNavigationController

-(void) privateInit {
	assessRoot = [[ButtonGridController alloc] init];
	[self replaceRootViewControllerWith:assessRoot];
    localDateFormatter = [[NSDateFormatter alloc] init];
    [localDateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    timeFormatter = [[NSDateFormatter alloc] init];
    [timeFormatter setDateFormat:@"h:mma"];
}

- (id) initWithCoder:(NSCoder *)aDecoder {
	[super initWithCoder:(NSCoder *)aDecoder];
	[self privateInit];
	return self;
}

#define SECONDS_PER_MINUTE 60.0
#define SECONDS_PER_HOUR (60.0*SECONDS_PER_MINUTE)
#define SECONDS_PER_DAY (24.0*SECONDS_PER_HOUR)
#define SECONDS_PER_WEEK (7.0*SECONDS_PER_DAY)
#define SECONDS_PER_MONTH (30.0*SECONDS_PER_DAY)

#define DEMO_LIMIT (-4*SECONDS_PER_MONTH)
/*
+ (void) setupDemo {
	if (DEMO_PCL) {
		NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
		NSManagedObjectContext *context = [iStressLessAppDelegate instance].udManagedObjectContext;
		NSEntityDescription *entity = [NSEntityDescription entityForName:@"PCLScore" inManagedObjectContext:context];
		[fetchRequest setEntity:entity];
		[fetchRequest setFetchLimit:1];
		[fetchRequest setSortDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"time" ascending:NO],nil]];
		NSArray *a = [context executeFetchRequest:fetchRequest error:NULL];
		[fetchRequest release];
		if (!a || !a.count) {
			float secondsAgo = -SECONDS_PER_MONTH;
			float score = 50;
			srand(0);
			do {
				int intScore = score;
				NSManagedObject *newPCL = [NSEntityDescription insertNewObjectForEntityForName:@"PCLScore" inManagedObjectContext:context];
				[newPCL setValue:[NSDate dateWithTimeIntervalSinceNow:secondsAgo] forKey:@"time"];
				[newPCL setValue:[NSNumber numberWithInt:intScore] forKey:@"score"];
				
				if (secondsAgo <= DEMO_LIMIT) break;
				float delta = SECONDS_PER_WEEK + ((SECONDS_PER_MONTH - SECONDS_PER_WEEK) * rand() / INT32_MAX);
				secondsAgo -= delta;
				if (secondsAgo < DEMO_LIMIT) secondsAgo = DEMO_LIMIT;
				delta = ((85.0-score) * rand() / INT32_MAX) / 3;
				score += delta;
			} while (1);
			[context save:nil];
		}
	}
}
*/

+ (NSManagedObject*)getLastPCLScore {
//	[AssessNavigationController setupDemo];

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSManagedObjectContext *context = [iStressLessAppDelegate instance].udManagedObjectContext;
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"PCLScore" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
	[fetchRequest setFetchLimit:1];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"time" ascending:NO],nil]];
	NSArray *a = [context executeFetchRequest:fetchRequest error:NULL];
	[fetchRequest release];
	if (!a || !a.count) return nil;
	return [a objectAtIndex:0];
}

int nnatoi(const char *str) {
    if (!str) return -1;
    return atoi(str);
}

NSString *nnatonss(const char *str) {
    if (!str) return nil;
    return [NSString stringWithCString:str];
}

NSArray *nnatonsna(const char *str) {
    if (!str) return nil;
    if (!str[0]) return nil;
    NSMutableArray *a = [NSMutableArray array];
    char **cstrs = QUtil::commaDelimitedToSArray(str);
    char **p = cstrs;
    while (*p) {
        [a addObject:[NSNumber numberWithInt:[[NSString stringWithCString:*p] intValue]]];
        p++;
    }
    QUtil::freeSArray(cstrs);
    
    return a;
}

- (void)questionnairePlayerHasFinished:(QPlayer*)player {
    
    QStringMap &answers = player->getAnswers();
    int totalScore = -1;
    int lastScore = -1;
    if (takingWeekly) {
        totalScore = 0;        
        for (int i=1;i<=17;i++) {
            char questionName[32];
            sprintf(questionName,"pcl%d",i);
            const char *value = answers.get(questionName);
            if (value) {
                int score = atoi(value);
                totalScore += score;
            }
        }
        
        NSManagedObject *lastScoreObj = [AssessNavigationController getLastPCLScore];
        lastScore = lastScoreObj ? [[lastScoreObj valueForKey:@"score"] intValue] : -1;
        NSDate *lastTime = lastScoreObj ? (NSDate*)[lastScoreObj valueForKey:@"time"] : nil;
        
        if (lastTime) {
            NSDate *now = [NSDate date];
            NSTimeInterval interval = [now timeIntervalSinceDate:lastTime];
            long long intervalInMillis = interval * 1000LL;
            [TimeElapsedBetweenPCLAssessmentsEvent logWithTimeElapsedBetweenPCLAssessments:intervalInMillis];
        }
        
        
        NSManagedObjectContext *context = [iStressLessAppDelegate instance].udManagedObjectContext;
        NSManagedObject *newPCL = [NSEntityDescription insertNewObjectForEntityForName:@"PCLScore" inManagedObjectContext:context];
        [newPCL setValue:[NSDate date] forKey:@"time"];
        [newPCL setValue:[NSNumber numberWithInt:totalScore] forKey:@"score"];
        [context save:nil];

        PclAssessmentEvent *pclEvent = [[PclAssessmentEvent alloc] init];
        pclEvent.pcl1 = nnatoi(answers.get("pcl1"));
        [heartbeat
         logEvent:@"pcl1"
         withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"value", nnatoi(answers.get("pcl1"))]];
         = nnatoi(answers.get("pcl2"));
         [heartbeat
          logEvent:@"pcl2"
          withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"value", nnatoi(answers.get("pcl2"))]];
        pclEvent.pcl3 = nnatoi(answers.get("pcl3"));
          [heartbeat
           logEvent:@"pcl3"
           withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"value",  nnatoi(answers.get("pcl3"))]];
        pclEvent.pcl4 = nnatoi(answers.get("pcl4"));
           [heartbeat
            logEvent:@"pcl4"
            withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"value",  nnatoi(answers.get("pcl4"))]];
        pclEvent.pcl5 = nnatoi(answers.get("pcl5"));
            [heartbeat
             logEvent:@"pcl5"
             withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"value",  nnatoi(answers.get("pcl5"))]];
        pclEvent.pcl6 = nnatoi(answers.get("pcl6"));
             [heartbeat
              logEvent:@"pcl6"
              withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"value",  nnatoi(answers.get("pcl6"))]];
        pclEvent.pcl7 = nnatoi(answers.get("pcl7"));
              [heartbeat
               logEvent:@"pcl7"
               withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"value",  nnatoi(answers.get("pcl7"))]];
        pclEvent.pcl8 = nnatoi(answers.get("pcl8"));
               [heartbeat
                logEvent:@"pcl8"
                withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"value",  nnatoi(answers.get("pcl8"))]];
        pclEvent.pcl9 = nnatoi(answers.get("pcl9"));
                [heartbeat
                 logEvent:@"pcl9"
                 withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"value",  nnatoi(answers.get("pcl9"))]];
        pclEvent.pcl10 = nnatoi(answers.get("pcl10"));
                 [heartbeat
                  logEvent:@"pcl10"
                  withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"value",  nnatoi(answers.get("pcl10"))]];
        pclEvent.pcl11 = nnatoi(answers.get("pcl11"));
                  [heartbeat
                   logEvent:@"pcl11"
                   withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"value",  nnatoi(answers.get("pcl11"))]];
        pclEvent.pcl12 = nnatoi(answers.get("pcl12"));
                   [heartbeat
                    logEvent:@"pcl12"
                    withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"value",  nnatoi(answers.get("pcl12"))]];
        pclEvent.pcl13 = nnatoi(answers.get("pcl13"));
                    [heartbeat
                     logEvent:@"pcl13"
                     withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"value",  nnatoi(answers.get("pcl13"))]];
        pclEvent.pcl14 = nnatoi(answers.get("pcl14"));
                     [heartbeat
                      logEvent:@"pcl14"
                      withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"value",  nnatoi(answers.get("pcl14"))]];
        pclEvent.pcl15 = nnatoi(answers.get("pcl15"));
                      [heartbeat
                       logEvent:@"pcl15"
                       withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"value",  nnatoi(answers.get("pcl15"))]];
        pclEvent.pcl16 = nnatoi(answers.get("pcl16"));
                       [heartbeat
                        logEvent:@"pcl16"
                        withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"value",  nnatoi(answers.get("pcl16"))]];
        pclEvent.pcl17 = nnatoi(answers.get("pcl17"));
                        [heartbeat
                         logEvent:@"pcl17"
                         withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"value",  nnatoi(answers.get("pcl17"))]];
        [[EventLog logger] log:pclEvent];
        [pclEvent release];

        [PclAssessmentCompletedEvent logWithPclAssessmentCompletedFinalScore:totalScore withPclAssessmentCompleted:1];
        
        [heartbeat
         logEvent:@"ASSESSMENT"
         withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"completed",@"yes",@"score",[NSString stringWithFormat:@"%d",totalScore],@"lastScore",[NSString stringWithFormat:@"%d",lastScore], nil]];

#ifdef EXPLORER_EMA
        Phq9SurveyEvent *phqEvent = [[Phq9SurveyEvent alloc] init];
        phqEvent.phq91 = nnatoi(answers.get("phq91"));
                         [heartbeat
                          logEvent:@"phq91"
                          withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"value", nnatoi(answers.get("phq91"))]];
        phqEvent.phq92 = nnatoi(answers.get("phq92"));
                          [heartbeat
                           logEvent:@"phq92"
                           withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"value", nnatoi(answers.get("phq92"))]];
        phqEvent.phq93 = nnatoi(answers.get("phq93"));
                           [heartbeat
                            logEvent:@"phq93"
                            withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"value", nnatoi(answers.get("phq93"))]];
        phqEvent.phq94 = nnatoi(answers.get("phq94"));
                            [heartbeat
                             logEvent:@"phq94"
                             withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"value", nnatoi(answers.get("phq94"))]];
        phqEvent.phq95 = nnatoi(answers.get("phq95"));
                             [heartbeat
                              logEvent:@"phq95"
                              withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"value", nnatoi(answers.get("phq95"))]];
        phqEvent.phq96 = nnatoi(answers.get("phq96"));
                              [heartbeat
                               logEvent:@"phq96"
                               withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"value", nnatoi(answers.get("phq96"))]];
        phqEvent.phq97 = nnatoi(answers.get("phq97"));
                               [heartbeat
                                logEvent:@"phq97"
                                withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"value", nnatoi(answers.get("phq97"))]];
        phqEvent.phq98 = nnatoi(answers.get("phq98"));
                                [heartbeat
                                 logEvent:@"phq98"
                                 withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"value",  nnatoi(answers.get("phq98"))]];
        phqEvent.phq99 = nnatoi(answers.get("phq99"));
                                 [heartbeat
                                  logEvent:@"phq99"
                                  withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"value",  nnatoi(answers.get("phq99"))]];
        [[EventLog logger] log:phqEvent];
        [phqEvent release];
        
        int howDifficult = nnatoi(answers.get("functioning"));
                                  [heartbeat
                                   logEvent:@"howdificult"
                                   withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"value",  = nnatoi(answers.get("functioning"))]];
        [FunctioningAssessmentEvent logWithHowDifficult:howDifficult];
#endif
    }
    
#ifdef EXPLORER_EMA
    if (takingDaily) {
        DailyAssessmentEvent *dailyEvent = [[DailyAssessmentEvent alloc] init];
        dailyEvent.overallMood = nnatoi(answers.get("overallMood"));
        [heartbeat
         logEvent:@"overallMood"
         withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"value", nnatoi(answers.get("overallMood"))]];
        dailyEvent.sleepWell = nnatoi(answers.get("sleepWell"));
         [heartbeat
          logEvent:@"sleepWell"
          withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"value", nnatoi(answers.get("sleepWell"))]];
        dailyEvent.howMuchAnger = nnatoi(answers.get("howMuchAnger"));
          [heartbeat
           logEvent:@"howMuchAnger"
           withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"value", nnatoi(answers.get("howMuchAnger"))]];
        dailyEvent.conflictWithOthers = nnatoi(answers.get("conflictWithOthers"));
           [heartbeat
            logEvent:@"conflictWithOthers"
            withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"value", nnatoi(answers.get("conflictWithOthers"))]];
        dailyEvent.needForCoping = nnatoi(answers.get("needForCoping"));
            [heartbeat
             logEvent:@"needForCoping"
             withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"value", nnatoi(answers.get("needForCoing"))]];
        dailyEvent.copingSituations = nnatonss(answers.get("copingSituations"));
             [heartbeat
              logEvent:@"copingSituations"
              withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"value", nnatoi(answers.get("copingSituations"))]];
        dailyEvent.overallCoping = nnatoi(answers.get("overallCoping"));
              [heartbeat
               logEvent:@"overallCoping"
               withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"value", nnatoi(answers.get("overallCoping"))]];
        dailyEvent.qualityOfGettingThingsDone = nnatoi(answers.get("qualityOfGettingThingsDone"));
               [heartbeat
                logEvent:@"qualityOfGettingThingsDone"
                withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"value", nnatoi(answers.get("qualityOfGettingThingsDone"))]];
        dailyEvent.copingToolsUsed = nnatonsna(answers.get("copingToolsUsed"));
                [heartbeat
                 logEvent:@"copingToolsUsed"
                 withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"value", nnatoi(answers.get("copingToolsUsed"))]];
        dailyEvent.copingSupport = nnatoi(answers.get("copingSupport"));
                 [heartbeat
                  logEvent:@"copingSupport"
                  withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"value", = nnatoi(answers.get("copingSupport"))]];
        dailyEvent.takePrescribedMedications = nnatoi(answers.get("takePrescribedMedications"));
                  [heartbeat
                   logEvent:@"takePrescribedMedications"
                   withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"value", nnatoi(answers.get("takePrescribedMedications"))]];
        dailyEvent.medicationSideEffects = nnatoi(answers.get("medicationSideEffects"));
                   [heartbeat
                    logEvent:@"medicationSideEffects"
                    withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"value", nnatoi(answers.get("medicationSideEffects"))]];
        dailyEvent.drinkAlcohol = nnatoi(answers.get("drinkAlcohol"));
                    [heartbeat
                     logEvent:@"drinkAlcohol"
                     withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"value", nnatoi(answers.get("drinkAlcohol"))]];
        dailyEvent.howMuchAlcohol = nnatoi(answers.get("howMuchAlcohol"));
                     [heartbeat
                      logEvent:@"howMuchAlcohol"
                      withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"value",  nnatoi(answers.get("howMuchAlcohol"))]];
        dailyEvent.takeNonPrescribedDrug = nnatoi(answers.get("takeNonPrescribedDrug"));
                      [heartbeat
                       logEvent:@"howMuchNanger"
                       withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"value",  nnatoi(answers.get("howMuchAnger"))]];
        [[EventLog logger] log:dailyEvent];
        [dailyEvent release];
        
        NSDate *now = [NSDate date];
        NSString *lastDailyAssessmentTimeStr = [localDateFormatter stringFromDate:now];
                       [heartbeat
                        logEvent:@"lastDailyAssessmentTimeStr"
                        withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"value",  lastDailyAssessmentTimeStr]];
                        [[iStressLessAppDelegate instance] setSetting:@"lastDailyAssessmentTime" to:lastDailyAssessmentTimeStr];
    }
    
	ContentViewController *cvc = [[iStressLessAppDelegate instance] getContentControllerWithName:@"assessmentFinished"];
	cvc.masterController = self;
    [cvc addButton:BUTTON_RETURN_TO_ROOT withText:@"Done"];
	[(GNavigationController*)self pushViewControllerAndRemoveAllPrevious:cvc];
    
#else
    
    if (takingWeekly) {
        NSString *absStr = nil;
        NSString *relStr = nil;

        if (totalScore >= 50) {
            absStr = @"High";
        } else if (totalScore >= 30) {
            absStr = @"Mid";
        } else if (totalScore == 17) {
            absStr = @"Bottom";
        } else {
            absStr = @"Low";
        }
        
        if (lastScore == -1) {
            relStr = @"First";
        } else if (totalScore > lastScore) {
            relStr = @"Higher";
        } else if (totalScore == lastScore) {
            relStr = @"Same";
        } else {
            relStr = @"Lower";
        }
        
        NSString *pclResultName = [NSString stringWithFormat:@"pcl%@%@",absStr,relStr];
        
        ContentViewController *cvc = [[iStressLessAppDelegate instance] getContentControllerWithName:pclResultName];
        cvc.masterController = self;

        NSString *currentPCLScheduling = [[iStressLessAppDelegate instance] getSetting:@"pclScheduled"];
        if (!currentPCLScheduling || [currentPCLScheduling isEqual:@""] || [currentPCLScheduling isEqual:@"none"]) {
            [cvc addButton:BUTTON_PROMPT_TO_SCHEDULE withText:@"Next"];
        } else {
            [AssessNavigationController schedulePCLReminderAtInterval:currentPCLScheduling];
            [cvc addButton:BUTTON_SEE_HISTORY withText:@"See Symptom History"];
        }
        [(GNavigationController*)self pushViewControllerAndRemoveAllPrevious:cvc];
    }
#endif
    
    takingDaily = FALSE;
    takingWeekly = FALSE;
    delete player;
}

+(void) schedulePCLReminder:(double)secondsFromLast tookItBefore:(BOOL)before withRepeat:(BOOL)repeat {
	UILocalNotification *n = [[UILocalNotification alloc] init];
	NSManagedObject *lastScoreObj = [AssessNavigationController getLastPCLScore];
	NSDate *lastTime = lastScoreObj ? (NSDate*)[lastScoreObj valueForKey:@"time"] : [NSDate date];
	n.fireDate = [NSDate dateWithTimeInterval:secondsFromLast sinceDate:lastTime];
	n.timeZone = [NSTimeZone defaultTimeZone];
	if (before) {
		n.alertBody = [NSString stringWithFormat:@"It has been %@ since you took your PTSD Coach assessment.  Would you like to take it now?", [AssessNavigationController timeIntervalToString:secondsFromLast]];
	} else {
		n.alertBody = @"You asked me to remind you to take your PTSD Coach assessment around now.  Would you like to take it now?";
	}
    [heartbeat
     logEvent:@"reminderShown"
     withParameters:nil];
    
	n.alertAction = @"Do it";
	n.soundName = UILocalNotificationDefaultSoundName;
	n.applicationIconBadgeNumber = 1;
	n.repeatInterval = NSDayCalendarUnit;
    
	[[UIApplication sharedApplication] cancelAllLocalNotifications];
	[[UIApplication sharedApplication] scheduleLocalNotification:n];
    
    [PclReminderScheduledEvent logWithPclReminderScheduledTimestamp:[n.fireDate timeIntervalSince1970] * 1000LL];
    
	[n release];
}

+(void) schedulePCLReminderAtInterval:(NSString*)interval {
	[[iStressLessAppDelegate instance] setSetting:@"pclScheduled" to:interval];
	if ([interval isEqual:@"none"]) {
		[[UIApplication sharedApplication] cancelAllLocalNotifications];
	} else {
		NSManagedObject *lastScoreObj = [AssessNavigationController getLastPCLScore];
		BOOL before = lastScoreObj != NULL;
		if ([interval isEqual:@"minute"]) {
			[self schedulePCLReminder:(double)60 tookItBefore:before withRepeat:TRUE];
            [heartbeat
             logEvent:@"reminderInterval"
             withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"value",  @"minute"]];
		} else if ([interval isEqual:@"week"]) {
			[self schedulePCLReminder:(double)7*24*60*60 tookItBefore:before withRepeat:TRUE];
            [heartbeat
             logEvent:@"reminderInterval"
             withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"value",  @"week"]];
		} else if ([interval isEqual:@"month"]) {
			[self schedulePCLReminder:(double)30*24*60*60 tookItBefore:before withRepeat:TRUE];
            [heartbeat
             logEvent:@"reminderInterval"
             withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"value",  @"month"]];
		} else if ([interval isEqual:@"twoweek"]) {
			[self schedulePCLReminder:(double)14*24*60*60 tookItBefore:before withRepeat:TRUE];
            [heartbeat
             logEvent:@"reminderInterval"
             withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"value",  @"twoweek"]];
		} else if ([interval isEqual:@"threemonth"]) {
			[self schedulePCLReminder:(double)90*24*60*60 tookItBefore:before withRepeat:TRUE];
            [heartbeat
             logEvent:@"reminderInterval"
             withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"value",  @"threemonth"]];
		} else {
			UIAlertView *alert = 
			[[UIAlertView alloc] initWithTitle:@"Internal Error" 
									   message:@"Bad Scheduler Interval"  
									  delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
			[alert show];
			[alert release];
		}
	}
}

+(void) scheduleDailyAndWeeklyRemindersAtTimeOfDay:(NSDate*)timeOfDay onDayOfWeek:(int)dayOfWeek {
    NSString *dayOfWeekStr = [NSString stringWithFormat:@"%d", dayOfWeek];
    NSString *timeOfDayStr = [timeFormatter stringFromDate:timeOfDay];
    [heartbeat
     logEvent:@"reminderDayOfWeek"
     withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"value",  dayOfWeekStr]];
     [heartbeat
      logEvent:@"reminderTime"
      withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"value",  timeofDayStr]];
    [[iStressLessAppDelegate instance] setSetting:@"assessmentDayOfWeek" to:dayOfWeekStr];
    [[iStressLessAppDelegate instance] setSetting:@"assessmentTimeOfDay" to:timeOfDayStr];
    [AssessNavigationController scheduleDailyAndWeeklyReminders];
}

+ (void) scheduleDailyAndWeeklyReminders {
    NSString *timeOfDayStr = [[iStressLessAppDelegate instance] getSetting:@"assessmentTimeOfDay"];
    NSDate *timeOfDay = [timeFormatter dateFromString:timeOfDayStr];

    UILocalNotification *n = [[UILocalNotification alloc] init];

    NSDate *now = [NSDate date];
    NSCalendar *cal = [NSCalendar currentCalendar];

    NSDateComponents *components = [cal components:NSHourCalendarUnit|NSMinuteCalendarUnit fromDate:timeOfDay];
    int hour = [components hour];
    int minute = [components minute];

    components = [cal components:0xFFFF fromDate:now];
    [components setHour:hour];
    [components setMinute:minute];
    [components setSecond:0];

    NSDate *nextAlert = [cal dateFromComponents:components];
    if ([nextAlert compare:now] != NSOrderedDescending) {
        NSDateComponents *additionalDay = [[NSDateComponents alloc] init];
        [additionalDay setDay:1];
        nextAlert = [cal dateByAddingComponents:additionalDay toDate:nextAlert options:0];
        [additionalDay release];
    }
    
	n.fireDate = nextAlert;
	n.timeZone = [NSTimeZone defaultTimeZone];
    [heartbeat
     logEvent:@"reminderFired"
     withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"value",  dayOfWeekStr]];
    n.alertBody = @"You have a PTSD Explorer assessment due.  Take it now?";
	n.alertAction = @"Do it";
	n.soundName = UILocalNotificationDefaultSoundName;
	n.applicationIconBadgeNumber = 1;
	n.repeatInterval = NSDayCalendarUnit;
    
	[[UIApplication sharedApplication] cancelAllLocalNotifications];
	[[UIApplication sharedApplication] scheduleLocalNotification:n];
    
	[n release];
}

- (NSDate*)setTimeOfDayFor:(NSDate*)dateTime to:(NSDate*)timeOfDay {
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *todComponents = [cal components:NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit fromDate:timeOfDay];
    NSDateComponents *currentComponents = [cal components:(NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit) fromDate:dateTime];
    NSDateComponents *deltaComponents = [[NSDateComponents alloc] init];
    deltaComponents.hour = currentComponents.hour - todComponents.hour;
    deltaComponents.minute = currentComponents.minute - todComponents.minute;
    deltaComponents.second = currentComponents.second - todComponents.second;
    NSDate *newDate = [cal dateByAddingComponents:deltaComponents toDate:dateTime options:0];
    [deltaComponents release];
    return newDate;
}

- (BOOL)dailyIsDue {
/*
    NSDate *now = [NSDate date];
    NSString *timeOfDayStr = [[iStressLessAppDelegate instance] getSetting:@"assessmentTimeOfDay"];
    NSDate *timeOfDay = [timeFormatter dateFromString:timeOfDayStr];

    NSString *lastDailyAssessmentTimeStr = [[iStressLessAppDelegate instance] getSetting:@"lastDailyAssessmentTime"];
    if (lastDailyAssessmentTimeStr == nil) return TRUE;
    NSDate *lastDailyAssessmentTime = lastDailyAssessmentTimeStr ? [localDateFormatter dateFromString:lastDailyAssessmentTimeStr] : nil;
    lastDailyAssessmentTime = [self setTimeOfDayFor:lastDailyAssessmentTime to:timeOfDay];
    
    double secondsSinceLastDaily = lastDailyAssessmentTime ? [now timeIntervalSinceDate:lastDailyAssessmentTime] : [now timeIntervalSince1970];
    double daysSinceLastDaily = ((secondsSinceLastDaily / 60)/60)/24;
    return daysSinceLastDaily >= 1;
*/
    
    // New logic: say the test is due if we are in the next calendar day, but use 4am as the day delimiter
    NSString *lastDailyAssessmentTimeStr = [[iStressLessAppDelegate instance] getSetting:@"lastDailyAssessmentTime"];
    if (lastDailyAssessmentTimeStr == nil) return TRUE;
    NSDate *lastDailyAssessmentTime = lastDailyAssessmentTimeStr ? [localDateFormatter dateFromString:lastDailyAssessmentTimeStr] : nil;
    NSDate *now = [NSDate date];
    
    NSCalendar *cal = [NSCalendar currentCalendar];
    
    NSDateComponents *nowComponents = 
        [cal components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit 
               fromDate:[now dateByAddingTimeInterval:-60*60*4]];

    NSDateComponents *lastComponents = 
        [cal components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit 
           fromDate:[lastDailyAssessmentTime dateByAddingTimeInterval:-60*60*4]];

    if ((nowComponents.day != lastComponents.day) || 
        (nowComponents.month != lastComponents.month) || 
        (nowComponents.year != lastComponents.year)) {
        return TRUE;
    }
    
    return FALSE;
}
    
- (BOOL)weeklyIsDue {
    NSDate *now = [NSDate date];
    NSString *timeOfDayStr = [[iStressLessAppDelegate instance] getSetting:@"assessmentTimeOfDay"];
    NSDate *timeOfDay = [timeFormatter dateFromString:timeOfDayStr];
    NSString *dayOfWeekStr = [[iStressLessAppDelegate instance] getSetting:@"assessmentDayOfWeek"];
    int dayOfWeek = dayOfWeekStr ? [dayOfWeekStr intValue] + 1 : 1;

    NSManagedObject *lastScoreObj = [AssessNavigationController getLastPCLScore];
    NSDate *lastScoreTime = (NSDate*)[lastScoreObj valueForKey:@"time"];
    lastScoreTime = [self setTimeOfDayFor:lastScoreTime to:timeOfDay];

    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *weekdayNow = [cal components:NSWeekdayCalendarUnit fromDate:lastScoreTime];
    NSDateComponents *componentsToAdd = [[NSDateComponents alloc] init];
    int weekday = [weekdayNow weekday];
    if (weekday == dayOfWeek) {
        [componentsToAdd setDay:7];
    } else if (weekday < dayOfWeek) {
        [componentsToAdd setDay:dayOfWeek - weekday];
    } else {
        [componentsToAdd setDay:7 - (weekday - dayOfWeek)];
    }
    
    NSDate *nextWeeklyAssessmentDue = [cal dateByAddingComponents:componentsToAdd toDate:lastScoreTime options:0];
    double secondsSinceLastWeekly = nextWeeklyAssessmentDue ? [now timeIntervalSinceDate:nextWeeklyAssessmentDue] : [now timeIntervalSince1970];
    double daysSinceLastWeekly = ((secondsSinceLastWeekly / 60)/60)/24;
    return daysSinceLastWeekly > 7;
}

-(void) buttonSelected:(int)buttonID {
	if (buttonID == BUTTON_SEE_HISTORY) {
		[self replaceRootViewControllerWith:assessRoot];
		[self popToRootViewControllerAnimated:FALSE];
		[self seeHistory];
	} else if (buttonID == BUTTON_REMIND_ME) {
		[[iStressLessAppDelegate instance] setSetting:@"pclScheduled" to:@"week"];
		[AssessNavigationController schedulePCLReminder:(double)7*24*60*60 tookItBefore:TRUE withRepeat:TRUE];
		[self setVariable:@"pclScheduledWhen" to:@"one week"];
		ContentViewController *cvc = [[iStressLessAppDelegate instance] getContentControllerWithName:@"pclScheduled"];
		cvc.masterController = self;
		cvc.navigationItem.hidesBackButton = TRUE;
		[cvc addButton:BUTTON_RETURN_TO_ROOT withText:@"Ok"];
		[(GNavigationController*)self pushViewController:cvc animated:TRUE];
	} else if (buttonID == BUTTON_TAKE_IT_ANYWAY) {
//		[self popViewControllerAnimated:FALSE];
		[self takeAssessment:TRUE];
	} else if (buttonID == BUTTON_PROMPT_TO_SCHEDULE) {
		ContentViewController *cvc = [[iStressLessAppDelegate instance] getContentControllerWithName:@"pclSchedulePrompt"];
		cvc.masterController = self;
		[cvc addButton:BUTTON_SEE_HISTORY withText:@"No, thanks"];
		[cvc addButton:BUTTON_SCHEDULE_IN_MONTH withText:@"Schedule the reminder"];
		[(GNavigationController*)self pushViewControllerAndRemoveAllPrevious:cvc];
	} else if (buttonID == BUTTON_SCHEDULE_IN_MONTH) {
		[[iStressLessAppDelegate instance] setSetting:@"pclScheduled" to:@"month"];
		[AssessNavigationController schedulePCLReminder:(double)30*24*60*60 tookItBefore:TRUE withRepeat:TRUE];
		[self setVariable:@"pclScheduledWhen" to:@"one month"];
		ContentViewController *cvc = [[iStressLessAppDelegate instance] getContentControllerWithName:@"pclScheduled"];
		cvc.masterController = self;
		cvc.navigationItem.hidesBackButton = TRUE;
		[cvc addButton:BUTTON_SEE_HISTORY withText:@"See Assessment History"];
		[(GNavigationController*)self pushViewController:cvc animated:TRUE];
	} else if (buttonID == BUTTON_RETURN_TO_ROOT) {
		[(GNavigationController*)self replaceRootViewControllerWith:assessRoot];
		[(GNavigationController*)self popToRootViewControllerAnimated:TRUE];
	} else {
		[super buttonSelected:(int)buttonID];
	}
}

- (BOOL) onAppSuspend {
    if (takingWeekly || takingDaily) return TRUE;
    return [super onAppSuspend];
}

- (void)questionnairePlayerWasCancelled:(QPlayer*)player {
    takingDaily = FALSE;
    takingWeekly = FALSE;

    [PclAssessmentAbortedEvent logWithPclAssessmentAbortedTimestamp:[EventLog timestamp]];
    [PclAssessmentCompletedEvent logWithPclAssessmentCompletedFinalScore:-1 withPclAssessmentCompleted:0];

    [heartbeat
     logEvent:@"ASSESSMENT"
     withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"completed",@"no",nil]];
    
	[self replaceRootViewControllerWith:assessRoot];
	[self popToRootViewControllerAnimated:TRUE];
	delete player;
}

NSString *numbersToWords[] = {
	nil,
	@"one",
	@"two",
	@"three",
	@"four",
	@"five",
	@"six",
	@"seven",
	@"eight",
	@"nine",
	@"ten",
	@"eleven",
	@"twelve",
	@"thirteen",
	@"fourteen",
	@"fifteen",
	@"sixteen",
	@"seventeen",
	@"eighteen",
	@"nineteen",
	@"twenty",
	@"twenty-one",
	@"twenty-two",
	@"twenty-three",
	@"twenty-four"
};

+ (NSString*) timeIntervalToString:(double)interval {
	double minutesInternal = (interval / 60);
	double hoursInterval = ((interval / 60) / 60);
	double daysInterval = ((interval / 60) / 60) / 24;
	if (interval < 50) {
		int seconds = interval;
		if (seconds == 0) seconds = 1;
		return [NSString stringWithFormat:@"%@ second%@",numbersToWords[seconds],(seconds > 1) ? @"s" : @"" ];
	} else if (minutesInternal < 20) {
		int minutes = minutesInternal;
		if (minutes == 0) minutes = 1;
		return [NSString stringWithFormat:@"%@ minute%@",numbersToWords[minutes],(minutes > 1) ? @"s" : @"" ];
	} else if (hoursInterval < 20) {
		int hours = hoursInterval;
		if (hours == 0) hours = 1;
		return [NSString stringWithFormat:@"%@ hour%@",numbersToWords[hours],(hours > 1) ? @"s" : @"" ];
	} else if (daysInterval < 6) {
		int days = daysInterval;
		return [NSString stringWithFormat:@"%@ day%@",numbersToWords[days],(days > 1) ? @"s" : @"" ];
	} else if ((daysInterval < 27)) {
		int weeks = daysInterval / 7;
		if (weeks == 0) weeks = 1;
		return [NSString stringWithFormat:@"%@ week%@",numbersToWords[weeks],(weeks > 1) ? @"s" : @"" ];
	} else {
		int months = daysInterval / 30;
		if (months == 0) months = 1;
		return [NSString stringWithFormat:@"%@ month%@",numbersToWords[months],(months > 1) ? @"s" : @"" ];
	}
}

- (void) takeAssessment:(BOOL)force {
	BOOL tooSoonWeekly = FALSE;
	BOOL tooSoonDaily = FALSE;

    NSDate *now = [NSDate date];

    NSString *lastDailyAssessmentTimeStr = [[iStressLessAppDelegate instance] getSetting:@"lastDailyAssessmentTime"];
    NSDate *lastDailyAssessmentTime = lastDailyAssessmentTimeStr ? [localDateFormatter dateFromString:lastDailyAssessmentTimeStr] : nil;

#ifdef EXPLORER_EMA
    if (![self dailyIsDue]) tooSoonDaily = TRUE;
    if (![self weeklyIsDue]) tooSoonWeekly = TRUE;
#endif

    NSString *pclSince = @"in the time since you last took this assessment";
	NSString *pclLastTime = @"just recently";
	NSManagedObject *lastScoreObj = [AssessNavigationController getLastPCLScore];
	if (!lastScoreObj) {
		pclSince = @"in the past month";
		pclLastTime = @"a month ago";
	} else {
		NSDate *lastScoreTime = (NSDate*)[lastScoreObj valueForKey:@"time"];
		double secondsSinceLastTime = [now timeIntervalSinceDate:lastScoreTime];
		double daysSinceLastTime = ((secondsSinceLastTime / 60)/60)/24;
#ifndef EXPLORER_EMA
        if (daysSinceLastTime < 6) tooSoonWeekly = TRUE;
#endif
		if (daysSinceLastTime < 1) {
			pclSince = @"in the time since you last took this assessment";
			pclLastTime = @"less than a day ago";
		} else if (daysSinceLastTime < 6) {
			int days = daysSinceLastTime;
			pclSince = [NSString stringWithFormat:@"in the past %@ day%@",numbersToWords[days],(days > 1) ? @"s" : @""];
			pclLastTime = [NSString stringWithFormat:@"%@ day%@ ago",numbersToWords[days],(days > 1) ? @"s" : @"" ];
		} else if ((daysSinceLastTime < 27)) {
			int weeks = daysSinceLastTime / 7;
			if (weeks == 0) weeks = 1;
			pclSince = [NSString stringWithFormat:@"in the past %@ week%@",numbersToWords[weeks],(weeks > 1) ? @"s" : @""];
			pclLastTime = [NSString stringWithFormat:@"%@ week%@ ago",numbersToWords[weeks],(weeks > 1) ? @"s" : @"" ];
		} else {
			int months = daysSinceLastTime / 30;
			if (months == 0) months = 1;
			pclSince = [NSString stringWithFormat:@"in the past %@ month%@",numbersToWords[months],(months > 1) ? @"s" : @""];
			pclLastTime = [NSString stringWithFormat:@"%@ month%@ ago",numbersToWords[months],(months > 1) ? @"s" : @"" ];
		}
	}
	
	NSString *pclSinceCap = [[[pclSince substringToIndex:1] capitalizedString] stringByAppendingString:[pclSince substringFromIndex:1]];
	
	[self setVariable:@"pclSince" to:pclSince];
	[self setVariable:@"pclSinceCap" to:pclSinceCap];
	[self setVariable:@"pclLastTime" to:pclLastTime];
	
#ifdef EXPLORER_EMA
    if (tooSoonDaily && tooSoonWeekly) {
        ContentViewController *cvc = [[iStressLessAppDelegate instance] getContentControllerWithName:@"assessmentTooSoon"];
        cvc.masterController = self;
        [cvc addButton:BUTTON_RETURN_TO_ROOT withText:@"Go Back"];
        [self pushViewController:cvc animated:TRUE];
        return;
    }
    
    if (!force) {
        if (tooSoonWeekly) {
            ContentViewController *cvc = [[iStressLessAppDelegate instance] getContentControllerWithName:@"assessmentDailyOnly"];
            cvc.masterController = self;
            [cvc addButton:BUTTON_RETURN_TO_ROOT withText:@"Go Back"];
            [cvc addButton:BUTTON_TAKE_IT_ANYWAY withText:@"Take It Now"];
            [self pushViewController:cvc animated:TRUE];
            return;
        } else if (tooSoonDaily) {
            ContentViewController *cvc = [[iStressLessAppDelegate instance] getContentControllerWithName:@"assessmentWeeklyOnly"];
            cvc.masterController = self;
            [cvc addButton:BUTTON_RETURN_TO_ROOT withText:@"Go Back"];
            [cvc addButton:BUTTON_TAKE_IT_ANYWAY withText:@"Take It Now"];
            [self pushViewController:cvc animated:TRUE];
            return;
        } else {
            ContentViewController *cvc = [[iStressLessAppDelegate instance] getContentControllerWithName:@"assessmentDailyAndWeekly"];
            cvc.masterController = self;
            [cvc addButton:BUTTON_RETURN_TO_ROOT withText:@"Go Back"];
            [cvc addButton:BUTTON_TAKE_IT_ANYWAY withText:@"Take It Now"];
            [self pushViewController:cvc animated:TRUE];
            return;
        }
    }
#else
	if (tooSoonWeekly && !force) {
		ContentViewController *cvc = [[iStressLessAppDelegate instance] getContentControllerWithName:@"pclTooSoon"];
		cvc.masterController = self;
		[cvc addButton:BUTTON_REMIND_ME withText:@"Remind me after a week"];
		[cvc addButton:BUTTON_TAKE_IT_ANYWAY withText:@"Take it now"];
		[self pushViewController:cvc animated:TRUE];
		return;
	}
#endif
    
#ifdef EXPLORER_EMA
    if (!tooSoonWeekly) {
#endif
        [PclAssessmentStartedEvent logWithPclAssessmentStarted:[EventLog timestamp]];

        [heartbeat
         logEvent:@"ASSESSMENT" 
         timed:YES];
#ifdef EXPLORER_EMA
    }
#endif

	QPlayer *player = new QPlayer(self);
#ifdef EXPLORER_EMA
    if (!tooSoonWeekly) {
        takingWeekly = TRUE;
        player->addQuestionnaire([[NSBundle mainBundle] pathForResource:@"pcl_no_intro" ofType:@"xml" inDirectory:@"Content"]);
        player->addQuestionnaire([[NSBundle mainBundle] pathForResource:@"phq9" ofType:@"xml" inDirectory:@"Content"]);
    }
    if (!tooSoonDaily) {
        takingDaily = TRUE;
        player->addQuestionnaire([[NSBundle mainBundle] pathForResource:@"daily" ofType:@"xml" inDirectory:@"Content"]);
    }
#else
    takingWeekly = TRUE;
    player->addQuestionnaire([[NSBundle mainBundle] pathForResource:@"pcl" ofType:@"xml" inDirectory:@"Content"]);
#endif
	player->setDelegate(self);
	player->play();
}

-(void) managedObjectSelected:(NSManagedObject*)mo {
	NSString *name = [mo valueForKey:@"name"];
	if ([name isEqual:@"takeAssessment"]) {
		[self takeAssessment:FALSE];
	} else if ([name isEqual:@"trackHistory"]) {
		[self seeHistory];
#ifdef EXPLORER_EMA        
    } else if ([name isEqual:@"scheduleAssessments"]) {
		ContentViewController *cvc = [[iStressLessAppDelegate instance] getContentControllerWithName:@"emaScheduleAssessments"];
		cvc.masterController = self;
		[self pushViewController:cvc animated:TRUE];
#endif       
	} else {
		[super managedObjectSelected:(NSManagedObject *)mo];
	}
}

- (void) dealloc {	
	[assessRoot release];

	[super dealloc];
}

@end

#endif
