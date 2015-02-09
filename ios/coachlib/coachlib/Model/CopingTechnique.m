//
//  CopingTechnique.m
//  coachlib
//
//  Copyright (c) 2013 Department of Veteran's Affairs. All rights reserved.
//

#import "CopingTechnique.h"
#import "JournalEntry.h"
#import "SymptomRef.h"


@implementation CopingTechnique

@dynamic displayName;
@dynamic journalEntries;
@dynamic appliesTo;

- (NSString *)description {
    return [NSString stringWithFormat: @"%@", self.displayName];
}

@end
