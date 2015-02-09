//
//  GenericCampaign.m
//  iStressLess
//
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GenericCampaign.h"

@implementation GenericCampaign

- (id)init
{
    self = [super init];
    if (self) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        self.eventIDToEventRecordClasses = dict;
    }
    
    return self;
}



@end
