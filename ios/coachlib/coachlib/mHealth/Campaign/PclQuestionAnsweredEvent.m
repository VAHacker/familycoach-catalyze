
#import "PclQuestionAnsweredEvent.h"

extern NSDateFormatter *isoFormatter;

@implementation PclQuestionAnsweredEvent

@synthesize pclNumberOfQuestionsAnswered;

- (id)init {
    self = [super init];
    if (self) {
    	eventID = 5;
    }
    
    return self;
}

+ (void)logWithPclNumberOfQuestionsAnswered:(long long)pclNumberOfQuestionsAnswered {
	msgpack_packer *pk = [[EventLog logger] startEvent];
	if (!pk) return;
    msgpack_pack_array(pk, 3);
    msgpack_pack_int(pk, 5);
    msgpack_pack_long_long(pk, [[NSDate date] timeIntervalSince1970] * 1000LL);
    msgpack_pack_long_long(pk, pclNumberOfQuestionsAnswered);
	[[EventLog logger] endEvent];
}

- (void)pack:(msgpack_packer*)pk {
    msgpack_pack_array(pk, 3);
    msgpack_pack_int(pk, eventID);
    msgpack_pack_long_long(pk, timestamp);
    msgpack_pack_long_long(pk, pclNumberOfQuestionsAnswered);
}

- (void)unpack:(msgpack_object_array*)array {
	[super unpack:array];

    msgpack_object *obj;

    obj = &array->ptr[2];
	pclNumberOfQuestionsAnswered = obj->via.i64;
}

- (NSString*)ohmageSurveyID {
    return @"pclQuestionAnsweredProbe";
}

- (void)addAttributesForOhmageJSON:(NSMutableArray*)list {
	NSMutableDictionary *dict;

    dict = [[NSMutableDictionary alloc] init];
    [dict setObject:@"pclNumberOfQuestionsAnswered" forKey:@"prompt_id"];
	[dict setObject:(pclNumberOfQuestionsAnswered==-1 ? @"NOT_DISPLAYED" : [NSNumber numberWithLongLong:pclNumberOfQuestionsAnswered]) forKey:@"value"];
	[list addObject:dict];
	[dict release];
	
}

- (void)dealloc {
	[super dealloc];
}

@end
