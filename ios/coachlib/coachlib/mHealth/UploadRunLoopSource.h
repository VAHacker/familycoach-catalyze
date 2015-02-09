//
//  UploadRunLoopSource.h
//  iStressLess
//
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class EventLog;

@interface UploadRunLoopSource : NSObject
{
    CFRunLoopSourceRef runLoopSource;
    NSMutableArray* commands;
    EventLog* eventLog;
    CFRunLoopRef runLoop;
}

@property (assign) CFRunLoopRef runLoop;

- (id)initWithEventLog:(EventLog*)log;
- (void)addToCurrentRunLoop;
- (void)invalidate;
- (void)signal;

// Handler method
- (void)sourceFired;

@end

// These are the CFRunLoopSourceRef callback functions.
void RunLoopSourceScheduleRoutine (void *info, CFRunLoopRef rl, CFStringRef mode);
void RunLoopSourcePerformRoutine (void *info);
void RunLoopSourceCancelRoutine (void *info, CFRunLoopRef rl, CFStringRef mode);

// RunLoopContext is a container object used during registration of the input source.
@interface UploadRunLoopContext : NSObject
{
    CFRunLoopRef        runLoop;
    UploadRunLoopSource*        source;
}
@property (readonly) CFRunLoopRef runLoop;
@property (readonly) UploadRunLoopSource* source;

- (id)initWithSource:(UploadRunLoopSource*)src andLoop:(CFRunLoopRef)loop;

@end
