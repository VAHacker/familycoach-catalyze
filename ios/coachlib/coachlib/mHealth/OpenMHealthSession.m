//
//  OpenMHealthSession.m
//  iStressLess
//
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "OpenMHealthSession.h"
#import "JSONKit.h"

@implementation OpenMHealthSession

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (NSString*)fullURLWithPath:(NSString*)path {
    return [NSString stringWithFormat:@"%@%@",baseURL,path];
}

- (void)open {
    NSString *post = @"user=ohmage.george&password=ieR2Aema*&client=ptsdexplorer";
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
    
    NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
    
    baseURL = @"https://dev1.andwellness.org";
    [baseURL retain];
    
    [request setURL:[NSURL URLWithString:[self fullURLWithPath:@"/app/user/auth"]]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];

    NSURLConnection *conn=[[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (conn) 
    {
        receivedData = [[NSMutableData data] retain];
    } 
    else 
    {
        // inform the user that the download could not be made
    }    
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [receivedData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // do something with the data
    // receivedData is declared as a method instance elsewhere
    NSLog(@"Succeeded! Received %d bytes of data",[receivedData length]);
    NSDictionary *dict = [receivedData objectFromJSONData];
    NSString *result = [dict valueForKey:@"result"];
    if ([result isEqualToString:@"success"]) {
        hashedPassword = [dict valueForKey:@"hashed_password"];
        [hashedPassword retain];
    }
    
    // release the connection, and the data object
    [receivedData release];
    receivedData = nil;
}

@end
