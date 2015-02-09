//
//  ExerciseScore.h
//  coachlib
//
//  Copyright (c) 2012 Department of Veteran's Affairs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ExerciseScore : NSManagedObject

@property (nonatomic, retain) NSNumber * isCategory;
@property (nonatomic, retain) NSString * displayName;
@property (nonatomic, retain) NSString * parentDisplayName;
@property (nonatomic, retain) NSString * refID;
@property (nonatomic, retain) NSNumber * inFavoriteList;
@property (nonatomic, retain) NSNumber * positiveScore;
@property (nonatomic, retain) NSNumber * negativeScore;
@property (nonatomic, retain) NSString * parentRefID;
@property (nonatomic, retain) NSString * sectionName;

@end
