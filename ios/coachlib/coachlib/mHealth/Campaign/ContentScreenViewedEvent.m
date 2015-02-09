
#import "ContentScreenViewedEvent.h"

extern NSDateFormatter *isoFormatter;

@implementation ContentScreenViewedEvent

@synthesize contentScreenTimestampStart,contentScreenTimestampDismissal,contentScreenName,contentScreenDisplayName,contentScreenType,contentScreenId;

- (id)init {
    self = [super init];
    if (self) {
    	eventID = 7;
    }
    
    return self;
}

+ (void)logWithContentScreenTimestampStart:(long long)contentScreenTimestampStart withContentScreenTimestampDismissal:(long long)contentScreenTimestampDismissal withContentScreenName:(NSString*)contentScreenName withContentScreenDisplayName:(NSString*)contentScreenDisplayName withContentScreenType:(int)contentScreenType withContentScreenId:(NSString*)contentScreenId {
	msgpack_packer *pk = [[EventLog logger] startEvent];
	if (!pk) return;
    msgpack_pack_array(pk, 8);
    msgpack_pack_int(pk, 7);
    msgpack_pack_long_long(pk, [[NSDate date] timeIntervalSince1970] * 1000LL);
    msgpack_pack_long_long(pk, contentScreenTimestampStart);
    msgpack_pack_long_long(pk, contentScreenTimestampDismissal);
    if (contentScreenName) {
    	msgpack_pack_raw(pk, [contentScreenName length]);
    	msgpack_pack_raw_body(pk, [contentScreenName UTF8String], [contentScreenName length]);
    } else {
    	msgpack_pack_nil(pk);
    }
    if (contentScreenDisplayName) {
    	msgpack_pack_raw(pk, [contentScreenDisplayName length]);
    	msgpack_pack_raw_body(pk, [contentScreenDisplayName UTF8String], [contentScreenDisplayName length]);
    } else {
    	msgpack_pack_nil(pk);
    }
    msgpack_pack_int(pk, contentScreenType);
    if (contentScreenId) {
    	msgpack_pack_raw(pk, [contentScreenId length]);
    	msgpack_pack_raw_body(pk, [contentScreenId UTF8String], [contentScreenId length]);
    } else {
    	msgpack_pack_nil(pk);
    }
	[[EventLog logger] endEvent];
}

- (void)pack:(msgpack_packer*)pk {
    msgpack_pack_array(pk, 8);
    msgpack_pack_int(pk, eventID);
    msgpack_pack_long_long(pk, timestamp);
    msgpack_pack_long_long(pk, contentScreenTimestampStart);
    msgpack_pack_long_long(pk, contentScreenTimestampDismissal);
    if (contentScreenName) {
    	msgpack_pack_raw(pk, [contentScreenName length]);
    	msgpack_pack_raw_body(pk, [contentScreenName UTF8String], [contentScreenName length]);
    } else {
    	msgpack_pack_nil(pk);
    }
    if (contentScreenDisplayName) {
    	msgpack_pack_raw(pk, [contentScreenDisplayName length]);
    	msgpack_pack_raw_body(pk, [contentScreenDisplayName UTF8String], [contentScreenDisplayName length]);
    } else {
    	msgpack_pack_nil(pk);
    }
    msgpack_pack_int(pk, contentScreenType);
    if (contentScreenId) {
    	msgpack_pack_raw(pk, [contentScreenId length]);
    	msgpack_pack_raw_body(pk, [contentScreenId UTF8String], [contentScreenId length]);
    } else {
    	msgpack_pack_nil(pk);
    }
}

- (void)unpack:(msgpack_object_array*)array {
	[super unpack:array];

    msgpack_object *obj;
    msgpack_object_raw *raw;

    obj = &array->ptr[2];
	contentScreenTimestampStart = obj->via.i64;
    obj = &array->ptr[3];
	contentScreenTimestampDismissal = obj->via.i64;
    obj = &array->ptr[4];
    if (obj->type == MSGPACK_OBJECT_NIL) {
    	self.contentScreenName = nil;
    } else {
	    raw = &obj->via.raw;
		self.contentScreenName = [NSString stringWithUTF8String:raw->ptr length:raw->size];
	}
    obj = &array->ptr[5];
    if (obj->type == MSGPACK_OBJECT_NIL) {
    	self.contentScreenDisplayName = nil;
    } else {
	    raw = &obj->via.raw;
		self.contentScreenDisplayName = [NSString stringWithUTF8String:raw->ptr length:raw->size];
	}
    obj = &array->ptr[6];
	contentScreenType = obj->via.i64;
    obj = &array->ptr[7];
    if (obj->type == MSGPACK_OBJECT_NIL) {
    	self.contentScreenId = nil;
    } else {
	    raw = &obj->via.raw;
		self.contentScreenId = [NSString stringWithUTF8String:raw->ptr length:raw->size];
	}
}

- (NSString*)ohmageSurveyID {
    return @"contentScreenViewedProbe";
}

- (void)addAttributesForOhmageJSON:(NSMutableArray*)list {
	NSMutableDictionary *dict;
	NSDate *d;
	NSString *s;

    dict = [[NSMutableDictionary alloc] init];
    [dict setObject:@"contentScreenTimestampStart" forKey:@"prompt_id"];
    d = [[NSDate alloc] initWithTimeIntervalSince1970:((double)contentScreenTimestampStart/1000.0)];
    s = [isoFormatter stringFromDate:d];
	[dict setObject:s forKey:@"value"];
    [d release];
	[list addObject:dict];
	[dict release];
	
    dict = [[NSMutableDictionary alloc] init];
    [dict setObject:@"contentScreenTimestampDismissal" forKey:@"prompt_id"];
    d = [[NSDate alloc] initWithTimeIntervalSince1970:((double)contentScreenTimestampDismissal/1000.0)];
    s = [isoFormatter stringFromDate:d];
	[dict setObject:s forKey:@"value"];
    [d release];
	[list addObject:dict];
	[dict release];
	
    dict = [[NSMutableDictionary alloc] init];
    [dict setObject:@"contentScreenName" forKey:@"prompt_id"];
	[dict setObject:(contentScreenName ? contentScreenName : @"NONE") forKey:@"value"];
	[list addObject:dict];
	[dict release];
	
    dict = [[NSMutableDictionary alloc] init];
    [dict setObject:@"contentScreenDisplayName" forKey:@"prompt_id"];
	[dict setObject:(contentScreenDisplayName ? contentScreenDisplayName : @"NONE") forKey:@"value"];
	[list addObject:dict];
	[dict release];
	
    dict = [[NSMutableDictionary alloc] init];
    [dict setObject:@"contentScreenType" forKey:@"prompt_id"];
	[dict setObject:(contentScreenType==-1 ? @"NOT_DISPLAYED" : [NSNumber numberWithInt:contentScreenType]) forKey:@"value"];
	[list addObject:dict];
	[dict release];
	
    dict = [[NSMutableDictionary alloc] init];
    [dict setObject:@"contentScreenId" forKey:@"prompt_id"];
	[dict setObject:(contentScreenId ? contentScreenId : @"NONE") forKey:@"value"];
	[list addObject:dict];
	[dict release];
	
}

- (void)dealloc {
    [contentScreenName release];
    [contentScreenDisplayName release];
    [contentScreenId release];
	[super dealloc];
}

@end
