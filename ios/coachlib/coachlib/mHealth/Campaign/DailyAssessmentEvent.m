
#import "DailyAssessmentEvent.h"

extern NSDateFormatter *isoFormatter;

@implementation DailyAssessmentEvent

@synthesize overallMood,sleepWell,howMuchAnger,conflictWithOthers,needForCoping,copingSituations,overallCoping,qualityOfGettingThingsDone,copingToolsUsed,copingSupport,takePrescribedMedications,medicationSideEffects,drinkAlcohol,howMuchAlcohol,takeNonPrescribedDrug;

- (id)init {
    self = [super init];
    if (self) {
    	eventID = 0;
    }
    
    return self;
}

+ (void)logWithOverallMood:(int)overallMood withSleepWell:(int)sleepWell withHowMuchAnger:(int)howMuchAnger withConflictWithOthers:(int)conflictWithOthers withNeedForCoping:(int)needForCoping withCopingSituations:(NSString*)copingSituations withOverallCoping:(int)overallCoping withQualityOfGettingThingsDone:(int)qualityOfGettingThingsDone withCopingToolsUsed:(NSArray*)copingToolsUsed withCopingSupport:(int)copingSupport withTakePrescribedMedications:(int)takePrescribedMedications withMedicationSideEffects:(int)medicationSideEffects withDrinkAlcohol:(int)drinkAlcohol withHowMuchAlcohol:(int)howMuchAlcohol withTakeNonPrescribedDrug:(int)takeNonPrescribedDrug {
	msgpack_packer *pk = [[EventLog logger] startEvent];
	if (!pk) return;
    msgpack_pack_array(pk, 17);
    msgpack_pack_int(pk, 0);
    msgpack_pack_long_long(pk, [[NSDate date] timeIntervalSince1970] * 1000LL);
    msgpack_pack_int(pk, overallMood);
    msgpack_pack_int(pk, sleepWell);
    msgpack_pack_int(pk, howMuchAnger);
    msgpack_pack_int(pk, conflictWithOthers);
    msgpack_pack_int(pk, needForCoping);
    if (copingSituations) {
    	msgpack_pack_raw(pk, [copingSituations length]);
    	msgpack_pack_raw_body(pk, [copingSituations UTF8String], [copingSituations length]);
    } else {
    	msgpack_pack_nil(pk);
    }
    msgpack_pack_int(pk, overallCoping);
    msgpack_pack_int(pk, qualityOfGettingThingsDone);
    if (copingToolsUsed) {
	    msgpack_pack_array(pk, [copingToolsUsed count]);
	    for (int i=0;i<[copingToolsUsed count];i++) {
	    	NSNumber *n = (NSNumber *)[copingToolsUsed objectAtIndex:i];
		    msgpack_pack_int(pk, [n intValue]);
	    }
    } else {
    	msgpack_pack_nil(pk);
    }
    msgpack_pack_int(pk, copingSupport);
    msgpack_pack_int(pk, takePrescribedMedications);
    msgpack_pack_int(pk, medicationSideEffects);
    msgpack_pack_int(pk, drinkAlcohol);
    msgpack_pack_int(pk, howMuchAlcohol);
    msgpack_pack_int(pk, takeNonPrescribedDrug);
	[[EventLog logger] endEvent];
}

- (void)pack:(msgpack_packer*)pk {
    msgpack_pack_array(pk, 17);
    msgpack_pack_int(pk, eventID);
    msgpack_pack_long_long(pk, timestamp);
    msgpack_pack_int(pk, overallMood);
    msgpack_pack_int(pk, sleepWell);
    msgpack_pack_int(pk, howMuchAnger);
    msgpack_pack_int(pk, conflictWithOthers);
    msgpack_pack_int(pk, needForCoping);
    if (copingSituations) {
    	msgpack_pack_raw(pk, [copingSituations length]);
    	msgpack_pack_raw_body(pk, [copingSituations UTF8String], [copingSituations length]);
    } else {
    	msgpack_pack_nil(pk);
    }
    msgpack_pack_int(pk, overallCoping);
    msgpack_pack_int(pk, qualityOfGettingThingsDone);
    if (copingToolsUsed) {
	    msgpack_pack_array(pk, [copingToolsUsed count]);
	    for (int i=0;i<[copingToolsUsed count];i++) {
	    	NSNumber *n = (NSNumber *)[copingToolsUsed objectAtIndex:i];
		    msgpack_pack_int(pk, [n intValue]);
	    }
    } else {
    	msgpack_pack_nil(pk);
    }
    msgpack_pack_int(pk, copingSupport);
    msgpack_pack_int(pk, takePrescribedMedications);
    msgpack_pack_int(pk, medicationSideEffects);
    msgpack_pack_int(pk, drinkAlcohol);
    msgpack_pack_int(pk, howMuchAlcohol);
    msgpack_pack_int(pk, takeNonPrescribedDrug);
}

- (void)unpack:(msgpack_object_array*)array {
	[super unpack:array];

    msgpack_object *obj;
    msgpack_object_raw *raw;
    msgpack_object_array *a;

    obj = &array->ptr[2];
	overallMood = obj->via.i64;
    obj = &array->ptr[3];
	sleepWell = obj->via.i64;
    obj = &array->ptr[4];
	howMuchAnger = obj->via.i64;
    obj = &array->ptr[5];
	conflictWithOthers = obj->via.i64;
    obj = &array->ptr[6];
	needForCoping = obj->via.i64;
    obj = &array->ptr[7];
    if (obj->type == MSGPACK_OBJECT_NIL) {
    	self.copingSituations = nil;
    } else {
	    raw = &obj->via.raw;
		self.copingSituations = [NSString stringWithUTF8String:raw->ptr length:raw->size];
	}
    obj = &array->ptr[8];
	overallCoping = obj->via.i64;
    obj = &array->ptr[9];
	qualityOfGettingThingsDone = obj->via.i64;
    obj = &array->ptr[10];
    if (obj->type == MSGPACK_OBJECT_NIL) {
    	self.copingToolsUsed = nil;
    } else {
	    a = &obj->via.array;
	    self.copingToolsUsed = [NSMutableArray arrayWithCapacity:a->size];
	    for (int i=0;i<a->size;i++) {
	    	NSNumber *n = [NSNumber numberWithInt:a->ptr[i].via.i64];
	    	[copingToolsUsed addObject:n];
	    }
	}
    obj = &array->ptr[11];
	copingSupport = obj->via.i64;
    obj = &array->ptr[12];
	takePrescribedMedications = obj->via.i64;
    obj = &array->ptr[13];
	medicationSideEffects = obj->via.i64;
    obj = &array->ptr[14];
	drinkAlcohol = obj->via.i64;
    obj = &array->ptr[15];
	howMuchAlcohol = obj->via.i64;
    obj = &array->ptr[16];
	takeNonPrescribedDrug = obj->via.i64;
}

- (NSString*)ohmageSurveyID {
    return @"dailyAssessment";
}

- (void)addAttributesForOhmageJSON:(NSMutableArray*)list {
	NSMutableDictionary *dict;

    dict = [[NSMutableDictionary alloc] init];
    [dict setObject:@"overallMood" forKey:@"prompt_id"];
	[dict setObject:(overallMood==-1 ? @"NOT_DISPLAYED" : [NSNumber numberWithInt:overallMood]) forKey:@"value"];
	[list addObject:dict];
	[dict release];
	
    dict = [[NSMutableDictionary alloc] init];
    [dict setObject:@"sleepWell" forKey:@"prompt_id"];
	[dict setObject:(sleepWell==-1 ? @"NOT_DISPLAYED" : [NSNumber numberWithInt:sleepWell]) forKey:@"value"];
	[list addObject:dict];
	[dict release];
	
    dict = [[NSMutableDictionary alloc] init];
    [dict setObject:@"howMuchAnger" forKey:@"prompt_id"];
	[dict setObject:(howMuchAnger==-1 ? @"NOT_DISPLAYED" : [NSNumber numberWithInt:howMuchAnger]) forKey:@"value"];
	[list addObject:dict];
	[dict release];
	
    dict = [[NSMutableDictionary alloc] init];
    [dict setObject:@"conflictWithOthers" forKey:@"prompt_id"];
	[dict setObject:(conflictWithOthers==-1 ? @"NOT_DISPLAYED" : [NSNumber numberWithInt:conflictWithOthers]) forKey:@"value"];
	[list addObject:dict];
	[dict release];
	
    dict = [[NSMutableDictionary alloc] init];
    [dict setObject:@"needForCoping" forKey:@"prompt_id"];
	[dict setObject:(needForCoping==-1 ? @"NOT_DISPLAYED" : [NSNumber numberWithInt:needForCoping]) forKey:@"value"];
	[list addObject:dict];
	[dict release];
	
    dict = [[NSMutableDictionary alloc] init];
    [dict setObject:@"copingSituations" forKey:@"prompt_id"];
	[dict setObject:(copingSituations ? copingSituations : @"NONE") forKey:@"value"];
	[list addObject:dict];
	[dict release];
	
    dict = [[NSMutableDictionary alloc] init];
    [dict setObject:@"overallCoping" forKey:@"prompt_id"];
	[dict setObject:(overallCoping==-1 ? @"NOT_DISPLAYED" : [NSNumber numberWithInt:overallCoping]) forKey:@"value"];
	[list addObject:dict];
	[dict release];
	
    dict = [[NSMutableDictionary alloc] init];
    [dict setObject:@"qualityOfGettingThingsDone" forKey:@"prompt_id"];
	[dict setObject:(qualityOfGettingThingsDone==-1 ? @"NOT_DISPLAYED" : [NSNumber numberWithInt:qualityOfGettingThingsDone]) forKey:@"value"];
	[list addObject:dict];
	[dict release];
	
    dict = [[NSMutableDictionary alloc] init];
    [dict setObject:@"copingToolsUsed" forKey:@"prompt_id"];
	[dict setObject:(copingToolsUsed ? copingToolsUsed : @"NONE") forKey:@"value"];
	[list addObject:dict];
	[dict release];
	
    dict = [[NSMutableDictionary alloc] init];
    [dict setObject:@"copingSupport" forKey:@"prompt_id"];
	[dict setObject:(copingSupport==-1 ? @"NOT_DISPLAYED" : [NSNumber numberWithInt:copingSupport]) forKey:@"value"];
	[list addObject:dict];
	[dict release];
	
    dict = [[NSMutableDictionary alloc] init];
    [dict setObject:@"takePrescribedMedications" forKey:@"prompt_id"];
	[dict setObject:(takePrescribedMedications==-1 ? @"NOT_DISPLAYED" : [NSNumber numberWithInt:takePrescribedMedications]) forKey:@"value"];
	[list addObject:dict];
	[dict release];
	
    dict = [[NSMutableDictionary alloc] init];
    [dict setObject:@"medicationSideEffects" forKey:@"prompt_id"];
	[dict setObject:(medicationSideEffects==-1 ? @"NOT_DISPLAYED" : [NSNumber numberWithInt:medicationSideEffects]) forKey:@"value"];
	[list addObject:dict];
	[dict release];
	
    dict = [[NSMutableDictionary alloc] init];
    [dict setObject:@"drinkAlcohol" forKey:@"prompt_id"];
	[dict setObject:(drinkAlcohol==-1 ? @"NOT_DISPLAYED" : [NSNumber numberWithInt:drinkAlcohol]) forKey:@"value"];
	[list addObject:dict];
	[dict release];
	
    dict = [[NSMutableDictionary alloc] init];
    [dict setObject:@"howMuchAlcohol" forKey:@"prompt_id"];
	[dict setObject:(howMuchAlcohol==-1 ? @"NOT_DISPLAYED" : [NSNumber numberWithInt:howMuchAlcohol]) forKey:@"value"];
	[list addObject:dict];
	[dict release];
	
    dict = [[NSMutableDictionary alloc] init];
    [dict setObject:@"takeNonPrescribedDrug" forKey:@"prompt_id"];
	[dict setObject:(takeNonPrescribedDrug==-1 ? @"NOT_DISPLAYED" : [NSNumber numberWithInt:takeNonPrescribedDrug]) forKey:@"value"];
	[list addObject:dict];
	[dict release];
	
}

- (void)dealloc {
    [copingSituations release];
    [copingToolsUsed release];
	[super dealloc];
}

@end
