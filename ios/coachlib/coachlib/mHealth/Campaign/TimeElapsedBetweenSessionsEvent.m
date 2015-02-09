
#import "TimeElapsedBetweenSessionsEvent.h"

extern NSDateFormatter *isoFormatter;

@implementation TimeElapsedBetweenSessionsEvent

@synthesize timeElapsedBetweenSessions;

- (id)init {
    self = [super init];
    if (self) {
    	eventID = 18;
    }
    
    return self;
}

+ (void)logWithTimeElapsedBetweenSessions:(long long)timeElapsedBetweenSessions {
	msgpack_packer *pk = [[EventLog logger] startEvent];
	if (!pk) return;
    msgpack_pack_array(pk, 3);
    msgpack_pack_int(pk, 18);
    msgpack_pack_long_long(pk, [[NSDate date] timeIntervalSince1970] * 1000LL);
    msgpack_pack_long_long(pk, timeElapsedBetweenSessions);
	[[EventLog logger] endEvent];
}

- (void)pack:(msgpack_packer*)pk {
    msgpack_pack_array(pk, 3);
    msgpack_pack_int(pk, eventID);
    msgpack_pack_long_long(pk, timestamp);
    msgpack_pack_long_long(pk, timeElapsedBetweenSessions);
}

- (void)unpack:(msgpack_object_array*)array {
	[super unpack:array];

    msgpack_object *obj;

    obj = &array->ptr[2];
	timeElapsedBetweenSessions = obj->via.i64;
}

- (NSString*)ohmageSurveyID {
    return @"timeElapsedBetweenSessionsProbe";
}

- (void)addAttributesForOhmageJSON:(NSMutableArray*)list {
	NSMutableDictionary *dict;

    dict = [[NSMutableDictionary alloc] init];
    [dict setObject:@"timeElapsedBetweenSessions" forKey:@"prompt_id"];
	[dict setObject:(timeElapsedBetweenSessions==-1 ? @"NOT_DISPLAYED" : [NSNumber numberWithLongLong:timeElapsedBetweenSessions]) forKey:@"value"];
	[list addObject:dict];
	[dict release];
	
}

- (void)dealloc {
	[super dealloc];
}

@end
