
#import "PclAssessmentEvent.h"

extern NSDateFormatter *isoFormatter;

@implementation PclAssessmentEvent

@synthesize pcl1,pcl2,pcl3,pcl4,pcl5,pcl6,pcl7,pcl8,pcl9,pcl10,pcl11,pcl12,pcl13,pcl14,pcl15,pcl16,pcl17;

- (id)init {
    self = [super init];
    if (self) {
    	eventID = 2;
    }
    
    return self;
}

+ (void)logWithPcl1:(int)pcl1 withPcl2:(int)pcl2 withPcl3:(int)pcl3 withPcl4:(int)pcl4 withPcl5:(int)pcl5 withPcl6:(int)pcl6 withPcl7:(int)pcl7 withPcl8:(int)pcl8 withPcl9:(int)pcl9 withPcl10:(int)pcl10 withPcl11:(int)pcl11 withPcl12:(int)pcl12 withPcl13:(int)pcl13 withPcl14:(int)pcl14 withPcl15:(int)pcl15 withPcl16:(int)pcl16 withPcl17:(int)pcl17 {
	msgpack_packer *pk = [[EventLog logger] startEvent];
	if (!pk) return;
    msgpack_pack_array(pk, 19);
    msgpack_pack_int(pk, 2);
    msgpack_pack_long_long(pk, [[NSDate date] timeIntervalSince1970] * 1000LL);
    msgpack_pack_int(pk, pcl1);
    msgpack_pack_int(pk, pcl2);
    msgpack_pack_int(pk, pcl3);
    msgpack_pack_int(pk, pcl4);
    msgpack_pack_int(pk, pcl5);
    msgpack_pack_int(pk, pcl6);
    msgpack_pack_int(pk, pcl7);
    msgpack_pack_int(pk, pcl8);
    msgpack_pack_int(pk, pcl9);
    msgpack_pack_int(pk, pcl10);
    msgpack_pack_int(pk, pcl11);
    msgpack_pack_int(pk, pcl12);
    msgpack_pack_int(pk, pcl13);
    msgpack_pack_int(pk, pcl14);
    msgpack_pack_int(pk, pcl15);
    msgpack_pack_int(pk, pcl16);
    msgpack_pack_int(pk, pcl17);
	[[EventLog logger] endEvent];
}

- (void)pack:(msgpack_packer*)pk {
    msgpack_pack_array(pk, 19);
    msgpack_pack_int(pk, eventID);
    msgpack_pack_long_long(pk, timestamp);
    msgpack_pack_int(pk, pcl1);
    msgpack_pack_int(pk, pcl2);
    msgpack_pack_int(pk, pcl3);
    msgpack_pack_int(pk, pcl4);
    msgpack_pack_int(pk, pcl5);
    msgpack_pack_int(pk, pcl6);
    msgpack_pack_int(pk, pcl7);
    msgpack_pack_int(pk, pcl8);
    msgpack_pack_int(pk, pcl9);
    msgpack_pack_int(pk, pcl10);
    msgpack_pack_int(pk, pcl11);
    msgpack_pack_int(pk, pcl12);
    msgpack_pack_int(pk, pcl13);
    msgpack_pack_int(pk, pcl14);
    msgpack_pack_int(pk, pcl15);
    msgpack_pack_int(pk, pcl16);
    msgpack_pack_int(pk, pcl17);
}

- (void)unpack:(msgpack_object_array*)array {
	[super unpack:array];

    msgpack_object *obj;

    obj = &array->ptr[2];
	pcl1 = obj->via.i64;
    obj = &array->ptr[3];
	pcl2 = obj->via.i64;
    obj = &array->ptr[4];
	pcl3 = obj->via.i64;
    obj = &array->ptr[5];
	pcl4 = obj->via.i64;
    obj = &array->ptr[6];
	pcl5 = obj->via.i64;
    obj = &array->ptr[7];
	pcl6 = obj->via.i64;
    obj = &array->ptr[8];
	pcl7 = obj->via.i64;
    obj = &array->ptr[9];
	pcl8 = obj->via.i64;
    obj = &array->ptr[10];
	pcl9 = obj->via.i64;
    obj = &array->ptr[11];
	pcl10 = obj->via.i64;
    obj = &array->ptr[12];
	pcl11 = obj->via.i64;
    obj = &array->ptr[13];
	pcl12 = obj->via.i64;
    obj = &array->ptr[14];
	pcl13 = obj->via.i64;
    obj = &array->ptr[15];
	pcl14 = obj->via.i64;
    obj = &array->ptr[16];
	pcl15 = obj->via.i64;
    obj = &array->ptr[17];
	pcl16 = obj->via.i64;
    obj = &array->ptr[18];
	pcl17 = obj->via.i64;
}

- (NSString*)ohmageSurveyID {
    return @"pclAssessment";
}

- (void)addAttributesForOhmageJSON:(NSMutableArray*)list {
	NSMutableDictionary *dict;

    dict = [[NSMutableDictionary alloc] init];
    [dict setObject:@"pcl1" forKey:@"prompt_id"];
	[dict setObject:(pcl1==-1 ? @"NOT_DISPLAYED" : [NSNumber numberWithInt:pcl1]) forKey:@"value"];
	[list addObject:dict];
	[dict release];
	
    dict = [[NSMutableDictionary alloc] init];
    [dict setObject:@"pcl2" forKey:@"prompt_id"];
	[dict setObject:(pcl2==-1 ? @"NOT_DISPLAYED" : [NSNumber numberWithInt:pcl2]) forKey:@"value"];
	[list addObject:dict];
	[dict release];
	
    dict = [[NSMutableDictionary alloc] init];
    [dict setObject:@"pcl3" forKey:@"prompt_id"];
	[dict setObject:(pcl3==-1 ? @"NOT_DISPLAYED" : [NSNumber numberWithInt:pcl3]) forKey:@"value"];
	[list addObject:dict];
	[dict release];
	
    dict = [[NSMutableDictionary alloc] init];
    [dict setObject:@"pcl4" forKey:@"prompt_id"];
	[dict setObject:(pcl4==-1 ? @"NOT_DISPLAYED" : [NSNumber numberWithInt:pcl4]) forKey:@"value"];
	[list addObject:dict];
	[dict release];
	
    dict = [[NSMutableDictionary alloc] init];
    [dict setObject:@"pcl5" forKey:@"prompt_id"];
	[dict setObject:(pcl5==-1 ? @"NOT_DISPLAYED" : [NSNumber numberWithInt:pcl5]) forKey:@"value"];
	[list addObject:dict];
	[dict release];
	
    dict = [[NSMutableDictionary alloc] init];
    [dict setObject:@"pcl6" forKey:@"prompt_id"];
	[dict setObject:(pcl6==-1 ? @"NOT_DISPLAYED" : [NSNumber numberWithInt:pcl6]) forKey:@"value"];
	[list addObject:dict];
	[dict release];
	
    dict = [[NSMutableDictionary alloc] init];
    [dict setObject:@"pcl7" forKey:@"prompt_id"];
	[dict setObject:(pcl7==-1 ? @"NOT_DISPLAYED" : [NSNumber numberWithInt:pcl7]) forKey:@"value"];
	[list addObject:dict];
	[dict release];
	
    dict = [[NSMutableDictionary alloc] init];
    [dict setObject:@"pcl8" forKey:@"prompt_id"];
	[dict setObject:(pcl8==-1 ? @"NOT_DISPLAYED" : [NSNumber numberWithInt:pcl8]) forKey:@"value"];
	[list addObject:dict];
	[dict release];
	
    dict = [[NSMutableDictionary alloc] init];
    [dict setObject:@"pcl9" forKey:@"prompt_id"];
	[dict setObject:(pcl9==-1 ? @"NOT_DISPLAYED" : [NSNumber numberWithInt:pcl9]) forKey:@"value"];
	[list addObject:dict];
	[dict release];
	
    dict = [[NSMutableDictionary alloc] init];
    [dict setObject:@"pcl10" forKey:@"prompt_id"];
	[dict setObject:(pcl10==-1 ? @"NOT_DISPLAYED" : [NSNumber numberWithInt:pcl10]) forKey:@"value"];
	[list addObject:dict];
	[dict release];
	
    dict = [[NSMutableDictionary alloc] init];
    [dict setObject:@"pcl11" forKey:@"prompt_id"];
	[dict setObject:(pcl11==-1 ? @"NOT_DISPLAYED" : [NSNumber numberWithInt:pcl11]) forKey:@"value"];
	[list addObject:dict];
	[dict release];
	
    dict = [[NSMutableDictionary alloc] init];
    [dict setObject:@"pcl12" forKey:@"prompt_id"];
	[dict setObject:(pcl12==-1 ? @"NOT_DISPLAYED" : [NSNumber numberWithInt:pcl12]) forKey:@"value"];
	[list addObject:dict];
	[dict release];
	
    dict = [[NSMutableDictionary alloc] init];
    [dict setObject:@"pcl13" forKey:@"prompt_id"];
	[dict setObject:(pcl13==-1 ? @"NOT_DISPLAYED" : [NSNumber numberWithInt:pcl13]) forKey:@"value"];
	[list addObject:dict];
	[dict release];
	
    dict = [[NSMutableDictionary alloc] init];
    [dict setObject:@"pcl14" forKey:@"prompt_id"];
	[dict setObject:(pcl14==-1 ? @"NOT_DISPLAYED" : [NSNumber numberWithInt:pcl14]) forKey:@"value"];
	[list addObject:dict];
	[dict release];
	
    dict = [[NSMutableDictionary alloc] init];
    [dict setObject:@"pcl15" forKey:@"prompt_id"];
	[dict setObject:(pcl15==-1 ? @"NOT_DISPLAYED" : [NSNumber numberWithInt:pcl15]) forKey:@"value"];
	[list addObject:dict];
	[dict release];
	
    dict = [[NSMutableDictionary alloc] init];
    [dict setObject:@"pcl16" forKey:@"prompt_id"];
	[dict setObject:(pcl16==-1 ? @"NOT_DISPLAYED" : [NSNumber numberWithInt:pcl16]) forKey:@"value"];
	[list addObject:dict];
	[dict release];
	
    dict = [[NSMutableDictionary alloc] init];
    [dict setObject:@"pcl17" forKey:@"prompt_id"];
	[dict setObject:(pcl17==-1 ? @"NOT_DISPLAYED" : [NSNumber numberWithInt:pcl17]) forKey:@"value"];
	[list addObject:dict];
	[dict release];
	
}

- (void)dealloc {
	[super dealloc];
}

@end
