//
//  ContentEvent.h
//  coachlib
//
//  Copyright (c) 2012 Department of Veteran's Affairs. All rights reserved.
//

#import <Foundation/Foundation.h>

#define CONTENT_EVENT_BACK_PRESSED 1
#define CONTENT_EVENT_GATHER_NAV_STACK 2

@interface ContentEvent : NSObject
@property (nonatomic) int eventType;
@property (nonatomic,retain) id data;

+(ContentEvent*)eventOfType:(int)eventType;

@end
