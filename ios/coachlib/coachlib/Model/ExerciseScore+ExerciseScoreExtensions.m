
#import "ExerciseScore+ExerciseScoreExtensions.h"
#import "Content+ContentExtensions.h"

@implementation ExerciseScore (ExerciseScoreExtensions)

-(Content*) getChildByName:(NSString*)name {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Content" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchBatchSize:1];
	[fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"parent == %@ AND name == %@",self, name]];
	NSArray *a = [self.managedObjectContext executeFetchRequest:fetchRequest error:NULL];
	[fetchRequest release];
	if (a.count > 0) return [a objectAtIndex:0];
	return nil;
}


@end
