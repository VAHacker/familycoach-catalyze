//
//  Campaign.h
//  iStressLess
//
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "msgpack.h"

@class EventRecord;

@interface Campaign : NSObject {
    NSDictionary *eventIDToEventRecordClasses;
}

@property (readonly) NSString *urn;
@property (nonatomic, retain) NSDictionary *eventIDToEventRecordClasses;

- (EventRecord*)unpackEventFrom:(msgpack_unpacked*)pac;

@end
