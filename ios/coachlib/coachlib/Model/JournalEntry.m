//
//  JournalEntry.m
//  coachlib
//
//  Copyright (c) 2013 Department of Veteran's Affairs. All rights reserved.
//

#import "JournalEntry.h"
#import "CopingTechnique.h"
#import "SymptomRef.h"
#import "SymptomTrigger.h"


@implementation JournalEntry

@dynamic when;
@dynamic displayName;
@dynamic duration;
@dynamic severity;
@dynamic sleepDuration;
@dynamic bedDuration;
@dynamic experience;
@dynamic consequences;
@dynamic notes;
@dynamic symptom;
@dynamic triggers;
@dynamic copingTechniques;

-(NSString *)subLabel {
    if (self.sleepDuration && self.bedDuration) {
        float sleepDuration = [self.sleepDuration floatValue];
        float bedDuration = [self.bedDuration floatValue];
        if (!isnan(sleepDuration) && (bedDuration > 0)) {
            float sleepEfficiency = (sleepDuration / bedDuration);
            return [NSString stringWithFormat:@"Sleep efficiency: %d%%",(int)(sleepEfficiency*100)];
        }
    }
    if (self.severity) return [NSString stringWithFormat:@"Severity: %d",[self.severity intValue]];
    return nil;
}

-(NSString *)detailLabel {
    NSDate *date = self.when;
    if (!date) return nil;
    
    NSString *dateStr = nil;
    NSCalendar *cal = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
    NSDateComponents *thenComponents = [cal components:NSDayCalendarUnit fromDate:date];
    NSDateComponents *nowComponents = [cal components:NSDayCalendarUnit fromDate:[NSDate date]];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    if ([thenComponents day] != [nowComponents day]) {
        [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
        [dateFormatter setDateStyle:NSDateFormatterShortStyle];
        dateStr = [dateFormatter stringFromDate:date];
    } else {
        [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
        [dateFormatter setDateStyle:NSDateFormatterNoStyle];
        dateStr = [dateFormatter stringFromDate:date];
    }
    [dateFormatter release];
    
    return dateStr;
}

@end
