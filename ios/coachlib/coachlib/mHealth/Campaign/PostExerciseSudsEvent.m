
#import "PostExerciseSudsEvent.h"

extern NSDateFormatter *isoFormatter;

@implementation PostExerciseSudsEvent

@synthesize initialSudsScore,postExerciseSudsScore;

- (id)init {
    self = [super init];
    if (self) {
    	eventID = 10;
    }
    
    return self;
}

+ (void)logWithInitialSudsScore:(long long)initialSudsScore withPostExerciseSudsScore:(long long)postExerciseSudsScore {
	msgpack_packer *pk = [[EventLog logger] startEvent];
	if (!pk) return;
    msgpack_pack_array(pk, 4);
    msgpack_pack_int(pk, 10);
    msgpack_pack_long_long(pk, [[NSDate date] timeIntervalSince1970] * 1000LL);
    msgpack_pack_long_long(pk, initialSudsScore);
    msgpack_pack_long_long(pk, postExerciseSudsScore);
	[[EventLog logger] endEvent];
}

- (void)pack:(msgpack_packer*)pk {
    msgpack_pack_array(pk, 4);
    msgpack_pack_int(pk, eventID);
    msgpack_pack_long_long(pk, timestamp);
    msgpack_pack_long_long(pk, initialSudsScore);
    msgpack_pack_long_long(pk, postExerciseSudsScore);
}

- (void)unpack:(msgpack_object_array*)array {
	[super unpack:array];

    msgpack_object *obj;

    obj = &array->ptr[2];
	initialSudsScore = obj->via.i64;
    obj = &array->ptr[3];
	postExerciseSudsScore = obj->via.i64;
}

- (NSString*)ohmageSurveyID {
    return @"postExerciseSudsProbe";
}

- (void)addAttributesForOhmageJSON:(NSMutableArray*)list {
	NSMutableDictionary *dict;

    dict = [[NSMutableDictionary alloc] init];
    [dict setObject:@"initialSudsScore" forKey:@"prompt_id"];
	[dict setObject:(initialSudsScore==-1 ? @"NOT_DISPLAYED" : [NSNumber numberWithLongLong:initialSudsScore]) forKey:@"value"];
	[list addObject:dict];
	[dict release];
	
    dict = [[NSMutableDictionary alloc] init];
    [dict setObject:@"postExerciseSudsScore" forKey:@"prompt_id"];
	[dict setObject:(postExerciseSudsScore==-1 ? @"NOT_DISPLAYED" : [NSNumber numberWithLongLong:postExerciseSudsScore]) forKey:@"value"];
	[list addObject:dict];
	[dict release];
	
}

- (void)dealloc {
	[super dealloc];
}

@end
