//
//  FavoritesListViewController.m
//  iStressLess
//


//

#import "AlarmController.h"
#import "iStressLessAppDelegate.h"
#import "ExerciseRef.h"
#import "GTableView.h"

@implementation AlarmController

-(void)configureFromContent {
    self.scoping = TRUE;
    self.alarmName = [self.content getExtraString:@"alarmName"];
    self.alarmDestination = [self.content getExtraString:@"alarmDestination"];
    self.alarmAction = [self.content getExtraString:@"alarmAction"];
    self.alarmBody = [self.content getExtraString:@"alarmBody"];
    
    UILocalNotification *n = [[iStressLessAppDelegate instance] getLocalNotificationWithID:self.alarmName];
    if (n) {
        [self setVariable:@"dailyAlarmOn" to:@true];
        [self setVariable:@"alarmTime" to:n.fireDate];
    } else {
        [self setVariable:@"dailyAlarmOn" to:@false];
    }
    
    [super configureFromContent];
}

- (void) clearVariable:(NSString*)key {
    [super clearVariable:key];
}

- (void) clearVariables {
    [super clearVariables];
}

- (void) updateAlarm {
    NSNumber *alarmOn = (NSNumber*)[self getVariable:@"dailyAlarmOn"];
    NSDate *timeOfDay = (NSDate*)[self getVariable:@"alarmTime"];
    if (timeOfDay && [alarmOn boolValue]) {
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
        n.alertBody = [NSString stringWithFormat:self.alarmBody,appName];
        n.alertAction = self.alarmAction;
        n.repeatInterval = NSDayCalendarUnit;
        n.userInfo = @{
            @"id" : self.alarmName,
            @"destination" : self.alarmDestination,
            @"type" : @"daily"
        };

        [[iStressLessAppDelegate instance] rescheduleLocalNotification:n];
        [n release];
    } else {
        UILocalNotification *n = [[iStressLessAppDelegate instance] getLocalNotificationWithID:self.alarmName];
        if (n) [[UIApplication sharedApplication] cancelLocalNotification:n];
    }
}

- (void) setVariable:(NSString*)key to:(NSObject*)value {
    [super setVariable:key to:value];
    [self updateAlarm];
}

@end
