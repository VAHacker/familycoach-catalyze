//
//  ExerciseRef.h
//  coachlib
//
//  Copyright (c) 2012 Department of Veteran's Affairs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Content.h"

@class SymptomRef;

@interface ExerciseRef : NSManagedObject

@property (nonatomic, retain) NSString * sectionName;
@property (nonatomic, retain) NSNumber * sectionOrder;
@property (nonatomic, retain) NSString * displayName;
@property (nonatomic, retain) NSNumber * inFavoriteList;
@property (nonatomic, retain) NSNumber * isCategory;
@property (nonatomic, retain) NSNumber * negativeScore;
@property (nonatomic, retain) NSNumber * positiveScore;
@property (nonatomic, retain) NSNumber * weight;
@property (nonatomic, retain) NSString * refID;
@property (nonatomic, retain) NSString * categoryRefID;
@property (nonatomic, retain) NSNumber * addressable;
@property (nonatomic, retain) NSNumber * childCount;
@property (nonatomic, retain) ExerciseRef *parent;
@property (nonatomic, retain) NSSet *helpsWithSymptoms;

@property (nonatomic, readonly) Content *ref;
@end

@interface ExerciseRef (CoreDataGeneratedAccessors)

- (void)addHelpsWithSymptomsObject:(SymptomRef *)value;
- (void)removeHelpsWithSymptomsObject:(SymptomRef *)value;
- (void)addHelpsWithSymptoms:(NSSet *)values;
- (void)removeHelpsWithSymptoms:(NSSet *)values;

@end
