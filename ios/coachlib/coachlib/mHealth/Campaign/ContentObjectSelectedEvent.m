
#import "ContentObjectSelectedEvent.h"

extern NSDateFormatter *isoFormatter;

@implementation ContentObjectSelectedEvent

@synthesize contentObjectName,contentObjectDisplayName,contentObjectId;

- (id)init {
    self = [super init];
    if (self) {
    	eventID = 8;
    }
    
    return self;
}

+ (void)logWithContentObjectName:(NSString*)contentObjectName withContentObjectDisplayName:(NSString*)contentObjectDisplayName withContentObjectId:(NSString*)contentObjectId {
	msgpack_packer *pk = [[EventLog logger] startEvent];
	if (!pk) return;
    msgpack_pack_array(pk, 5);
    msgpack_pack_int(pk, 8);
    msgpack_pack_long_long(pk, [[NSDate date] timeIntervalSince1970] * 1000LL);
    if (contentObjectName) {
    	msgpack_pack_raw(pk, [contentObjectName length]);
    	msgpack_pack_raw_body(pk, [contentObjectName UTF8String], [contentObjectName length]);
    } else {
    	msgpack_pack_nil(pk);
    }
    if (contentObjectDisplayName) {
    	msgpack_pack_raw(pk, [contentObjectDisplayName length]);
    	msgpack_pack_raw_body(pk, [contentObjectDisplayName UTF8String], [contentObjectDisplayName length]);
    } else {
    	msgpack_pack_nil(pk);
    }
    if (contentObjectId) {
    	msgpack_pack_raw(pk, [contentObjectId length]);
    	msgpack_pack_raw_body(pk, [contentObjectId UTF8String], [contentObjectId length]);
    } else {
    	msgpack_pack_nil(pk);
    }
	[[EventLog logger] endEvent];
}

- (void)pack:(msgpack_packer*)pk {
    msgpack_pack_array(pk, 5);
    msgpack_pack_int(pk, eventID);
    msgpack_pack_long_long(pk, timestamp);
    if (contentObjectName) {
    	msgpack_pack_raw(pk, [contentObjectName length]);
    	msgpack_pack_raw_body(pk, [contentObjectName UTF8String], [contentObjectName length]);
    } else {
    	msgpack_pack_nil(pk);
    }
    if (contentObjectDisplayName) {
    	msgpack_pack_raw(pk, [contentObjectDisplayName length]);
    	msgpack_pack_raw_body(pk, [contentObjectDisplayName UTF8String], [contentObjectDisplayName length]);
    } else {
    	msgpack_pack_nil(pk);
    }
    if (contentObjectId) {
    	msgpack_pack_raw(pk, [contentObjectId length]);
    	msgpack_pack_raw_body(pk, [contentObjectId UTF8String], [contentObjectId length]);
    } else {
    	msgpack_pack_nil(pk);
    }
}

- (void)unpack:(msgpack_object_array*)array {
	[super unpack:array];

    msgpack_object *obj;
    msgpack_object_raw *raw;

    obj = &array->ptr[2];
    if (obj->type == MSGPACK_OBJECT_NIL) {
    	self.contentObjectName = nil;
    } else {
	    raw = &obj->via.raw;
		self.contentObjectName = [NSString stringWithUTF8String:raw->ptr length:raw->size];
	}
    obj = &array->ptr[3];
    if (obj->type == MSGPACK_OBJECT_NIL) {
    	self.contentObjectDisplayName = nil;
    } else {
	    raw = &obj->via.raw;
		self.contentObjectDisplayName = [NSString stringWithUTF8String:raw->ptr length:raw->size];
	}
    obj = &array->ptr[4];
    if (obj->type == MSGPACK_OBJECT_NIL) {
    	self.contentObjectId = nil;
    } else {
	    raw = &obj->via.raw;
		self.contentObjectId = [NSString stringWithUTF8String:raw->ptr length:raw->size];
	}
}

- (NSString*)ohmageSurveyID {
    return @"contentObjectSelectedProbe";
}

- (void)addAttributesForOhmageJSON:(NSMutableArray*)list {
	NSMutableDictionary *dict;

    dict = [[NSMutableDictionary alloc] init];
    [dict setObject:@"contentObjectName" forKey:@"prompt_id"];
	[dict setObject:(contentObjectName ? contentObjectName : @"NONE") forKey:@"value"];
	[list addObject:dict];
	[dict release];
	
    dict = [[NSMutableDictionary alloc] init];
    [dict setObject:@"contentObjectDisplayName" forKey:@"prompt_id"];
	[dict setObject:(contentObjectDisplayName ? contentObjectDisplayName : @"NONE") forKey:@"value"];
	[list addObject:dict];
	[dict release];
	
    dict = [[NSMutableDictionary alloc] init];
    [dict setObject:@"contentObjectId" forKey:@"prompt_id"];
	[dict setObject:(contentObjectId ? contentObjectId : @"NONE") forKey:@"value"];
	[list addObject:dict];
	[dict release];
	
}

- (void)dealloc {
    [contentObjectName release];
    [contentObjectDisplayName release];
    [contentObjectId release];
	[super dealloc];
}

@end
