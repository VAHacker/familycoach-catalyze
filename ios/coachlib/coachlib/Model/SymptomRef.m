//
//  SymptomRef.m
//  coachlib
//
//  Copyright (c) 2013 Department of Veteran's Affairs. All rights reserved.
//

#import "SymptomRef.h"
#import "CopingTechnique.h"
#import "ExerciseRef.h"
#import "JournalEntry.h"
#import "SymptomTrigger.h"


@implementation SymptomRef

@dynamic sectionName;
@dynamic displayName;
@dynamic refID;
@dynamic helpedBy;
@dynamic journalEntries;
@dynamic copingTechniques;
@dynamic triggers;

- (NSString *)description {
    return [NSString stringWithFormat: @"%@", self.displayName];
}

@end
