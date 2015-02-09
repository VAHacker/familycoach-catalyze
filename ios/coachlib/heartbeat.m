//
//  heartbeat.m
//  coachlib
//
//  Created by Mark Olschesky on 10/2/14.
//  Copyright (c) 2014 Department of Veteran's Affairs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "heartbeat.h"
#import "JSONKit.h"
#import "BackedQueue.h"

@implementation heartbeat : NSObject

+ (void)checkQueue {
    NSLog(@"checking queue...");
    if ([[BackedQueue sharedQueue] count] > 0) {
        NSLog(@"emptying queue...");
        // dispatch async job to pop items off and send them one by one
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            while ([[BackedQueue sharedQueue] count] > 0 && [[NSUserDefaults standardUserDefaults] boolForKey:@"__catalyze_reachability"]) {
                [heartbeat makeRequestWithBody:[[BackedQueue sharedQueue] pop]];
            }
        });
    }
}

+ (void) logEvent:(NSString *)eventName withParameters:(NSDictionary *)parameters{
    NSString *token = [[NSUserDefaults standardUserDefaults] valueForKey:@"token"];
    if(!token){
        [self signIn:^{
            [self createEntry:eventName withParameters:parameters];
        }];
    } else {
        [self createEntry:eventName withParameters:parameters];
    }
}

+ (void)signIn:(ASIBasicBlock)completionBlock {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.catalyze.io/v2/auth/signin"]];
    ASIFormDataRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setRequestMethod:@"POST"];
    [request addRequestHeader:@"Accept" value:@"application/json"];
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request addRequestHeader:@"X-Api-Key" value:@"969ad33b-fcc9-494a-acc6-66bfe2f2d1b6"];
    [request appendPostData:[@"{\"username\": \"VAUser\", \"password\": \"d42654ff3fe423c2544fc945aa62d0bf\"}" dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setCompletionBlock:^ {
        int statusCode = [request responseStatusCode];
        if (statusCode == 200) {
            NSString *resp = [request responseString];
            NSDictionary *jsonResp = [resp objectFromJSONString];
            NSString *token = [jsonResp objectForKey:@"sessionToken"];
            [[NSUserDefaults standardUserDefaults] setObject:token forKey:@"token"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        // call passed in completion block
        if (completionBlock) completionBlock();
    }];
    
    [request setDelegate:self];
    [request startAsynchronous];
}

+ (void)createEntry:(NSString *)eventName withParameters:(NSDictionary *)parameters {
    NSMutableDictionary *content = [NSMutableDictionary dictionary];
    [content setObject:eventName forKey:@"event"];
    if (parameters){
        [content setObject:parameters forKey:@"metadata"];
    }
    [content setObject:[[NSUserDefaults standardUserDefaults] valueForKey:@"sessionId"] forKey:@"sessionId"];
    NSString *subjectId = [[NSUserDefaults standardUserDefaults] valueForKey:@"subjectId"];
    if (subjectId) {
        [content setObject:subjectId forKey:@"subjectId"];
    }
    NSString *userInviteCode = [[NSUserDefaults standardUserDefaults] valueForKey:@"userInviteCode"];
    if (userInviteCode) {
        [content setObject:userInviteCode forKey:@"userInviteCode"];
    }
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
    [content setObject:[formatter stringFromDate:[NSDate date]] forKey:@"timestamp"];
    [content setObject:@"a3585955-23dd-40b2-b24c-8e823fe683fa" forKey:@"appId"];
    NSMutableDictionary *body = [NSMutableDictionary dictionary];
    [body setObject:content forKey:@"content"];
    NSString *JSON = [body JSONString];
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"__catalyze_reachability"]) {
        [heartbeat makeRequestWithBody:JSON];
    } else {
        // add it to the disk backed queue
        [[BackedQueue sharedQueue] push:JSON];
    }
}

+ (void)makeRequestWithBody:(NSString *)body {
    NSString *token = [[NSUserDefaults standardUserDefaults] valueForKey:@"token"];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.catalyze.io/v2/classes/event/entry"]];
    ASIFormDataRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setRequestMethod:@"POST"];
    [request addRequestHeader:@"Accept" value:@"application/json"];
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request addRequestHeader:@"X-Api-Key" value:@"969ad33b-fcc9-494a-acc6-66bfe2f2d1b6"];
    [request addRequestHeader:@"Authorization" value:[NSString stringWithFormat:@"Bearer %@", token]];
    [request appendPostData: [body dataUsingEncoding:NSUTF8StringEncoding]];
    [request setCompletionBlock:^ {
        int statusCode = [request responseStatusCode];
        if (statusCode == 200) {
            NSLog(@"Successfully posted event!");
        } else {
            NSLog(@"Failed to post event: %@", [request responseString]);
        }
    }];
    [request setDelegate:self];
    [request startAsynchronous];
}

@end

