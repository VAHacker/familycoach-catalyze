//
//  OpenMHealthSession.h
//  iStressLess
//
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OpenMHealthSession : NSObject {
    NSMutableData *receivedData;
    NSString *baseURL;
    NSString *hashedPassword;
}

-(id)init;
-(void)open;

@end
