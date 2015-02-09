//
//  EventLog.h
//  iStressLess
//
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UploadRunLoopSource.h"
#import "Campaign.h"
#import "EventRecord.h"
#import "msgpack.h"

extern NSString *NetworkConnectivityErrorMsg;

@interface EventLog : NSObject {
    NSThread *uploadThread;
    NSFileManager *fmgr;
    UploadRunLoopSource *uploadRunloopSource;
    Campaign *campaign;
    NSString *logDir;
    NSObject *logLock;
    NSLock *eventLock;
    NSMutableArray *logFiles;
    NSString *currentLogFile;
    FILE *currentLogStream;
    int currentLogEventCount;
    msgpack_packer logPacker;
    NSString *username;
    NSString *password;
    NSString *baseURL;
    NSString *hashedPassword;
    NSString *creationTimestamp;
    NSString *campaignUrn;
}

+ (EventLog*)logger;
+ (long long)timestamp;

- (id)initForCampaign:(Campaign*)_campaign;
- (void)setUsername:(NSString*)_username andPassword:(NSString*)_password;
- (void)tryLogin;
- (void)tryBackgroundUpload;
- (void)log:(EventRecord*)event;

- (msgpack_packer*)startEvent;
- (void)endEvent;

- (void)closeLog;
- (void)close;

@end

