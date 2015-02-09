//
//  ContactReference.m
//  coachlib
//
//  Copyright (c) 2012 Department of Veteran's Affairs. All rights reserved.
//

#import "ContactReference.h"
#import "iStressLessAppDelegate.h"

@implementation ContactReference

@dynamic refID;
@dynamic preferred;

-(void)prepareForDeletion {
    if ([self.preferred boolValue]) {
        [[iStressLessAppDelegate instance] setSetting:@"preferredContactSet" to:@"false"];
    }
}

@end
