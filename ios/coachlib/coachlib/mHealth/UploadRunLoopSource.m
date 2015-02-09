//
//  UploadRunLoopSource.m
//  iStressLess
//
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UploadRunLoopSource.h"
#import "EventLog.h"

@implementation UploadRunLoopSource

@synthesize runLoop;

- (id)initWithEventLog:(EventLog*)log {
    self = [super init];
    CFRunLoopSourceContext    context = {0, self, NULL, NULL, NULL, NULL, NULL,
        &RunLoopSourceScheduleRoutine,
        RunLoopSourceCancelRoutine,
        RunLoopSourcePerformRoutine};
    
    eventLog = log;
    [eventLog retain];
    runLoopSource = CFRunLoopSourceCreate(NULL, 0, &context);
    commands = [[NSMutableArray alloc] init];
    
    return self;
}

- (void)signal {
    CFRunLoopSourceSignal(runLoopSource);
    if (runLoop) CFRunLoopWakeUp(runLoop);
}

- (void)invalidate {
    CFRunLoopSourceInvalidate(runLoopSource);
}

- (void)sourceFired {
    [eventLog tryBackgroundUpload];
}

- (void)addToCurrentRunLoop
{
    CFRunLoopRef newRunLoop = CFRunLoopGetCurrent();
    CFRunLoopAddSource(newRunLoop, runLoopSource, kCFRunLoopDefaultMode);
}

void RunLoopSourceScheduleRoutine (void *info, CFRunLoopRef rl, CFStringRef mode)
{
    UploadRunLoopSource* obj = (UploadRunLoopSource*)info;
    obj.runLoop = rl;
//    AppDelegate*   del = [AppDelegate sharedAppDelegate];
//    UploadRunLoopContext* theContext = [[UploadRunLoopContext alloc] initWithSource:obj andLoop:rl];
    
//    [del performSelectorOnMainThread:@selector(registerSource:)
//                          withObject:theContext waitUntilDone:NO];
}

void RunLoopSourcePerformRoutine (void *info)
{
    UploadRunLoopSource*  obj = (UploadRunLoopSource*)info;
    [obj sourceFired];
}

void RunLoopSourceCancelRoutine (void *info, CFRunLoopRef rl, CFStringRef mode)
{
    UploadRunLoopSource* obj = (UploadRunLoopSource*)info;
    obj.runLoop = nil;

 //   AppDelegate* del = [AppDelegate sharedAppDelegate];
//    UploadRunLoopContext* theContext = [[UploadRunLoopContext alloc] initWithSource:obj andLoop:rl];
    
 //   [del performSelectorOnMainThread:@selector(removeSource:)
 //                         withObject:theContext waitUntilDone:YES];
}



@end
