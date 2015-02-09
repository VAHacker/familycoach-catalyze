//
//  ExerciseRef.m
//  coachlib
//
//  Copyright (c) 2012 Department of Veteran's Affairs. All rights reserved.
//

#import "ExerciseRef.h"
#import "SymptomRef.h"
#import "iStressLessAppDelegate.h"

@implementation ExerciseRef

@dynamic sectionName;
@dynamic displayName;
@dynamic inFavoriteList;
@dynamic isCategory;
@dynamic negativeScore;
@dynamic positiveScore;
@dynamic weight;
@dynamic refID;
@dynamic categoryRefID;
@dynamic addressable;
@dynamic parent;
@dynamic sectionOrder;
@dynamic childCount;
@dynamic helpsWithSymptoms;

-(Content*)ref {
    NSManagedObjectContext *context = [iStressLessAppDelegate instance].managedObjectContext;
    NSString *oidStr = self.refID;
    if (self.isCategory.boolValue) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:[NSEntityDescription entityForName:@"ExerciseCategory" inManagedObjectContext:context]];
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"uniqueID == %@",oidStr]];
        [fetchRequest setFetchLimit:1];
        NSArray *a = [context executeFetchRequest:fetchRequest error:NULL];
        [fetchRequest release];
        if (!a || !a.count) return nil;
        return [a objectAtIndex:0];
    } else {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:[NSEntityDescription entityForName:@"Content" inManagedObjectContext:context]];
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"uniqueID == %@",oidStr]];
        [fetchRequest setFetchLimit:1];
        NSArray *a = [context executeFetchRequest:fetchRequest error:NULL];
        [fetchRequest release];
        if (!a || !a.count) return nil;
        return [a objectAtIndex:0];
    }
}

@end
