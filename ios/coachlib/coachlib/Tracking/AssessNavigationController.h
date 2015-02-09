//
//  AssessNavigationController.h
//  iStressLess
//


//

#import <Foundation/Foundation.h>
#import "GNavigationController.h"
#import "ButtonGridController.h"
#import "heartbeat.h"

@interface AssessNavigationController : GNavigationController {
	ButtonGridController *assessRoot;
    BOOL takingDaily;
    BOOL takingWeekly;
}

+(void) schedulePCLReminderAtInterval:(NSString*)interval;
+(void) scheduleDailyAndWeeklyRemindersAtTimeOfDay:(NSDate*)timeOfDay onDayOfWeek:(int)dayOfWeek;

@end
