//
//  OpenMHealthSession.h
//  iStressLess
//
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OpenMHealthSession.h"

@interface OpenMHealthSurveyUpload : NSObject {
    NSData *postData;
    NSMutableData *receivedData;
    NSString *baseURL;
    NSString *hashedPassword;
}

-(id)initWithData:(NSData*)uploadData;
-(void)open;

@end
