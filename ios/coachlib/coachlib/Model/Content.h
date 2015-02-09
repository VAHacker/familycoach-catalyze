//
//  Content.h
//  coachlib
//
//  Copyright (c) 2012 Department of Veteran's Affairs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Item.h"

@class Content;

@interface Content : Item

@property (nonatomic, retain) NSNumber * weight;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * image;
@property (nonatomic, retain) NSString * uniqueID;
@property (nonatomic, retain) NSString * file;
@property (nonatomic, retain) NSString * ui;
@property (nonatomic, retain) NSString * icon;
@property (nonatomic, retain) NSString * backButton;
@property (nonatomic, retain) NSNumber * score;
@property (nonatomic, retain) NSString * mainText;
@property (nonatomic, retain) NSString * audio;
@property (nonatomic, retain) id extras;
@property (nonatomic, retain) NSString * special;
@property (nonatomic, retain) NSSet *referredToBy;
@property (nonatomic, retain) Content *category;
@property (nonatomic, retain) NSSet *helpsWithSymptoms;
@property (nonatomic, retain) Content *ref;
@property (nonatomic, retain) NSSet *helpFor;
@property (nonatomic, retain) NSSet *helpedBy;
@property (nonatomic, retain) NSSet *captions;
@property (nonatomic, retain) Content *help;
@property (nonatomic, retain) NSString * disposition;
@end

@interface Content (CoreDataGeneratedAccessors)

- (void)addReferredToByObject:(Content *)value;
- (void)removeReferredToByObject:(Content *)value;
- (void)addReferredToBy:(NSSet *)values;
- (void)removeReferredToBy:(NSSet *)values;

- (void)addHelpsWithSymptomsObject:(Content *)value;
- (void)removeHelpsWithSymptomsObject:(Content *)value;
- (void)addHelpsWithSymptoms:(NSSet *)values;
- (void)removeHelpsWithSymptoms:(NSSet *)values;

- (void)addHelpForObject:(Content *)value;
- (void)removeHelpForObject:(Content *)value;
- (void)addHelpFor:(NSSet *)values;
- (void)removeHelpFor:(NSSet *)values;

- (void)addHelpedByObject:(Content *)value;
- (void)removeHelpedByObject:(Content *)value;
- (void)addHelpedBy:(NSSet *)values;
- (void)removeHelpedBy:(NSSet *)values;

- (void)addCaptionsObject:(NSManagedObject *)value;
- (void)removeCaptionsObject:(NSManagedObject *)value;
- (void)addCaptions:(NSSet *)values;
- (void)removeCaptions:(NSSet *)values;

@end
