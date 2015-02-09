//
//  Goal.h
//  coachlib
//
//  Copyright (c) 2013 Department of Veteran's Affairs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Goal;

@interface Goal : NSManagedObject

@property (nonatomic, retain) NSString * displayName;
@property (nonatomic, retain) NSNumber * ordering;
@property (nonatomic, retain) NSString * notes;
@property (nonatomic, retain) NSNumber * level;
@property (nonatomic, retain) NSNumber * expanded;
@property (nonatomic, retain) NSNumber * doneState;
@property (nonatomic, retain) NSString * alarmID;
@property (nonatomic, retain) NSDate * dueDate;
@property (nonatomic, retain) Goal *parent;
@property (nonatomic, retain) NSOrderedSet *children;
@end

@interface Goal (CoreDataGeneratedAccessors)

- (void)insertObject:(Goal *)value inChildrenAtIndex:(NSUInteger)idx;
- (void)removeObjectFromChildrenAtIndex:(NSUInteger)idx;
- (void)insertChildren:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeChildrenAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInChildrenAtIndex:(NSUInteger)idx withObject:(Goal *)value;
- (void)replaceChildrenAtIndexes:(NSIndexSet *)indexes withChildren:(NSArray *)values;
- (void)addChildrenObject:(Goal *)value;
- (void)removeChildrenObject:(Goal *)value;
- (void)addChildren:(NSOrderedSet *)values;
- (void)removeChildren:(NSOrderedSet *)values;
@end
