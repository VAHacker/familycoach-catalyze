//
//  ContentEvent.m
//  coachlib
//
//  Copyright (c) 2012 Department of Veteran's Affairs. All rights reserved.
//

#import "ContentEvent.h"

@implementation ContentEvent

+(ContentEvent*)eventOfType:(int)eventType {
    ContentEvent *event = [[[ContentEvent alloc] init] autorelease];
    event.eventType = eventType;
    return event;
}

@end
