
#import "iStressLessAppDelegate.h"
#import "Reminder+ReminderExtensions.h"

@implementation Reminder (ReminderExtensions)

- (Content*) referencedContent {
    NSLog(@"%@",self);
    NSManagedObjectContext *ctx = [iStressLessAppDelegate instance].managedObjectContext;
    NSFetchRequest *req = [NSFetchRequest fetchRequestWithEntityName:@"Content"];
    req.predicate = [NSPredicate predicateWithFormat:@"uniqueID == %@",self.reference];
    req.fetchLimit = 1;
    NSArray *a = [ctx executeFetchRequest:req error:NULL];
    if (a.count) return [a objectAtIndex:0];
    return nil;
}

@end
