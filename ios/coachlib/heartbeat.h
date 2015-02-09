//
//  heartbeat.h
//  coachlib
//
//  Created by Mark Olschesky on 10/2/14.
//  Copyright (c) 2014 Catalyze, Inc.
//


#import "ASIHTTPRequest.h"
#import "JSONKit.h"

@interface heartbeat : NSObject

+ (void)checkQueue;

+ (void)logEvent:(NSString *)eventName withParameters:(NSDictionary *)parameters;

+ (void)signIn:(ASIBasicBlock)completionBlock;

@end
