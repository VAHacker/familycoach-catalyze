//
//  Goal.m
//  coachlib
//
//  Copyright (c) 2013 Department of Veteran's Affairs. All rights reserved.
//

#import "Goal.h"
#import "Goal.h"
#import "iStressLessAppDelegate.h"

@implementation Goal

@dynamic displayName;
@dynamic ordering;
@dynamic notes;
@dynamic level;
@dynamic expanded;
@dynamic parent;
@dynamic children;
@dynamic doneState;
@dynamic alarmID;
@dynamic dueDate;

-(NSString *)description {
    return self.displayName;
}

-(void)didSave {
    NSString *alarmName = [[self.objectID URIRepresentation] absoluteString];
    if (self.dueDate && self.alarmID) {
        UILocalNotification *n = [[UILocalNotification alloc] init];
        NSString *appName = [[iStressLessAppDelegate instance] getContentTextWithName:@"APP_NAME"];
        
        NSString *alarmAction=@"View Goals";
        NSString *alarmBody=@"You've reached the target date for a %@ goal.  Would you like to view your goals to update your progress?";
        
        n.fireDate = self.dueDate;
        n.timeZone = [NSTimeZone defaultTimeZone];
        n.alertBody = [NSString stringWithFormat:alarmBody,appName];
        n.alertAction = alarmAction;
        n.userInfo = @{
                       @"id" : alarmName,
                       @"destination" : self.alarmID ? self.alarmID : @"",
                       @"info" : alarmName
                       };
        
        [[iStressLessAppDelegate instance] rescheduleLocalNotification:n];
        [n release];
    } else {
        UILocalNotification *n = [[iStressLessAppDelegate instance] getLocalNotificationWithID:alarmName];
        if (n) [[UIApplication sharedApplication] cancelLocalNotification:n];
    }

}

@end
