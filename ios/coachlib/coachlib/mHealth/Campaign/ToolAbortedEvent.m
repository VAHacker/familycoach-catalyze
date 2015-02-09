
#import "ToolAbortedEvent.h"

extern NSDateFormatter *isoFormatter;

@implementation ToolAbortedEvent

@synthesize toolId,toolName;

- (id)init {
    self = [super init];
    if (self) {
    	eventID = 20;
    }
    
    return self;
}

+ (void)logWithToolId:(NSString*)toolId withToolName:(NSString*)toolName {
	msgpack_packer *pk = [[EventLog logger] startEvent];
	if (!pk) return;
    msgpack_pack_array(pk, 4);
    msgpack_pack_int(pk, 20);
    msgpack_pack_long_long(pk, [[NSDate date] timeIntervalSince1970] * 1000LL);
    if (toolId) {
    	msgpack_pack_raw(pk, [toolId length]);
    	msgpack_pack_raw_body(pk, [toolId UTF8String], [toolId length]);
    } else {
    	msgpack_pack_nil(pk);
    }
    if (toolName) {
    	msgpack_pack_raw(pk, [toolName length]);
    	msgpack_pack_raw_body(pk, [toolName UTF8String], [toolName length]);
    } else {
    	msgpack_pack_nil(pk);
    }
	[[EventLog logger] endEvent];
}

- (void)pack:(msgpack_packer*)pk {
    msgpack_pack_array(pk, 4);
    msgpack_pack_int(pk, eventID);
    msgpack_pack_long_long(pk, timestamp);
    if (toolId) {
    	msgpack_pack_raw(pk, [toolId length]);
    	msgpack_pack_raw_body(pk, [toolId UTF8String], [toolId length]);
    } else {
    	msgpack_pack_nil(pk);
    }
    if (toolName) {
    	msgpack_pack_raw(pk, [toolName length]);
    	msgpack_pack_raw_body(pk, [toolName UTF8String], [toolName length]);
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
    	self.toolId = nil;
    } else {
	    raw = &obj->via.raw;
		self.toolId = [NSString stringWithUTF8String:raw->ptr length:raw->size];
	}
    obj = &array->ptr[3];
    if (obj->type == MSGPACK_OBJECT_NIL) {
    	self.toolName = nil;
    } else {
	    raw = &obj->via.raw;
		self.toolName = [NSString stringWithUTF8String:raw->ptr length:raw->size];
	}
}

- (NSString*)ohmageSurveyID {
    return @"toolAbortedProbe";
}

- (void)addAttributesForOhmageJSON:(NSMutableArray*)list {
	NSMutableDictionary *dict;

    dict = [[NSMutableDictionary alloc] init];
    [dict setObject:@"toolId" forKey:@"prompt_id"];
	[dict setObject:(toolId ? toolId : @"NONE") forKey:@"value"];
	[list addObject:dict];
	[dict release];
	
    dict = [[NSMutableDictionary alloc] init];
    [dict setObject:@"toolName" forKey:@"prompt_id"];
	[dict setObject:(toolName ? toolName : @"NONE") forKey:@"value"];
	[list addObject:dict];
	[dict release];
	
}

- (void)dealloc {
    [toolId release];
    [toolName release];
	[super dealloc];
}

@end
