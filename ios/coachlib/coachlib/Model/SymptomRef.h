//
//  SymptomRef.h
//  coachlib
//
//  Copyright (c) 2013 Department of Veteran's Affairs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CopingTechnique, ExerciseRef, JournalEntry, SymptomTrigger;

@interface SymptomRef : NSManagedObject

@property (nonatomic, retain) NSString * sectionName;
@property (nonatomic, retain) NSString * displayName;
@property (nonatomic, retain) NSString * refID;
@property (nonatomic, retain) NSSet *helpedBy;
@property (nonatomic, retain) NSSet *journalEntries;
@property (nonatomic, retain) NSSet *copingTechniques;
@property (nonatomic, retain) NSSet *triggers;
@end

@interface SymptomRef (CoreDataGeneratedAccessors)

- (void)addHelpedByObject:(ExerciseRef *)value;
- (void)removeHelpedByObject:(ExerciseRef *)value;
- (void)addHelpedBy:(NSSet *)values;
- (void)removeHelpedBy:(NSSet *)values;

- (void)addJournalEntriesObject:(JournalEntry *)value;
- (void)removeJournalEntriesObject:(JournalEntry *)value;
- (void)addJournalEntries:(NSSet *)values;
- (void)removeJournalEntries:(NSSet *)values;

- (void)addCopingTechniquesObject:(CopingTechnique *)value;
- (void)removeCopingTechniquesObject:(CopingTechnique *)value;
- (void)addCopingTechniques:(NSSet *)values;
- (void)removeCopingTechniques:(NSSet *)values;

- (void)addTriggersObject:(SymptomTrigger *)value;
- (void)removeTriggersObject:(SymptomTrigger *)value;
- (void)addTriggers:(NSSet *)values;
- (void)removeTriggers:(NSSet *)values;

@end
