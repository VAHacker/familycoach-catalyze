
#import "TimePerScreenEvent.h"

extern NSDateFormatter *isoFormatter;

@implementation TimePerScreenEvent

@synthesize screenId,screenStartTime,timeSpentOnScreen;

- (id)init {
    self = [super init];
    if (self) {
    	eventID = 17;
    }
    
    return self;
}

+ (void)logWithScreenId:(NSString*)screenId withScreenStartTime:(long long)screenStartTime withTimeSpentOnScreen:(long long)timeSpentOnScreen {
	msgpack_packer *pk = [[EventLog logger] startEvent];
	if (!pk) return;
    msgpack_pack_array(pk, 5);
    msgpack_pack_int(pk, 17);
    msgpack_pack_long_long(pk, [[NSDate date] timeIntervalSince1970] * 1000LL);
    if (screenId) {
    	msgpack_pack_raw(pk, [screenId length]);
    	msgpack_pack_raw_body(pk, [screenId UTF8String], [screenId length]);
    } else {
    	msgpack_pack_nil(pk);
    }
    msgpack_pack_long_long(pk, screenStartTime);
    msgpack_pack_long_long(pk, timeSpentOnScreen);
	[[EventLog logger] endEvent];
}

- (void)pack:(msgpack_packer*)pk {
    msgpack_pack_array(pk, 5);
    msgpack_pack_int(pk, eventID);
    msgpack_pack_long_long(pk, timestamp);
    if (screenId) {
    	msgpack_pack_raw(pk, [screenId length]);
    	msgpack_pack_raw_body(pk, [screenId UTF8String], [screenId length]);
    } else {
    	msgpack_pack_nil(pk);
    }
    msgpack_pack_long_long(pk, screenStartTime);
    msgpack_pack_long_long(pk, timeSpentOnScreen);
}

- (void)unpack:(msgpack_object_array*)array {
	[super unpack:array];

    msgpack_object *obj;
    msgpack_object_raw *raw;

    obj = &array->ptr[2];
    if (obj->type == MSGPACK_OBJECT_NIL) {
    	self.screenId = nil;
    } else {
	    raw = &obj->via.raw;
		self.screenId = [NSString stringWithUTF8String:raw->ptr length:raw->size];
	}
    obj = &array->ptr[3];
	screenStartTime = obj->via.i64;
    obj = &array->ptr[4];
	timeSpentOnScreen = obj->via.i64;
}

- (NSString*)ohmageSurveyID {
    return @"timePerScreenProbe";
}

- (void)addAttributesForOhmageJSON:(NSMutableArray*)list {
	NSMutableDictionary *dict;
	NSDate *d;
	NSString *s;

    dict = [[NSMutableDictionary alloc] init];
    [dict setObject:@"screenId" forKey:@"prompt_id"];
	[dict setObject:(screenId ? screenId : @"NONE") forKey:@"value"];
	[list addObject:dict];
	[dict release];
	
    dict = [[NSMutableDictionary alloc] init];
    [dict setObject:@"screenStartTime" forKey:@"prompt_id"];
    d = [[NSDate alloc] initWithTimeIntervalSince1970:((double)screenStartTime/1000.0)];
    s = [isoFormatter stringFromDate:d];
	[dict setObject:s forKey:@"value"];
    [d release];
	[list addObject:dict];
	[dict release];
	
    dict = [[NSMutableDictionary alloc] init];
    [dict setObject:@"timeSpentOnScreen" forKey:@"prompt_id"];
	[dict setObject:(timeSpentOnScreen==-1 ? @"NOT_DISPLAYED" : [NSNumber numberWithLongLong:timeSpentOnScreen]) forKey:@"value"];
	[list addObject:dict];
	[dict release];
	
}

- (void)dealloc {
    [screenId release];
	[super dealloc];
}

@end
