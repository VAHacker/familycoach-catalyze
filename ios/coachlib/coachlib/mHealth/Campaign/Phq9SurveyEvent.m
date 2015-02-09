
#import "Phq9SurveyEvent.h"

extern NSDateFormatter *isoFormatter;

@implementation Phq9SurveyEvent

@synthesize phq91,phq92,phq93,phq94,phq95,phq96,phq97,phq98,phq99;

- (id)init {
    self = [super init];
    if (self) {
    	eventID = 3;
    }
    
    return self;
}

+ (void)logWithPhq91:(int)phq91 withPhq92:(int)phq92 withPhq93:(int)phq93 withPhq94:(int)phq94 withPhq95:(int)phq95 withPhq96:(int)phq96 withPhq97:(int)phq97 withPhq98:(int)phq98 withPhq99:(int)phq99 {
	msgpack_packer *pk = [[EventLog logger] startEvent];
	if (!pk) return;
    msgpack_pack_array(pk, 11);
    msgpack_pack_int(pk, 3);
    msgpack_pack_long_long(pk, [[NSDate date] timeIntervalSince1970] * 1000LL);
    msgpack_pack_int(pk, phq91);
    msgpack_pack_int(pk, phq92);
    msgpack_pack_int(pk, phq93);
    msgpack_pack_int(pk, phq94);
    msgpack_pack_int(pk, phq95);
    msgpack_pack_int(pk, phq96);
    msgpack_pack_int(pk, phq97);
    msgpack_pack_int(pk, phq98);
    msgpack_pack_int(pk, phq99);
	[[EventLog logger] endEvent];
}

- (void)pack:(msgpack_packer*)pk {
    msgpack_pack_array(pk, 11);
    msgpack_pack_int(pk, eventID);
    msgpack_pack_long_long(pk, timestamp);
    msgpack_pack_int(pk, phq91);
    msgpack_pack_int(pk, phq92);
    msgpack_pack_int(pk, phq93);
    msgpack_pack_int(pk, phq94);
    msgpack_pack_int(pk, phq95);
    msgpack_pack_int(pk, phq96);
    msgpack_pack_int(pk, phq97);
    msgpack_pack_int(pk, phq98);
    msgpack_pack_int(pk, phq99);
}

- (void)unpack:(msgpack_object_array*)array {
	[super unpack:array];

    msgpack_object *obj;

    obj = &array->ptr[2];
	phq91 = obj->via.i64;
    obj = &array->ptr[3];
	phq92 = obj->via.i64;
    obj = &array->ptr[4];
	phq93 = obj->via.i64;
    obj = &array->ptr[5];
	phq94 = obj->via.i64;
    obj = &array->ptr[6];
	phq95 = obj->via.i64;
    obj = &array->ptr[7];
	phq96 = obj->via.i64;
    obj = &array->ptr[8];
	phq97 = obj->via.i64;
    obj = &array->ptr[9];
	phq98 = obj->via.i64;
    obj = &array->ptr[10];
	phq99 = obj->via.i64;
}

- (NSString*)ohmageSurveyID {
    return @"phq9Survey";
}

- (void)addAttributesForOhmageJSON:(NSMutableArray*)list {
	NSMutableDictionary *dict;

    dict = [[NSMutableDictionary alloc] init];
    [dict setObject:@"phq91" forKey:@"prompt_id"];
	[dict setObject:(phq91==-1 ? @"NOT_DISPLAYED" : [NSNumber numberWithInt:phq91]) forKey:@"value"];
	[list addObject:dict];
	[dict release];
	
    dict = [[NSMutableDictionary alloc] init];
    [dict setObject:@"phq92" forKey:@"prompt_id"];
	[dict setObject:(phq92==-1 ? @"NOT_DISPLAYED" : [NSNumber numberWithInt:phq92]) forKey:@"value"];
	[list addObject:dict];
	[dict release];
	
    dict = [[NSMutableDictionary alloc] init];
    [dict setObject:@"phq93" forKey:@"prompt_id"];
	[dict setObject:(phq93==-1 ? @"NOT_DISPLAYED" : [NSNumber numberWithInt:phq93]) forKey:@"value"];
	[list addObject:dict];
	[dict release];
	
    dict = [[NSMutableDictionary alloc] init];
    [dict setObject:@"phq94" forKey:@"prompt_id"];
	[dict setObject:(phq94==-1 ? @"NOT_DISPLAYED" : [NSNumber numberWithInt:phq94]) forKey:@"value"];
	[list addObject:dict];
	[dict release];
	
    dict = [[NSMutableDictionary alloc] init];
    [dict setObject:@"phq95" forKey:@"prompt_id"];
	[dict setObject:(phq95==-1 ? @"NOT_DISPLAYED" : [NSNumber numberWithInt:phq95]) forKey:@"value"];
	[list addObject:dict];
	[dict release];
	
    dict = [[NSMutableDictionary alloc] init];
    [dict setObject:@"phq96" forKey:@"prompt_id"];
	[dict setObject:(phq96==-1 ? @"NOT_DISPLAYED" : [NSNumber numberWithInt:phq96]) forKey:@"value"];
	[list addObject:dict];
	[dict release];
	
    dict = [[NSMutableDictionary alloc] init];
    [dict setObject:@"phq97" forKey:@"prompt_id"];
	[dict setObject:(phq97==-1 ? @"NOT_DISPLAYED" : [NSNumber numberWithInt:phq97]) forKey:@"value"];
	[list addObject:dict];
	[dict release];
	
    dict = [[NSMutableDictionary alloc] init];
    [dict setObject:@"phq98" forKey:@"prompt_id"];
	[dict setObject:(phq98==-1 ? @"NOT_DISPLAYED" : [NSNumber numberWithInt:phq98]) forKey:@"value"];
	[list addObject:dict];
	[dict release];
	
    dict = [[NSMutableDictionary alloc] init];
    [dict setObject:@"phq99" forKey:@"prompt_id"];
	[dict setObject:(phq99==-1 ? @"NOT_DISPLAYED" : [NSNumber numberWithInt:phq99]) forKey:@"value"];
	[list addObject:dict];
	[dict release];
	
}

- (void)dealloc {
	[super dealloc];
}

@end
