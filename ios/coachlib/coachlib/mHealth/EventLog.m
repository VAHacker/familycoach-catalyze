//
//  EventLog.m
//  iStressLess
//
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "EventLog.h"
#import "EventRecord.h"
#import "Campaign.h"
#import "OpenMHealthSession.h"
#import "OpenMHealthSurveyUpload.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "ASIDataCompressor.h"
#import "JSONKit.h"
#import "iStressLessAppDelegate.h"
#import "msgpack.h"

#define REMOVE_OLD_LOGS 0
#define MAX_EVENT_COUNT 200
#define MAX_LOG_SIZE 4096

NSString *NetworkConnectivityErrorMsg = @"Could not connect to server.";
NSString *SSLErrorMsg = @"There was a problem making a secure connection.  Please make sure this device's date and time are correct.";

static EventLog *logger;

@implementation EventLog

+ (EventLog*)logger {
    return logger;
}

- (msgpack_packer*)startEvent {
    [eventLock lock];
    if (!currentLogFile) [self openLog];
    return &logPacker;
}

- (void)endEvent {
    currentLogEventCount++;
    if ((currentLogEventCount > MAX_EVENT_COUNT) || (ftell(currentLogStream) > MAX_LOG_SIZE)) {
        [self rollLog];
    }
    [eventLock unlock];
}

- (NSString*)openSession {
    if (!username || !password) {
        return @"No username and/or password set.";
    }
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[baseURL stringByAppendingString:@"/app/user/auth"]]];
    [request setPostValue:username forKey:@"user"];
    [request setPostValue:password forKey:@"password"];
    [request setPostValue:@"ptsdexplorer" forKey:@"client"];
    
    [request startSynchronous];
    
    NSString *result = @"Unknown error";

    NSError *error = [request error];    
    if (!error) {
        NSString *response = [request responseString];
        NSDictionary *dict = [response objectFromJSONString];
        result = [dict valueForKey:@"result"];
        if ([result isEqualToString:@"success"]) {
            NSLog(@"Logged into Ohmage");
            hashedPassword = [dict valueForKey:@"hashed_password"];
            [hashedPassword retain];
            result = nil;
        } else {
            NSArray *a = [dict valueForKey:@"errors"];
            NSDictionary *subdict = [a objectAtIndex:0];
            result = [subdict valueForKey:@"text"];
        }
    } else {
        NSString *errorStr = [error localizedDescription];
        NSLog(@"%@",errorStr);
        if ([[error domain] isEqualToString:NetworkRequestErrorDomain]) {
            if (([error code] == ASIConnectionFailureErrorType) || ([error code] == ASIRequestTimedOutErrorType)) {
                if ([errorStr rangeOfString:@"SSL"].location == NSNotFound) {
                    result = NetworkConnectivityErrorMsg;
                } else {
                    result = SSLErrorMsg;
                }
            }
        }
    }

    if (!result) {
        ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[baseURL stringByAppendingString:@"/app/campaign/read"]]];
        [request setPostValue:username forKey:@"user"];
        [request setPostValue:hashedPassword forKey:@"password"];
//        [request setPostValue:[campaign urn] forKey:@"campaign_urn_list"];
        [request setPostValue:@"ptsdexplorer" forKey:@"client"];
        [request setPostValue:@"short" forKey:@"output_format"];
        [request setPostValue:@"UTF-8" forKey:@"charset"];
        
        [request startSynchronous];
        NSError *error = [request error];
        if (!error) {
            NSString *response = [request responseString];
            NSDictionary *dict = [response objectFromJSONString];
            campaignUrn = [((NSArray*)[[dict objectForKey:@"metadata"] objectForKey:@"items"]) objectAtIndex:0];
            [campaignUrn retain];
            creationTimestamp = [[[dict objectForKey:@"data"] objectForKey:campaignUrn] objectForKey:@"creation_timestamp"];
            [creationTimestamp retain];
        } else {
            result = @"Problem logging in to Ohmage service.";
        }
    }

    return result;
}

#ifdef EXPLORER
- (void)uploadThreadMain {
    // Set up an autorelease pool here if not using garbage collection.
    BOOL done = NO;

    baseURL = @"https://ri.omh.io";
    [baseURL retain];

    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    // Add your sources or timers to the run loop and do any other setup.
    [uploadRunloopSource addToCurrentRunLoop];
        
    do {
        if (pool != nil) pool = [[NSAutoreleasePool alloc] init];
        
        // Start the run loop but return after each source is handled.
        SInt32    result = CFRunLoopRunInMode(kCFRunLoopDefaultMode, 10, YES);

        [pool release];
        pool = nil;
        
        // If a source explicitly stopped the run loop, or if there are no
        // sources or timers, go ahead and exit.
        if ((result == kCFRunLoopRunStopped) || (result == kCFRunLoopRunFinished))
            done = YES;
        
        // Check for any other exit conditions here and set the
        // done variable as needed.
    }
    while (!done);
    
    // Clean up code here. Be sure to release any allocated autorelease pools.
}

- (BOOL)doSynchronousUpload:(NSData*)postData withCompression:(BOOL)usingCompression {

    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[baseURL stringByAppendingString:@"/app/survey/upload"]]];

    if (usingCompression) {
        request.shouldCompressRequestBody = YES;
        request.shouldWaitToInflateCompressedResponses = NO;
    }

    [request setPostValue:campaignUrn forKey:@"campaign_urn"];
    [request setPostValue:creationTimestamp forKey:@"campaign_creation_timestamp"];
    [request setPostValue:@"ptsdexplorer" forKey:@"client"];
    [request setPostValue:username forKey:@"user"];
    [request setPostValue:hashedPassword forKey:@"password"];
    [request setData:postData withFileName:nil andContentType:nil forKey:@"surveys"];
    
    [request startSynchronous];
    NSError *error = [request error];
    if (!error) {
        NSLog(@"%@",[request responseHeaders]);
        NSString *response = [request responseString];
        NSLog(@"response: %@",response);
        NSDictionary *dict = [response objectFromJSONString];
        NSString *result = [dict objectForKey:@"result"];
        if ([result isEqualToString:@"success"]) {
            return TRUE;
        }
    }
    
    return FALSE;
}

- (BOOL)tryBackgroundUpload {
    
    if (!hashedPassword) {
        NSString *errMsg = [self openSession];
        if (errMsg) {
            [[iStressLessAppDelegate instance] performSelectorOnMainThread:@selector(loginFailed:) withObject:errMsg waitUntilDone:FALSE];
            return FALSE;
        } else {
            [[iStressLessAppDelegate instance] performSelectorOnMainThread:@selector(loginSucceeded) withObject:nil waitUntilDone:FALSE];
        }
    }
    
    boolean_t winning = TRUE;
    while (winning) {
        NSString *toUpload = nil;
        @synchronized (logLock) {
            int count = [logFiles count];
            if (count > 0) {
                toUpload = [logFiles objectAtIndex:0];
                [toUpload retain];
                [logFiles removeObjectAtIndex:0];
            }
        }
        
        if (toUpload == nil) break;
        
        NSLog(@"uploading log file '%@'",toUpload); 

        NSString *fn = [logDir stringByAppendingPathComponent:toUpload];
        FILE *f = fopen([fn cStringUsingEncoding:1], "r");
        fseek(f, 0, SEEK_END);
        long long size = ftell(f);
        fseek(f, 0, SEEK_SET);
        
        if (size > 0) {
            msgpack_unpacker pac;
            msgpack_unpacked unpacked;
            msgpack_unpacker_init(&pac, MSGPACK_UNPACKER_INIT_BUFFER_SIZE);
            msgpack_unpacked_init(&unpacked);

            NSMutableData *postData = [[NSMutableData alloc] init];
            [postData appendData:[@"[" dataUsingEncoding:1]];
            
            boolean_t first = TRUE;
            long fileLeft = size - ftell(f);
            while (fileLeft > 0) {
                long bufferSize = msgpack_unpacker_buffer_capacity(&pac);
                long amtToRead = bufferSize;
                if (amtToRead > fileLeft) amtToRead = fileLeft;
                long amtRead = fread(msgpack_unpacker_buffer(&pac), 1, amtToRead, f);
                fileLeft -= amtRead;
                msgpack_unpacker_buffer_consumed(&pac, amtRead);
                
                while (msgpack_unpacker_next(&pac, &unpacked)) {
                    if (!first) {
                        [postData appendData:[@",\r\n" dataUsingEncoding:1]];
                    }
                    EventRecord *event = [campaign unpackEventFrom:&unpacked];
                    [event writeOhmageJSON:postData];
                    [event release];
                    first = FALSE;
                }
            }
            [postData appendData:[@"]" dataUsingEncoding:NSUTF8StringEncoding]];
            
            fclose(f);
            msgpack_unpacked_destroy(&unpacked);

            NSLog(@"content size: %d",[postData length]);

            NSString *content = [[NSString alloc]  initWithBytes:[postData bytes]
                                                          length:[postData length] encoding: NSUTF8StringEncoding];
            NSLog(@"content: %@", content);
            [content release];

            if ([self doSynchronousUpload:postData withCompression:FALSE]) {
                NSLog(@"success; deleting log file '%@'",toUpload); 
                [fmgr removeItemAtPath:fn error:NULL];
            } else {
                NSLog(@"failed; keeping log file '%@'",toUpload); 
                [logFiles insertObject:toUpload atIndex:0];
                winning = FALSE;
            }

            [postData release];
        } else {
            NSLog(@"zero-length file; deleting log file '%@'",toUpload);
            fclose(f);
            [fmgr removeItemAtPath:fn error:NULL];
        }
            
        [toUpload release];
    }
    
    return TRUE;
}
#endif

- (id)initForCampaign:(Campaign*)_campaign {
#ifndef EXPLORER
    return nil;
#else    
    self = [super init];
    if (self) {
        logger = self;
        campaign = _campaign;
        [campaign retain];
        logLock = [[NSObject alloc] init];
        eventLock = [[NSLock alloc] init];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *path = [paths objectAtIndex:0];
        
        NSString *campaignClassName = [NSString stringWithCString:object_getClassName(campaign)];
        logDir = [[path stringByAppendingPathComponent:@"eventLogs"] stringByAppendingPathComponent:campaignClassName];
        [logDir retain];
        
        fmgr = [[NSFileManager alloc] init];
        [fmgr createDirectoryAtPath:logDir withIntermediateDirectories:TRUE attributes:nil error:NULL];
        NSArray *files = [fmgr contentsOfDirectoryAtPath:logDir error:NULL];
        logFiles = [files sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
        logFiles = [NSMutableArray arrayWithArray:logFiles];
        [logFiles retain];

        if (REMOVE_OLD_LOGS) {
            while ([logFiles count] > 0) {
                NSString *fn = [logFiles objectAtIndex:0];
                NSLog(@"removing log file '%@'",fn);
                NSString *pathname = [logDir stringByAppendingPathComponent:fn];
                [fmgr removeItemAtPath:pathname error:NULL];
                [logFiles removeObjectAtIndex:0];
            }
        }
 
        uploadRunloopSource = [[UploadRunLoopSource alloc] initWithEventLog:self];
        uploadThread = [[NSThread alloc] initWithTarget:self selector:@selector(uploadThreadMain) object:nil];
        [uploadThread start];  // Actually create the thread
    }
    
    return self;
#endif
}

- (void)setUsername:(NSString*)_username andPassword:(NSString*)_password {
    username = _username;
    [username retain];
    password = _password;
    [password retain];
}

- (void)tryLogin {
    [self tryUpload];
}

+ (long long) timestamp {
    return [[NSDate date] timeIntervalSince1970] * 1000LL;
}

- (void)tryBackgroundUpload {
    [uploadRunloopSource signal];
}

- (void)tryUpload {
    [uploadRunloopSource signal];
}

static int msgpack_fwrite_write(void* data, const char* buf, unsigned int len) {
    FILE *f = (FILE*)data;
    return fwrite(buf,1,len,f);
}

- (void)closeLog {
    if (currentLogFile != nil) {
        @synchronized (logLock) {
            NSLog(@"closing log file '%@' with %d events",currentLogFile,currentLogEventCount);
            currentLogEventCount = 0;
            fclose(currentLogStream);
            currentLogStream = NULL;
            [logFiles addObject:currentLogFile];
            [currentLogFile release];
            currentLogFile = nil;
        }
        
        [self tryUpload];
    }
}

- (void)openLog {
    long long timestamp = [[NSDate date] timeIntervalSince1970] * 1000LL;
    currentLogFile = [NSString stringWithFormat:@"events-%016llx.log", timestamp];
    [currentLogFile retain];
    NSLog(@"opening log file '%@'",currentLogFile);
    currentLogEventCount = 0;
    currentLogStream = fopen([[logDir stringByAppendingPathComponent:currentLogFile] cStringUsingEncoding:1], "w");
    msgpack_packer_init(&logPacker, currentLogStream, msgpack_fwrite_write);
}

- (void)rollLog {
    [self closeLog];
    [self openLog];
}

- (void)log:(EventRecord*)event {
#ifdef EXPLORER
    [eventLock lock];
    
    if (!currentLogFile) [self openLog];
    [event pack:&logPacker];
    currentLogEventCount++;
    if ((currentLogEventCount > MAX_EVENT_COUNT) || (ftell(currentLogStream) > MAX_LOG_SIZE)) {
        [self rollLog];
    }

    [eventLock unlock];
#endif    
}

- (void)close {
    [uploadRunloopSource invalidate];
    [self closeLog];
}

- (void)dealloc {
    [logFiles release];
    [logLock release];
    [fmgr release];
    [campaign release];
    [campaignUrn release];
    [username release];
    [password release];
    
    [super dealloc];
}

@end
