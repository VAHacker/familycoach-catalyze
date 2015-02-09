
#import "PclAssessmentStartedEvent.h"

extern NSDateFormatter *isoFormatter;

@implementation PclAssessmentStartedEvent

@synthesize pclAssessmentStarted;

- (id)init {
    self = [super init];
    if (self) {
    	eventID = 4;
    }
    
    return self;
}

+ (void)logWithPclAssessmentStarted:(long long)pclAssessmentStarted {
	msgpack_packer *pk = [[EventLog logger] startEvent];
	if (!pk) return;
    msgpack_pack_array(pk, 3);
    msgpack_pack_int(pk, 4);
    msgpack_pack_long_long(pk, [[NSDate date] timeIntervalSince1970] * 1000LL);
    msgpack_pack_long_long(pk, pclAssessmentStarted);
	[[EventLog logger] endEvent];
}

- (void)pack:(msgpack_packer*)pk {
    msgpack_pack_array(pk, 3);
    msgpack_pack_int(pk, eventID);
    msgpack_pack_long_long(pk, timestamp);
    msgpack_pack_long_long(pk, pclAssessmentStarted);
}

- (void)unpack:(msgpack_object_array*)array {
	[super unpack:array];

    msgpack_object *obj;

    obj = &array->ptr[2];
	pclAssessmentStarted = obj->via.i64;
}

- (NSString*)ohmageSurveyID {
    return @"pclAssessmentStartedProbe";
}

- (void)addAttributesForOhmageJSON:(NSMutableArray*)list {
	NSMutableDictionary *dict;
	NSDate *d;
	NSString *s;

    dict = [[NSMutableDictionary alloc] init];
    [dict setObject:@"pclAssessmentStarted" forKey:@"prompt_id"];
    d = [[NSDate alloc] initWithTimeIntervalSince1970:((double)pclAssessmentStarted/1000.0)];
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
