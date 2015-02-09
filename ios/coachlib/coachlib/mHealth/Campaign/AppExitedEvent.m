
#import "AppExitedEvent.h"

extern NSDateFormatter *isoFormatter;

@implementation AppExitedEvent

@synthesize appExitedAccessibilityFeaturesActive;

- (id)init {
    self = [super init];
    if (self) {
    	eventID = 12;
    }
    
    return self;
}

+ (void)logWithAppExitedAccessibilityFeaturesActive:(int)appExitedAccessibilityFeaturesActive {
	msgpack_packer *pk = [[EventLog logger] startEvent];
	if (!pk) return;
    msgpack_pack_array(pk, 3);
    msgpack_pack_int(pk, 12);
    msgpack_pack_long_long(pk, [[NSDate date] timeIntervalSince1970] * 1000LL);
    msgpack_pack_int(pk, appExitedAccessibilityFeaturesActive);
	[[EventLog logger] endEvent];
}

- (void)pack:(msgpack_packer*)pk {
    msgpack_pack_array(pk, 3);
    msgpack_pack_int(pk, eventID);
    msgpack_pack_long_long(pk, timestamp);
    msgpack_pack_int(pk, appExitedAccessibilityFeaturesActive);
}

- (void)unpack:(msgpack_object_array*)array {
	[super unpack:array];

    msgpack_object *obj;

    obj = &array->ptr[2];
	appExitedAccessibilityFeaturesActive = obj->via.i64;
}

- (NSString*)ohmageSurveyID {
    return @"appExitedProbe";
}

- (void)addAttributesForOhmageJSON:(NSMutableArray*)list {
	NSMutableDictionary *dict;

    dict = [[NSMutableDictionary alloc] init];
    [dict setObject:@"appExitedAccessibilityFeaturesActive" forKey:@"prompt_id"];
	[dict setObject:(appExitedAccessibilityFeaturesActive==-1 ? @"NOT_DISPLAYED" : [NSNumber numberWithInt:appExitedAccessibilityFeaturesActive]) forKey:@"value"];
	[list addObject:dict];
	[dict release];
	
}

- (void)dealloc {
	[super dealloc];
}

@end
