
#import "TotalTimeOnAppEvent.h"

extern NSDateFormatter *isoFormatter;

@implementation TotalTimeOnAppEvent

@synthesize totalTimeOnApp;

- (id)init {
    self = [super init];
    if (self) {
    	eventID = 16;
    }
    
    return self;
}

+ (void)logWithTotalTimeOnApp:(long long)totalTimeOnApp {
	msgpack_packer *pk = [[EventLog logger] startEvent];
	if (!pk) return;
    msgpack_pack_array(pk, 3);
    msgpack_pack_int(pk, 16);
    msgpack_pack_long_long(pk, [[NSDate date] timeIntervalSince1970] * 1000LL);
    msgpack_pack_long_long(pk, totalTimeOnApp);
	[[EventLog logger] endEvent];
}

- (void)pack:(msgpack_packer*)pk {
    msgpack_pack_array(pk, 3);
    msgpack_pack_int(pk, eventID);
    msgpack_pack_long_long(pk, timestamp);
    msgpack_pack_long_long(pk, totalTimeOnApp);
}

- (void)unpack:(msgpack_object_array*)array {
	[super unpack:array];

    msgpack_object *obj;

    obj = &array->ptr[2];
	totalTimeOnApp = obj->via.i64;
}

- (NSString*)ohmageSurveyID {
    return @"totalTimeOnAppProbe";
}

- (void)addAttributesForOhmageJSON:(NSMutableArray*)list {
	NSMutableDictionary *dict;

    dict = [[NSMutableDictionary alloc] init];
    [dict setObject:@"totalTimeOnApp" forKey:@"prompt_id"];
	[dict setObject:(totalTimeOnApp==-1 ? @"NOT_DISPLAYED" : [NSNumber numberWithLongLong:totalTimeOnApp]) forKey:@"value"];
	[list addObject:dict];
	[dict release];
	
}

- (void)dealloc {
	[super dealloc];
}

@end
