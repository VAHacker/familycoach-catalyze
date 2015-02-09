
#import "PclAssessmentCompletedEvent.h"

extern NSDateFormatter *isoFormatter;

@implementation PclAssessmentCompletedEvent

@synthesize pclAssessmentCompletedFinalScore,pclAssessmentCompleted;

- (id)init {
    self = [super init];
    if (self) {
    	eventID = 15;
    }
    
    return self;
}

+ (void)logWithPclAssessmentCompletedFinalScore:(long long)pclAssessmentCompletedFinalScore withPclAssessmentCompleted:(int)pclAssessmentCompleted {
	msgpack_packer *pk = [[EventLog logger] startEvent];
	if (!pk) return;
    msgpack_pack_array(pk, 4);
    msgpack_pack_int(pk, 15);
    msgpack_pack_long_long(pk, [[NSDate date] timeIntervalSince1970] * 1000LL);
    msgpack_pack_long_long(pk, pclAssessmentCompletedFinalScore);
    msgpack_pack_int(pk, pclAssessmentCompleted);
	[[EventLog logger] endEvent];
}

- (void)pack:(msgpack_packer*)pk {
    msgpack_pack_array(pk, 4);
    msgpack_pack_int(pk, eventID);
    msgpack_pack_long_long(pk, timestamp);
    msgpack_pack_long_long(pk, pclAssessmentCompletedFinalScore);
    msgpack_pack_int(pk, pclAssessmentCompleted);
}

- (void)unpack:(msgpack_object_array*)array {
	[super unpack:array];

    msgpack_object *obj;

    obj = &array->ptr[2];
	pclAssessmentCompletedFinalScore = obj->via.i64;
    obj = &array->ptr[3];
	pclAssessmentCompleted = obj->via.i64;
}

- (NSString*)ohmageSurveyID {
    return @"pclAssessmentCompletedProbe";
}

- (void)addAttributesForOhmageJSON:(NSMutableArray*)list {
	NSMutableDictionary *dict;

    dict = [[NSMutableDictionary alloc] init];
    [dict setObject:@"pclAssessmentCompletedFinalScore" forKey:@"prompt_id"];
	[dict setObject:(pclAssessmentCompletedFinalScore==-1 ? @"NOT_DISPLAYED" : [NSNumber numberWithLongLong:pclAssessmentCompletedFinalScore]) forKey:@"value"];
	[list addObject:dict];
	[dict release];
	
    dict = [[NSMutableDictionary alloc] init];
    [dict setObject:@"pclAssessmentCompleted" forKey:@"prompt_id"];
	[dict setObject:(pclAssessmentCompleted==-1 ? @"NOT_DISPLAYED" : [NSNumber numberWithInt:pclAssessmentCompleted]) forKey:@"value"];
	[list addObject:dict];
	[dict release];
	
}

- (void)dealloc {
	[super dealloc];
}

@end
