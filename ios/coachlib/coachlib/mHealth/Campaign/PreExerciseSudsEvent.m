
#import "PreExerciseSudsEvent.h"

extern NSDateFormatter *isoFormatter;

@implementation PreExerciseSudsEvent

@synthesize preExerciseSudsScore;

- (id)init {
    self = [super init];
    if (self) {
    	eventID = 9;
    }
    
    return self;
}

+ (void)logWithPreExerciseSudsScore:(long long)preExerciseSudsScore {
	msgpack_packer *pk = [[EventLog logger] startEvent];
	if (!pk) return;
    msgpack_pack_array(pk, 3);
    msgpack_pack_int(pk, 9);
    msgpack_pack_long_long(pk, [[NSDate date] timeIntervalSince1970] * 1000LL);
    msgpack_pack_long_long(pk, preExerciseSudsScore);
	[[EventLog logger] endEvent];
}

- (void)pack:(msgpack_packer*)pk {
    msgpack_pack_array(pk, 3);
    msgpack_pack_int(pk, eventID);
    msgpack_pack_long_long(pk, timestamp);
    msgpack_pack_long_long(pk, preExerciseSudsScore);
}

- (void)unpack:(msgpack_object_array*)array {
	[super unpack:array];

    msgpack_object *obj;

    obj = &array->ptr[2];
	preExerciseSudsScore = obj->via.i64;
}

- (NSString*)ohmageSurveyID {
    return @"preExerciseSudsProbe";
}

- (void)addAttributesForOhmageJSON:(NSMutableArray*)list {
	NSMutableDictionary *dict;

    dict = [[NSMutableDictionary alloc] init];
    [dict setObject:@"preExerciseSudsScore" forKey:@"prompt_id"];
	[dict setObject:(preExerciseSudsScore==-1 ? @"NOT_DISPLAYED" : [NSNumber numberWithLongLong:preExerciseSudsScore]) forKey:@"value"];
	[list addObject:dict];
	[dict release];
	
}

- (void)dealloc {
	[super dealloc];
}

@end
