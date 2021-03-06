
#import "FunctioningAssessmentEvent.h"

extern NSDateFormatter *isoFormatter;

@implementation FunctioningAssessmentEvent

@synthesize howDifficult;

- (id)init {
    self = [super init];
    if (self) {
    	eventID = 1;
    }
    
    return self;
}

+ (void)logWithHowDifficult:(int)howDifficult {
	msgpack_packer *pk = [[EventLog logger] startEvent];
	if (!pk) return;
    msgpack_pack_array(pk, 3);
    msgpack_pack_int(pk, 1);
    msgpack_pack_long_long(pk, [[NSDate date] timeIntervalSince1970] * 1000LL);
    msgpack_pack_int(pk, howDifficult);
	[[EventLog logger] endEvent];
}

- (void)pack:(msgpack_packer*)pk {
    msgpack_pack_array(pk, 3);
    msgpack_pack_int(pk, eventID);
    msgpack_pack_long_long(pk, timestamp);
    msgpack_pack_int(pk, howDifficult);
}

- (void)unpack:(msgpack_object_array*)array {
	[super unpack:array];

    msgpack_object *obj;

    obj = &array->ptr[2];
	howDifficult = obj->via.i64;
}

- (NSString*)ohmageSurveyID {
    return @"functioningAssessment";
}

- (void)addAttributesForOhmageJSON:(NSMutableArray*)list {
	NSMutableDictionary *dict;

    dict = [[NSMutableDictionary alloc] init];
    [dict setObject:@"howDifficult" forKey:@"prompt_id"];
	[dict setObject:(howDifficult==-1 ? @"NOT_DISPLAYED" : [NSNumber numberWithInt:howDifficult]) forKey:@"value"];
	[list addObject:dict];
	[dict release];
	
}

- (void)dealloc {
	[super dealloc];
}

@end
