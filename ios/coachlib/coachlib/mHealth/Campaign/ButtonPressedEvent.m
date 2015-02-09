
#import "ButtonPressedEvent.h"

extern NSDateFormatter *isoFormatter;

@implementation ButtonPressedEvent

@synthesize buttonPressedButtonId,buttonPressedButtonTitle;

- (id)init {
    self = [super init];
    if (self) {
    	eventID = 6;
    }
    
    return self;
}

+ (void)logWithButtonPressedButtonId:(NSString*)buttonPressedButtonId withButtonPressedButtonTitle:(NSString*)buttonPressedButtonTitle {
	msgpack_packer *pk = [[EventLog logger] startEvent];
	if (!pk) return;
    msgpack_pack_array(pk, 4);
    msgpack_pack_int(pk, 6);
    msgpack_pack_long_long(pk, [[NSDate date] timeIntervalSince1970] * 1000LL);
    if (buttonPressedButtonId) {
    	msgpack_pack_raw(pk, [buttonPressedButtonId length]);
    	msgpack_pack_raw_body(pk, [buttonPressedButtonId UTF8String], [buttonPressedButtonId length]);
    } else {
    	msgpack_pack_nil(pk);
    }
    if (buttonPressedButtonTitle) {
    	msgpack_pack_raw(pk, [buttonPressedButtonTitle length]);
    	msgpack_pack_raw_body(pk, [buttonPressedButtonTitle UTF8String], [buttonPressedButtonTitle length]);
    } else {
    	msgpack_pack_nil(pk);
    }
	[[EventLog logger] endEvent];
}

- (void)pack:(msgpack_packer*)pk {
    msgpack_pack_array(pk, 4);
    msgpack_pack_int(pk, eventID);
    msgpack_pack_long_long(pk, timestamp);
    if (buttonPressedButtonId) {
    	msgpack_pack_raw(pk, [buttonPressedButtonId length]);
    	msgpack_pack_raw_body(pk, [buttonPressedButtonId UTF8String], [buttonPressedButtonId length]);
    } else {
    	msgpack_pack_nil(pk);
    }
    if (buttonPressedButtonTitle) {
    	msgpack_pack_raw(pk, [buttonPressedButtonTitle length]);
    	msgpack_pack_raw_body(pk, [buttonPressedButtonTitle UTF8String], [buttonPressedButtonTitle length]);
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
    	self.buttonPressedButtonId = nil;
    } else {
	    raw = &obj->via.raw;
		self.buttonPressedButtonId = [NSString stringWithUTF8String:raw->ptr length:raw->size];
	}
    obj = &array->ptr[3];
    if (obj->type == MSGPACK_OBJECT_NIL) {
    	self.buttonPressedButtonTitle = nil;
    } else {
	    raw = &obj->via.raw;
		self.buttonPressedButtonTitle = [NSString stringWithUTF8String:raw->ptr length:raw->size];
	}
}

- (NSString*)ohmageSurveyID {
    return @"buttonPressedProbe";
}

- (void)addAttributesForOhmageJSON:(NSMutableArray*)list {
	NSMutableDictionary *dict;

    dict = [[NSMutableDictionary alloc] init];
    [dict setObject:@"buttonPressedButtonId" forKey:@"prompt_id"];
	[dict setObject:(buttonPressedButtonId ? buttonPressedButtonId : @"NONE") forKey:@"value"];
	[list addObject:dict];
	[dict release];
	
    dict = [[NSMutableDictionary alloc] init];
    [dict setObject:@"buttonPressedButtonTitle" forKey:@"prompt_id"];
	[dict setObject:(buttonPressedButtonTitle ? buttonPressedButtonTitle : @"NONE") forKey:@"value"];
	[list addObject:dict];
	[dict release];
	
}

- (void)dealloc {
    [buttonPressedButtonId release];
    [buttonPressedButtonTitle release];
	[super dealloc];
}

@end
