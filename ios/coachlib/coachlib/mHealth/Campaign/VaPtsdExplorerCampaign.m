
#import "VaPtsdExplorerCampaign.h"

@implementation VaPtsdExplorerCampaign

static NSDictionary *eventMappings;

+(void) initialize {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:[DailyAssessmentEvent class] forKey:[NSNumber numberWithInt:0]];
    [dict setObject:[FunctioningAssessmentEvent class] forKey:[NSNumber numberWithInt:1]];
    [dict setObject:[PclAssessmentEvent class] forKey:[NSNumber numberWithInt:2]];
    [dict setObject:[Phq9SurveyEvent class] forKey:[NSNumber numberWithInt:3]];
    [dict setObject:[PclAssessmentStartedEvent class] forKey:[NSNumber numberWithInt:4]];
    [dict setObject:[PclQuestionAnsweredEvent class] forKey:[NSNumber numberWithInt:5]];
    [dict setObject:[ButtonPressedEvent class] forKey:[NSNumber numberWithInt:6]];
    [dict setObject:[ContentScreenViewedEvent class] forKey:[NSNumber numberWithInt:7]];
    [dict setObject:[ContentObjectSelectedEvent class] forKey:[NSNumber numberWithInt:8]];
    [dict setObject:[PreExerciseSudsEvent class] forKey:[NSNumber numberWithInt:9]];
    [dict setObject:[PostExerciseSudsEvent class] forKey:[NSNumber numberWithInt:10]];
    [dict setObject:[AppLaunchedEvent class] forKey:[NSNumber numberWithInt:11]];
    [dict setObject:[AppExitedEvent class] forKey:[NSNumber numberWithInt:12]];
    [dict setObject:[PclReminderScheduledEvent class] forKey:[NSNumber numberWithInt:13]];
    [dict setObject:[PclAssessmentAbortedEvent class] forKey:[NSNumber numberWithInt:14]];
    [dict setObject:[PclAssessmentCompletedEvent class] forKey:[NSNumber numberWithInt:15]];
    [dict setObject:[TotalTimeOnAppEvent class] forKey:[NSNumber numberWithInt:16]];
    [dict setObject:[TimePerScreenEvent class] forKey:[NSNumber numberWithInt:17]];
    [dict setObject:[TimeElapsedBetweenSessionsEvent class] forKey:[NSNumber numberWithInt:18]];
    [dict setObject:[TimeElapsedBetweenPCLAssessmentsEvent class] forKey:[NSNumber numberWithInt:19]];
    [dict setObject:[ToolAbortedEvent class] forKey:[NSNumber numberWithInt:20]];
    eventMappings = dict;
    [eventMappings retain];
}

- (id)init
{
    self = [super init];
    if (self) {
        self.eventIDToEventRecordClasses = eventMappings;
    }
    
    return self;
}

- (NSString*)urn {
    return @"urn:campaign:va:ptsd_explorer";
}

@end
