//
//  OpenMHealthSession.m
//  iStressLess
//
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "OpenMHealthSurveyUpload.h"
#import "JSONKit.h"

@implementation OpenMHealthSurveyUpload

- (id)initWithData:(NSData*)uploadData
{
    self = [super init];
    if (self) {
        postData = uploadData;
        [postData retain];
        // Initialization code here.
    }
    
    return self;
}

- (NSString*)fullURLWithPath:(NSString*)path {
    return [NSString stringWithFormat:@"%@%@",baseURL,path];
}

- (void)open {
    NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
    
    baseURL = @"https://dev1.andwellness.org";
    [baseURL retain];
    
    [request setURL:[NSURL URLWithString:[self fullURLWithPath:@"/app/user/auth"]]];
    [request setHTTPMethod:@"POST"];

    NSString *boundary = @"---BOUNDARY-";

    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm:ss MM-dd-yy"];
    NSString *formattedDateString = [dateFormatter stringFromDate:date];
    [dateFormatter release];

    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request setValue:contentType forHTTPHeaderField:@"Content-Type"];
    
    NSData *boundaryData = [[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableData *postBody = [NSMutableData data];

    [postBody appendData:boundaryData];
    [postBody appendData:[@"Content-Disposition: form-data; name=\"campaign_urn\"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[@"some_value" dataUsingEncoding:NSUTF8StringEncoding]];

    [postBody appendData:boundaryData];
    [postBody appendData:[@"Content-Disposition: form-data; name=\"campaign_creation_timestamp\"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[formattedDateString dataUsingEncoding:NSUTF8StringEncoding]];

    [postBody appendData:boundaryData];
    [postBody appendData:[@"Content-Disposition: form-data; name=\"client\"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[@"ptsdexplorer" dataUsingEncoding:NSUTF8StringEncoding]];

    [postBody appendData:boundaryData];
    [postBody appendData:[@"Content-Disposition: form-data; name=\"user\"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[@"ohmage.george" dataUsingEncoding:NSUTF8StringEncoding]];

    [postBody appendData:boundaryData];
    [postBody appendData:[@"Content-Disposition: form-data; name=\"password\"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[@"ieR2Aema*" dataUsingEncoding:NSUTF8StringEncoding]];

    [postBody appendData:boundaryData];
    [postBody appendData:[@"Content-Disposition: form-data; name=\"survey\"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:postData];
    
    NSString *postLength = [NSString stringWithFormat:@"%d", [postBody length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:postBody];

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
    NSLog(@"%@",result);
    
    // release the connection, and the data object
    [receivedData release];
    receivedData = nil;
}

-(void)dealloc {
    [postData release];

    [super dealloc];
}

@end
