
#import "PclAssessmentAbortedEvent.h"

extern NSDateFormatter *isoFormatter;

@implementation PclAssessmentAbortedEvent

@synthesize pclAssessmentAbortedTimestamp;

- (id)init {
    self = [super init];
    if (self) {
    	eventID = 14;
    }
    
    return self;
}

+ (void)logWithPclAssessmentAbortedTimestamp:(long long)pclAssessmentAbortedTimestamp {
	msgpack_packer *pk = [[EventLog logger] startEvent];
	if (!pk) return;
    msgpack_pack_array(pk, 3);
    msgpack_pack_int(pk, 14);
    msgpack_pack_long_long(pk, [[NSDate date] timeIntervalSince1970] * 1000LL);
    msgpack_pack_long_long(pk, pclAssessmentAbortedTimestamp);
	[[EventLog logger] endEvent];
}

- (void)pack:(msgpack_packer*)pk {
    msgpack_pack_array(pk, 3);
    msgpack_pack_int(pk, eventID);
    msgpack_pack_long_long(pk, timestamp);
    msgpack_pack_long_long(pk, pclAssessmentAbortedTimestamp);
}

- (void)unpack:(msgpack_object_array*)array {
	[super unpack:array];

    msgpack_object *obj;

    obj = &array->ptr[2];
	pclAssessmentAbortedTimestamp = obj->via.i64;
}

- (NSString*)ohmageSurveyID {
    return @"pclAssessmentAbortedProbe";
}

- (void)addAttributesForOhmageJSON:(NSMutableArray*)list {
	NSMutableDictionary *dict;
	NSDate *d;
	NSString *s;

    dict = [[NSMutableDictionary alloc] init];
    [dict setObject:@"pclAssessmentAbortedTimestamp" forKey:@"prompt_id"];
    d = [[NSDate alloc] initWithTimeIntervalSince1970:((double)pclAssessmentAbortedTimestamp/1000.0)];
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
