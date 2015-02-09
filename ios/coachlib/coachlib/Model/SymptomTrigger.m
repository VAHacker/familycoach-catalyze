//
//  SymptomTrigger.m
//  coachlib
//
//  Copyright (c) 2013 Department of Veteran's Affairs. All rights reserved.
//

#import "SymptomTrigger.h"
#import "JournalEntry.h"
#import "SymptomRef.h"


@implementation SymptomTrigger

@dynamic displayName;
@dynamic permanent;
@dynamic journalEntries;
@dynamic appliesTo;

- (NSString *)description {
    return [NSString stringWithFormat: @"%@", self.displayName];
}


@end
