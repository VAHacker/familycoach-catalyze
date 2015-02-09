//
//  Reminder.h
//  coachlib
//
//  Copyright (c) 2012 Department of Veteran's Affairs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Reminder : NSManagedObject

@property (nonatomic, retain) NSDate * time;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSString * reference;
@property (nonatomic, retain) NSString * displayName;
@property (nonatomic, retain) NSString * eventID;

@end
