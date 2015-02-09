//
//  ContactReference.h
//  coachlib
//
//  Copyright (c) 2012 Department of Veteran's Affairs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ContactReference : NSManagedObject

@property (nonatomic, retain) NSNumber * refID;
@property (nonatomic, retain) NSNumber * preferred;

@end
