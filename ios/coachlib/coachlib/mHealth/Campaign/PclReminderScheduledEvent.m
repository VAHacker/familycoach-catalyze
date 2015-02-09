
#import "PclReminderScheduledEvent.h"

extern NSDateFormatter *isoFormatter;

@implementation PclReminderScheduledEvent

@synthesize pclReminderScheduledTimestamp;

- (id)init {
    self = [super init];
    if (self) {
    	eventID = 13;
    }
    
    return self;
}

+ (void)logWithPclReminderScheduledTimestamp:(long long)pclReminderScheduledTimestamp {
	msgpack_packer *pk = [[EventLog logger] startEvent];
	if (!pk) return;
    msgpack_pack_array(pk, 3);
    msgpack_pack_int(pk, 13);
    msgpack_pack_long_long(pk, [[NSDate date] timeIntervalSince1970] * 1000LL);
    msgpack_pack_long_long(pk, pclReminderScheduledTimestamp);
	[[EventLog logger] endEvent];
}

- (void)pack:(msgpack_packer*)pk {
    msgpack_pack_array(pk, 3);
    msgpack_pack_int(pk, eventID);
    msgpack_pack_long_long(pk, timestamp);
    msgpack_pack_long_long(pk, pclReminderScheduledTimestamp);
}

- (void)unpack:(msgpack_object_array*)array {
	[super unpack:array];

    msgpack_object *obj;

    obj = &array->ptr[2];
	pclReminderScheduledTimestamp = obj->via.i64;
}

- (NSString*)ohmageSurveyID {
    return @"pclReminderScheduledProbe";
}

- (void)addAttributesForOhmageJSON:(NSMutableArray*)list {
	NSMutableDictionary *dict;
	NSDate *d;
	NSString *s;

    dict = [[NSMutableDictionary alloc] init];
    [dict setObject:@"pclReminderScheduledTimestamp" forKey:@"prompt_id"];
    d = [[NSDate alloc] initWithTimeIntervalSince1970:((double)pclReminderScheduledTimestamp/1000.0)];
    s = [isoFormatter stringFromDate:d];
	[dict setObject:s forKey:@"value"];
    [d release];
	[list addObject:dict];
	[dict release];
	
}

- (void)dealloc {
	[super dealloc];
}

@end
