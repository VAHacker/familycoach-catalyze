//
//  JournalEntry.h
//  coachlib
//
//  Copyright (c) 2013 Department of Veteran's Affairs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CopingTechnique, SymptomRef, SymptomTrigger;

@interface JournalEntry : NSManagedObject

@property (nonatomic, retain) NSDate * when;
@property (nonatomic, retain) NSString * displayName;
@property (nonatomic, retain) NSNumber * duration;
@property (nonatomic, retain) NSNumber * severity;
@property (nonatomic, retain) NSNumber * sleepDuration;
@property (nonatomic, retain) NSNumber * bedDuration;
@property (nonatomic, retain) NSString * experience;
@property (nonatomic, retain) NSString * consequences;
@property (nonatomic, retain) NSString * notes;
@property (nonatomic, retain) SymptomRef *symptom;
@property (nonatomic, retain) NSOrderedSet *triggers;
@property (nonatomic, retain) NSOrderedSet *copingTechniques;
@property (nonatomic, readonly) NSString * subLabel;
@property (nonatomic, readonly) NSString * detailLabel;
@end

@interface JournalEntry (CoreDataGeneratedAccessors)

- (void)insertObject:(SymptomTrigger *)value inTriggersAtIndex:(NSUInteger)idx;
- (void)removeObjectFromTriggersAtIndex:(NSUInteger)idx;
- (void)insertTriggers:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeTriggersAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInTriggersAtIndex:(NSUInteger)idx withObject:(SymptomTrigger *)value;
- (void)replaceTriggersAtIndexes:(NSIndexSet *)indexes withTriggers:(NSArray *)values;
- (void)addTriggersObject:(SymptomTrigger *)value;
- (void)removeTriggersObject:(SymptomTrigger *)value;
- (void)addTriggers:(NSOrderedSet *)values;
- (void)removeTriggers:(NSOrderedSet *)values;
- (void)insertObject:(CopingTechnique *)value inCopingTechniquesAtIndex:(NSUInteger)idx;
- (void)removeObjectFromCopingTechniquesAtIndex:(NSUInteger)idx;
- (void)insertCopingTechniques:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeCopingTechniquesAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInCopingTechniquesAtIndex:(NSUInteger)idx withObject:(CopingTechnique *)value;
- (void)replaceCopingTechniquesAtIndexes:(NSIndexSet *)indexes withCopingTechniques:(NSArray *)values;
- (void)addCopingTechniquesObject:(CopingTechnique *)value;
- (void)removeCopingTechniquesObject:(CopingTechnique *)value;
- (void)addCopingTechniques:(NSOrderedSet *)values;
- (void)removeCopingTechniques:(NSOrderedSet *)values;
@end
