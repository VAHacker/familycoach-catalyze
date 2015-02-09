//
//  CopingTechnique.h
//  coachlib
//
//  Copyright (c) 2013 Department of Veteran's Affairs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class JournalEntry, SymptomRef;

@interface CopingTechnique : NSManagedObject

@property (nonatomic, retain) NSString * displayName;
@property (nonatomic, retain) NSSet *journalEntries;
@property (nonatomic, retain) NSSet *appliesTo;
@end

@interface CopingTechnique (CoreDataGeneratedAccessors)

- (void)addJournalEntriesObject:(JournalEntry *)value;
- (void)removeJournalEntriesObject:(JournalEntry *)value;
- (void)addJournalEntries:(NSSet *)values;
- (void)removeJournalEntries:(NSSet *)values;

- (void)addAppliesToObject:(SymptomRef *)value;
- (void)removeAppliesToObject:(SymptomRef *)value;
- (void)addAppliesTo:(NSSet *)values;
- (void)removeAppliesTo:(NSSet *)values;

@end
