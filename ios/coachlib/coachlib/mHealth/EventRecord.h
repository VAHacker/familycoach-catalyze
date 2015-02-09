//
//  EventRecord.h
//  iStressLess
//
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "msgpack.h"

extern NSDateFormatter *dateFormatter;
extern NSDateFormatter *isoFormatter;

@interface EventRecord : NSObject {
    int eventID;
    long long timestamp;
}

- (void)pack:(msgpack_packer*)pk;
- (void)unpack:(msgpack_object_array*)array;

@end
