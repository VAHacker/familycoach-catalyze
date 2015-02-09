//
//  Campaign.m
//  iStressLess
//
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Campaign.h"
#import "EventRecord.h"

@implementation Campaign

@synthesize eventIDToEventRecordClasses;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (NSString*)urn {
    return nil;
}

- (EventRecord*)unpackEventFrom:(msgpack_unpacked*)pac {
    int eventID = pac->data.via.array.ptr[0].via.i64;
    Class class = [eventIDToEventRecordClasses objectForKey:[NSNumber numberWithInt:eventID]];
    EventRecord *rec = [[[class alloc] init] autorelease];
    [rec unpack:&pac->data.via.array];
    return rec;
}

@end
