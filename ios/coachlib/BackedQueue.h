//
//  BackedQueue.h
//  coachlib
//
//  Created by Josh Ault on 12/24/14.
//  Copyright (c) 2014 Catalyze, Inc.
//

#import <Foundation/Foundation.h>

@interface BackedQueue : NSObject {
    NSMutableArray *queue;
}

+ (BackedQueue *)sharedQueue;

- (void)synchronizeToDisk;

- (void)push:(id)item;
- (id)pop;
- (id)peek;
- (NSUInteger)count;

@end
