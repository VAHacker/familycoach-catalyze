//
//  EventRecord.m
//  iStressLess
//
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "EventRecord.h"
#import "JSONKit.h"
#import "ISO8601DateFormatter.h"

@implementation EventRecord

NSDateFormatter *dateFormatter;
NSDateFormatter *isoFormatter;

+ (void)initialize {
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    isoFormatter = [[NSDateFormatter alloc] init];
    [isoFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS"];
}

- (id)init
{
    self = [super init];
    if (self) {
        timestamp = [[NSDate date] timeIntervalSince1970] * 1000LL;
    }
    
    return self;
}

- (void)pack:(msgpack_packer*)pk {
    msgpack_pack_array(pk, 2);
    msgpack_pack_int(pk, eventID);
    msgpack_pack_long_long(pk, timestamp);
}

- (void)unpack:(msgpack_object_array*)array {
    eventID = array->ptr[0].via.i64;
    timestamp = array->ptr[1].via.u64;
}

- (NSString*)ohmageSurveyID {
    return nil;
}

- (void)addAttributesForOhmageJSON:(NSArray*)list {
}

- (void)writeOhmageJSON:(NSMutableData*)jsonData {
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *surveyLaunchContext = [[NSMutableDictionary alloc] init];
    
    CFUUIDRef uuid = CFUUIDCreate(NULL);
    NSString *uniqueID = (NSString*)CFUUIDCreateString(NULL,uuid);
    [(id)uuid release];
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:((double)timestamp/1000.0)];
    NSString *formattedDateString = [dateFormatter stringFromDate:date];
    NSTimeZone *tz = [NSTimeZone defaultTimeZone];

    [dict setObject:uniqueID forKey:@"survey_key"];
    [uniqueID release];

    NSNumber *nsnumberTimestamp = [NSNumber numberWithLongLong:timestamp];
    
    [dict setObject:formattedDateString forKey:@"date"];
    [dict setObject:nsnumberTimestamp forKey:@"time"];
    [dict setObject:[tz name] forKey:@"timezone"];
//    [dict setObject:@"America\/Los_Angeles" forKey:@"timezone"];
    [dict setObject:@"unavailable" forKey:@"location_status"];
    [surveyLaunchContext setObject:[NSArray array] forKey:@"active_triggers"];
    [surveyLaunchContext setObject:nsnumberTimestamp forKey:@"launch_time"];
    [surveyLaunchContext setObject:[tz name] forKey:@"launch_timezone"];
//    [surveyLaunchContext setObject:formattedDateString forKey:@"launch_time"];
    [dict setObject:surveyLaunchContext forKey:@"survey_launch_context"];
    [dict setObject:[self ohmageSurveyID] forKey:@"survey_id"];

    /*
     "survey_launch_context":{
     "launch_time":"2011-10-04 19:26:52",
     "active_triggers":[]},
*/
    NSMutableArray *a = [[NSMutableArray alloc] init];
    [self addAttributesForOhmageJSON:a];
    [dict setObject:a forKey:@"responses"];
    [a release];
    
    [jsonData appendData:[dict JSONDataWithOptions:JKSerializeOptionPretty error:NULL]];
    [dict release];
/*    
    "date":"2010-07-26 10:18:33",
    "time":1257272467077,
    "timezone":"PST",
    "location": {
        "latitude":38.8977,
        "longitude":-77.0366
    },
    "survey_id":"specificStressfulEvent",
    "responses: [
    {
    "prompt_id":"specificStressfulEventHoursAgo",
    "value":1
    },
    {
    "prompt_id":"specificStressfulEventWhatHappened",
    "value":"I sat on the 405 for an hour in practically stopped traffic."
        },
        {
        "prompt_id":"specificStressfulEventPhoto",
        "value":"e5bc0c9a-5773-4088-80ad-af7d0e3c14fb"
        }
        ] 
        }
*/
    
    
}

@end
