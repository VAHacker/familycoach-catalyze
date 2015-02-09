
#import "AppLaunchedEvent.h"

extern NSDateFormatter *isoFormatter;

@implementation AppLaunchedEvent

@synthesize accessibilityFeaturesActiveOnLaunch;

- (id)init {
    self = [super init];
    if (self) {
    	eventID = 11;
    }
    
    return self;
}

+ (void)logWithAccessibilityFeaturesActiveOnLaunch:(int)accessibilityFeaturesActiveOnLaunch {
	msgpack_packer *pk = [[EventLog logger] startEvent];
	if (!pk) return;
    msgpack_pack_array(pk, 3);
    msgpack_pack_int(pk, 11);
    msgpack_pack_long_long(pk, [[NSDate date] timeIntervalSince1970] * 1000LL);
    msgpack_pack_int(pk, accessibilityFeaturesActiveOnLaunch);
	[[EventLog logger] endEvent];
}

- (void)pack:(msgpack_packer*)pk {
    msgpack_pack_array(pk, 3);
    msgpack_pack_int(pk, eventID);
    msgpack_pack_long_long(pk, timestamp);
    msgpack_pack_int(pk, accessibilityFeaturesActiveOnLaunch);
}

- (void)unpack:(msgpack_object_array*)array {
	[super unpack:array];

    msgpack_object *obj;

    obj = &array->ptr[2];
	accessibilityFeaturesActiveOnLaunch = obj->via.i64;
}

- (NSString*)ohmageSurveyID {
    return @"appLaunchedProbe";
}

- (void)addAttributesForOhmageJSON:(NSMutableArray*)list {
	NSMutableDictionary *dict;

    dict = [[NSMutableDictionary alloc] init];
    [dict setObject:@"accessibilityFeaturesActiveOnLaunch" forKey:@"prompt_id"];
	[dict setObject:(accessibilityFeaturesActiveOnLaunch==-1 ? @"NOT_DISPLAYED" : [NSNumber numberWithInt:accessibilityFeaturesActiveOnLaunch]) forKey:@"value"];
	[list addObject:dict];
	[dict release];
	
}

- (void)dealloc {
	[super dealloc];
}

@end
