//
//  TrackingTopView.m
//  iStressLess
//


//

#import "QuestionnaireContentController.h"
#import "QuestionnaireParser.h"
#import "QQuestionnaire.h"
#import "QHandler.h"
#import "QPlayer.h"
#include "QStringMap.h"
#import "VaPtsdExplorerProbesCampaign.h"
#import "heartbeat.h"
#include "QUtil.h"
#import "iStressLessAppDelegate.h"

@implementation QuestionnaireContentController

static NSDateFormatter *localDateFormatter=nil;
static NSDateFormatter *timeFormatter=nil;

+(void) privateInit {
    if (!localDateFormatter) {
        localDateFormatter = [[NSDateFormatter alloc] init];
        [localDateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
        timeFormatter = [[NSDateFormatter alloc] init];
        [timeFormatter setDateFormat:@"h:mma"];
    }
}

static int nnatoi(const char *str) {
    if (!str) return -1;
    return atoi(str);
}

static NSString *nnatonss(const char *str) {
    if (!str) return nil;
    return [NSString stringWithUTF8String:str];
}

static NSArray *nnatonsna(const char *str) {
    if (!str) return nil;
    if (!str[0]) return nil;
    NSMutableArray *a = [NSMutableArray array];
    char **cstrs = QUtil::commaDelimitedToSArray(str);
    char **p = cstrs;
    while (*p) {
        [a addObject:[NSNumber numberWithInt:[[NSString stringWithUTF8String:*p] intValue]]];
        p++;
    }
    QUtil::freeSArray(cstrs);
    
    return a;
}

+(void) scheduleAssessmentReminderFor:(NSString*)series at:(NSDate*)nextTime tookItBefore:(BOOL)before withRepeat:(BOOL)repeat andUserInfo:(NSDictionary*)dict {
	NSString *appName = [[iStressLessAppDelegate instance] getContentTextWithName:@"APP_NAME"];
	UILocalNotification *n = [[UILocalNotification alloc] init];
	NSManagedObject *lastScoreObj = [QuestionnaireContentController getLastTimeSeriesEntry:series];
	NSDate *lastTime = lastScoreObj ? (NSDate*)[lastScoreObj valueForKey:@"time"] : [NSDate date];

	n.fireDate = nextTime;//[NSDate dateWithTimeInterval:secondsFromLast sinceDate:lastTime];
    double secondsFromLast = [nextTime timeIntervalSinceDate:lastTime];

	n.timeZone = [NSTimeZone defaultTimeZone];
	if (before) {
		n.alertBody = [NSString stringWithFormat:@"It has been %@ since you took your %@ assessment.  Would you like to take it now?", [QuestionnaireContentController timeIntervalToString:secondsFromLast], appName];
	} else {
		n.alertBody = [NSString stringWithFormat:@"You asked me to remind you to take your %@ assessment around now.  Would you like to take it now?",appName];
	}
	n.alertAction = @"Do it";
	n.soundName = UILocalNotificationDefaultSoundName;
	n.applicationIconBadgeNumber = 1;
	n.repeatInterval = NSDayCalendarUnit;
    n.userInfo = dict;
    
	[[UIApplication sharedApplication] cancelAllLocalNotifications];
	[[UIApplication sharedApplication] scheduleLocalNotification:n];
    
    [PclReminderScheduledEvent logWithPclReminderScheduledTimestamp:[n.fireDate timeIntervalSince1970] * 1000LL];
    
	[n release];
}

+(NSDate*) addDelta:(NSString*)interval toDate:(NSDate*)lastTime {
    NSCalendar *cal = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
    NSDateComponents *comps = [[[NSDateComponents alloc] init] autorelease];
    if ([interval isEqual:@"minute"]) {
        comps.minute = 1;
    } else if ([interval isEqual:@"week"]) {
        comps.week = 1;
    } else if ([interval isEqual:@"month"]) {
        comps.month = 1;
    } else if ([interval isEqual:@"twoweek"]) {
        comps.week = 2;
    } else if ([interval isEqual:@"threemonth"]) {
        comps.month = 3;
    } else {
        UIAlertView *alert =
        [[UIAlertView alloc] initWithTitle:@"Internal Error"
                                   message:@"Bad Scheduler Interval"
                                  delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
    
    NSDate *nextTime = [cal dateByAddingComponents:comps toDate:lastTime options:0];
    return nextTime;
}
    
+(void) scheduleAssessmentReminderFor:(NSString*)series atInterval:(NSString*)interval andUserInfo:(NSDictionary*)dict {
    NSString *scheduledSetting = [NSString stringWithFormat:@"%@Scheduled",series];
	[[iStressLessAppDelegate instance] setSetting:scheduledSetting to:interval];
	if ([interval isEqual:@"none"]) {
		[[UIApplication sharedApplication] cancelAllLocalNotifications];
	} else {
		NSManagedObject *lastScoreObj = [QuestionnaireContentController getLastTimeSeriesEntry:series];
        NSDate *lastTime = lastScoreObj ? (NSDate*)[lastScoreObj valueForKey:@"time"] : [NSDate date];
		BOOL before = lastScoreObj != NULL;
        NSDate *nextTime = [QuestionnaireContentController addDelta:interval toDate:lastTime];
        [self scheduleAssessmentReminderFor:series at:nextTime tookItBefore:before withRepeat:TRUE andUserInfo:dict];
        
	}
}

+(void) scheduleDailyAndWeeklyRemindersAtTimeOfDay:(NSDate*)timeOfDay onDayOfWeek:(int)dayOfWeek {
    NSString *dayOfWeekStr = [NSString stringWithFormat:@"%d", dayOfWeek];
    NSString *timeOfDayStr = [timeFormatter stringFromDate:timeOfDay];
    [[iStressLessAppDelegate instance] setSetting:@"assessmentDayOfWeek" to:dayOfWeekStr];
    [[iStressLessAppDelegate instance] setSetting:@"assessmentTimeOfDay" to:timeOfDayStr];
    [QuestionnaireContentController scheduleDailyAndWeeklyReminders];
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
    
	NSString *appName = [[iStressLessAppDelegate instance] getContentTextWithName:@"APP_NAME"];

	n.fireDate = nextAlert;
	n.timeZone = [NSTimeZone defaultTimeZone];
    n.alertBody = [NSString stringWithFormat:@"You have a %@ assessment due.  Take it now?",appName];
	n.alertAction = @"Do it";
	n.soundName = UILocalNotificationDefaultSoundName;
	n.applicationIconBadgeNumber = 1;
	n.repeatInterval = NSDayCalendarUnit;
    
	[[UIApplication sharedApplication] cancelAllLocalNotifications];
	[[UIApplication sharedApplication] scheduleLocalNotification:n];
    
	[n release];
}

+ (NSDate*)getLastTimeSeriesTime:(NSString*)series {
    //	[AssessNavigationController setupDemo];
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"TimeSeries"];
	NSManagedObjectContext *context = [iStressLessAppDelegate instance].udManagedObjectContext;
    [fetchRequest setFetchLimit:1];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"series == %@",series]];
    [fetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"time" ascending:FALSE]]];
    
	NSArray *a = [context executeFetchRequest:fetchRequest error:NULL];
	if (!a || !a.count) return nil;
	NSManagedObject *o = [a objectAtIndex:0];
    return (NSDate*)[o valueForKey:@"time"];
}

+ (NSManagedObject*)getLastTimeSeriesEntry:(NSString*)series {
    //	[AssessNavigationController setupDemo];
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"TimeSeries"];
	NSManagedObjectContext *context = [iStressLessAppDelegate instance].udManagedObjectContext;
    [fetchRequest setFetchLimit:1];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"series == %@",series]];
    [fetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"time" ascending:FALSE]]];

	NSArray *a = [context executeFetchRequest:fetchRequest error:NULL];
	if (!a || !a.count) return nil;
	return [a objectAtIndex:0];
}

+ (NSArray*)getTimeSeriesHistory:(NSString*)series withMaxCount:(int)count {
    //	[AssessNavigationController setupDemo];
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"TimeSeries"];
	NSManagedObjectContext *context = [iStressLessAppDelegate instance].udManagedObjectContext;
    if (count) [fetchRequest setFetchLimit:count];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"series == %@",series]];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"time" ascending:NO],nil]];
	NSArray *a = [context executeFetchRequest:fetchRequest error:NULL];
	
	NSMutableArray * copy = [NSMutableArray arrayWithCapacity:[a count]];
	for(int i = 0; i < [a count]; i++) {
		[copy addObject:[a objectAtIndex:[a count] - i - 1]];
	}	
	return copy;
}

- (void)questionnairePlayerHasFinished:(QPlayer*)player {
    
    QStringMap &answers = player->getAnswers();
    int totalScore = -1;
    int lastScore = -1;
//    if (takingWeekly) {
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
        
    NSManagedObject *lastScoreObj = [QuestionnaireContentController getLastTimeSeriesEntry:@"pclTotal"];
        lastScore = lastScoreObj ? [[lastScoreObj valueForKey:@"value"] intValue] : -1;
        NSDate *lastTime = lastScoreObj ? (NSDate*)[lastScoreObj valueForKey:@"time"] : nil;
        
        if (lastTime) {
            NSDate *now = [NSDate date];
            NSTimeInterval interval = [now timeIntervalSinceDate:lastTime];
            long long intervalInMillis = interval * 1000LL;
            [TimeElapsedBetweenPCLAssessmentsEvent logWithTimeElapsedBetweenPCLAssessments:intervalInMillis];
        }
        
        
        NSManagedObjectContext *context = [iStressLessAppDelegate instance].udManagedObjectContext;
        NSManagedObject *newPCL = [NSEntityDescription insertNewObjectForEntityForName:@"TimeSeries" inManagedObjectContext:context];
        [newPCL setValue:@"pclTotal" forKey:@"series"];
        [newPCL setValue:[NSDate date] forKey:@"time"];
        [newPCL setValue:[NSNumber numberWithInt:totalScore] forKey:@"value"];
        [context save:nil];
    
        [[iStressLessAppDelegate instance] setSetting:@"pclHistoryExists" to:@"true"];
    
        PclAssessmentEvent *pclEvent = [[PclAssessmentEvent alloc] init];
        pclEvent.pcl1 = nnatoi(answers.get("pcl1"));
        pclEvent.pcl2 = nnatoi(answers.get("pcl2"));
        pclEvent.pcl3 = nnatoi(answers.get("pcl3"));
        pclEvent.pcl4 = nnatoi(answers.get("pcl4"));
        pclEvent.pcl5 = nnatoi(answers.get("pcl5"));
        pclEvent.pcl6 = nnatoi(answers.get("pcl6"));
        pclEvent.pcl7 = nnatoi(answers.get("pcl7"));
        pclEvent.pcl8 = nnatoi(answers.get("pcl8"));
        pclEvent.pcl9 = nnatoi(answers.get("pcl9"));
        pclEvent.pcl10 = nnatoi(answers.get("pcl10"));
        pclEvent.pcl11 = nnatoi(answers.get("pcl11"));
        pclEvent.pcl12 = nnatoi(answers.get("pcl12"));
        pclEvent.pcl13 = nnatoi(answers.get("pcl13"));
        pclEvent.pcl14 = nnatoi(answers.get("pcl14"));
        pclEvent.pcl15 = nnatoi(answers.get("pcl15"));
        pclEvent.pcl16 = nnatoi(answers.get("pcl16"));
        pclEvent.pcl17 = nnatoi(answers.get("pcl17"));
        [[EventLog logger] log:pclEvent];
        [pclEvent release];
        
        [PclAssessmentCompletedEvent logWithPclAssessmentCompletedFinalScore:totalScore withPclAssessmentCompleted:1];
        
        [heartbeat
         logEvent:@"ASSESSMENT"
         withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"completed",@"yes",@"score",[NSString stringWithFormat:@"%d",totalScore],@"lastScore",[NSString stringWithFormat:@"%d",lastScore], nil]];
        
#ifdef EXPLORER_EMA
        Phq9SurveyEvent *phqEvent = [[Phq9SurveyEvent alloc] init];
        phqEvent.phq91 = nnatoi(answers.get("phq91"));
        phqEvent.phq92 = nnatoi(answers.get("phq92"));
        phqEvent.phq93 = nnatoi(answers.get("phq93"));
        phqEvent.phq94 = nnatoi(answers.get("phq94"));
        phqEvent.phq95 = nnatoi(answers.get("phq95"));
        phqEvent.phq96 = nnatoi(answers.get("phq96"));
        phqEvent.phq97 = nnatoi(answers.get("phq97"));
        phqEvent.phq98 = nnatoi(answers.get("phq98"));
        phqEvent.phq99 = nnatoi(answers.get("phq99"));
        [[EventLog logger] log:phqEvent];
        [phqEvent release];
        
        int howDifficult = nnatoi(answers.get("functioning"));
        [FunctioningAssessmentEvent logWithHowDifficult:howDifficult];
#endif
//    }
    
#ifdef EXPLORER_EMA
    if (takingDaily) {
        DailyAssessmentEvent *dailyEvent = [[DailyAssessmentEvent alloc] init];
        dailyEvent.overallMood = nnatoi(answers.get("overallMood"));
        dailyEvent.sleepWell = nnatoi(answers.get("sleepWell"));
        dailyEvent.howMuchAnger = nnatoi(answers.get("howMuchAnger"));
        dailyEvent.conflictWithOthers = nnatoi(answers.get("conflictWithOthers"));
        dailyEvent.needForCoping = nnatoi(answers.get("needForCoping"));
        dailyEvent.copingSituations = nnatonss(answers.get("copingSituations"));
        dailyEvent.overallCoping = nnatoi(answers.get("overallCoping"));
        dailyEvent.qualityOfGettingThingsDone = nnatoi(answers.get("qualityOfGettingThingsDone"));
        dailyEvent.copingToolsUsed = nnatonsna(answers.get("copingToolsUsed"));
        dailyEvent.copingSupport = nnatoi(answers.get("copingSupport"));
        dailyEvent.takePrescribedMedications = nnatoi(answers.get("takePrescribedMedications"));
        dailyEvent.medicationSideEffects = nnatoi(answers.get("medicationSideEffects"));
        dailyEvent.drinkAlcohol = nnatoi(answers.get("drinkAlcohol"));
        dailyEvent.howMuchAlcohol = nnatoi(answers.get("howMuchAlcohol"));
        dailyEvent.takeNonPrescribedDrug = nnatoi(answers.get("takeNonPrescribedDrug"));
        [[EventLog logger] log:dailyEvent];
        [dailyEvent release];
        
        NSDate *now = [NSDate date];
        NSString *lastDailyAssessmentTimeStr = [localDateFormatter stringFromDate:now];
        [[iStressLessAppDelegate instance] setSetting:@"lastDailyAssessmentTime" to:lastDailyAssessmentTimeStr];
    }
    
	ContentViewController *cvc = [[iStressLessAppDelegate instance] getContentControllerWithName:@"assessmentFinished"];
	cvc.masterController = self;
    [cvc addButton:BUTTON_RETURN_TO_ROOT withText:@"Done"];
	[(GNavigationController*)self.masterController pushViewControllerAndRemoveAllPrevious:cvc];
    
#else
    
//    if (takingWeekly) {
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
        cvc.masterController = self.masterController;
        
        NSString *currentPCLScheduling = [[iStressLessAppDelegate instance] getSetting:@"pclScheduled"];
        if (!currentPCLScheduling || [currentPCLScheduling isEqual:@""] || [currentPCLScheduling isEqual:@"none"]) {
            [cvc addButtonWithText:@"Next" callingBlock:^{
                ContentViewController *cvc = [[iStressLessAppDelegate instance] getContentControllerWithName:@"pclSchedulePrompt"];
                cvc.masterController = self.masterController;
                [cvc addButtonWithText:@"No, thanks" callingBlock:^{
                    [self navigateToContentName:@"trackHistory"];
                }];
                [cvc addButtonWithText:@"Schedule the reminder" callingBlock:^{
                    [QuestionnaireContentController scheduleAssessmentReminderFor: @"pclTotal" atInterval:@"month" andUserInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"pcl",@"destination", nil]];
                    [self setVariable:@"pclScheduledWhen" to:@"one month"];
                    ContentViewController *cvc = [[iStressLessAppDelegate instance] getContentControllerWithName:@"pclScheduled"];
                    cvc.masterController = self.masterController;
                    cvc.navigationItem.hidesBackButton = TRUE;
                    [cvc addButtonWithText:@"See Symptom History" callingBlock:^{
                        [self navigateToContentName:@"trackHistory"];
                    }];
                    [self navigateToNext:cvc from:self animated:TRUE andRemoveOld:TRUE];
                }];
                [self navigateToNext:cvc from:self animated:TRUE andRemoveOld:TRUE];
            }];
        } else {
            [QuestionnaireContentController scheduleAssessmentReminderFor: @"pclTotal" atInterval:currentPCLScheduling andUserInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"pcl",@"destination", nil]];
            [cvc addButtonWithText:@"See Symptom History" callingBlock:^{
                [self navigateToContentName:@"trackHistory"];
            }];
        }
        [self navigateToNext:cvc from:self animated:TRUE andRemoveOld:TRUE];
//    }
#endif
    
//    takingDaily = FALSE;
//    takingWeekly = FALSE;
    delete player;
}

- (void)questionnairePlayerWasCancelled:(QPlayer*)player {
//    takingDaily = FALSE;
//    takingWeekly = FALSE;
    
    [PclAssessmentAbortedEvent logWithPclAssessmentAbortedTimestamp:[EventLog timestamp]];
    [PclAssessmentCompletedEvent logWithPclAssessmentCompletedFinalScore:-1 withPclAssessmentCompleted:0];
    
    [heartbeat
     logEvent:@"ASSESSMENT"
     withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"completed",@"no",nil]];
    
	[self goBack];
    [self navigateToContentName:@"assess"];
	delete player;
}

static NSString *numbersToWords[] = {
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
//	BOOL tooSoonDaily = FALSE;
    
    NSDate *now = [NSDate date];
    
//    NSString *lastDailyAssessmentTimeStr = [[iStressLessAppDelegate instance] getSetting:@"lastDailyAssessmentTime"];
//    NSDate *lastDailyAssessmentTime = lastDailyAssessmentTimeStr ? [localDateFormatter dateFromString:lastDailyAssessmentTimeStr] : nil;
    
#ifdef EXPLORER_EMA
    if (![self dailyIsDue]) tooSoonDaily = TRUE;
    if (![self weeklyIsDue]) tooSoonWeekly = TRUE;
#endif
    
    NSString *pclSince = @"in the time since you last took this assessment";
	NSString *pclLastTime = @"just recently";
	NSManagedObject *lastScoreObj = [QuestionnaireContentController getLastTimeSeriesEntry:@"pclTotal"];
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
/*
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
*/ 
#else
	if (tooSoonWeekly && !force) {
		__block ContentViewController *tooSoonCVC = [[iStressLessAppDelegate instance] getContentControllerWithName:@"pclTooSoon"];
        __block QuestionnaireContentController *_self = self;
		[tooSoonCVC addButtonWithText:@"Remind me after a week" callingBlock:^{
            [QuestionnaireContentController scheduleAssessmentReminderFor:@"pclTotal" atInterval:@"week" andUserInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"pcl",@"destination", nil]];
            [tooSoonCVC setVariable:@"pclScheduledWhen" to:@"one week"];
            __block ContentViewController *scheduledCVC = [[iStressLessAppDelegate instance] getContentControllerWithName:@"pclScheduled"];
            scheduledCVC.navigationItem.hidesBackButton = TRUE;
            [scheduledCVC addButtonWithText:@"Ok" callingBlock:^{
                [_self goBack];
            }];
            [_self pushChild:scheduledCVC andRemoveOld:TRUE animated:TRUE];
        }];
		[tooSoonCVC addButtonWithText:@"Take it now" callingBlock:^{
            [_self takeAssessment:TRUE];
        }];
		[self pushChild:tooSoonCVC andRemoveOld:TRUE animated:FALSE];
		return;
	}
#endif
    
#ifdef EXPLORER_EMA
    if (!tooSoonWeekly) {
#endif
        [PclAssessmentStartedEvent logWithPclAssessmentStarted:[EventLog timestamp]];
        
        [heartbeat
         logEvent:@"ASSESSMENT"
         withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"timed",@"yes",nil]];
#ifdef EXPLORER_EMA
    }
#endif
    
	QPlayer *player = new QPlayer(self);
#ifdef EXPLORER_EMA
/*
    if (!tooSoonWeekly) {
        takingWeekly = TRUE;
        player->addQuestionnaire([[NSBundle mainBundle] pathForResource:@"pcl_no_intro" ofType:@"xml" inDirectory:@"Content"]);
        player->addQuestionnaire([[NSBundle mainBundle] pathForResource:@"phq9" ofType:@"xml" inDirectory:@"Content"]);
    }
    if (!tooSoonDaily) {
        takingDaily = TRUE;
        player->addQuestionnaire([[NSBundle mainBundle] pathForResource:@"daily" ofType:@"xml" inDirectory:@"Content"]);
    }
*/
 #else
//    takingWeekly = TRUE;
    
    NSString *fn = self.content.file;
    player->addQuestionnaire([[NSBundle mainBundle] pathForResource:[[fn componentsSeparatedByString:@"."] objectAtIndex:0] ofType:@"xml" inDirectory:@"Content"]);
#endif
	player->setDelegate(self);
	player->play();
}

- (BOOL) shouldUseFirstChildAsRoot {
    return FALSE;
}

-(void)configureFromContent {
    [super configureFromContent];
    [self takeAssessment:false];
}

- (void)dealloc {
    [super dealloc];
}


@end
