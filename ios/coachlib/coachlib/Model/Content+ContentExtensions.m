
#import "Content+ContentExtensions.h"
#import "ContentViewController.h"
#import "SymptomRef.h"
#import "ExerciseRef.h"
#import "iStressLessAppDelegate.h"

@implementation Content (ContentExtensions)

- (NSDictionary*) getExtrasDict {
	NSDictionary *dict = self.extras;
	return dict;
}

- (NSString*) getExtraString:(NSString*)key {
	NSDictionary *dict = [self getExtrasDict];
	if (!dict) return nil;
	return [dict valueForKey:key];
}

- (BOOL) getExtraBoolean:(NSString*)key {
	NSDictionary *dict = [self getExtrasDict];
	if (!dict) return FALSE;
	return [[dict valueForKey:key] isEqualToString:@"true"];
}

- (CGPoint) getExtraPoint:(NSString*)key {
	NSDictionary *dict = [self getExtrasDict];
	if (!dict) return CGPointMake(NAN,NAN);
    NSString *s = [dict valueForKey:key];
    NSArray *a = [s componentsSeparatedByString:@","];
    if (!a || (a.count != 2)) return CGPointMake(NAN,NAN);
    return CGPointMake([(NSString*)[a objectAtIndex:0] floatValue],[(NSString*)[a objectAtIndex:1] floatValue]);
}

- (SymptomRef*)refForSymptom {
    if (!self) return nil;
	NSManagedObjectContext *context = [iStressLessAppDelegate instance].udManagedObjectContext;
	NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"SymptomRef"];
	[fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"refID == %@", self.uniqueID]];
	NSArray *a = [context executeFetchRequest:fetchRequest error:NULL];
    return a.count ? [a objectAtIndex:0] : nil;
}

- (ExerciseRef*)refForExercise {
    if (!self) return nil;
	NSManagedObjectContext *context = [iStressLessAppDelegate instance].udManagedObjectContext;
	NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"ExerciseRef"];
	[fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"refID == %@", self.uniqueID]];
	NSArray *a = [context executeFetchRequest:fetchRequest error:NULL];
    return a.count ? [a objectAtIndex:0] : nil;
}

- (int) getExtraInt:(NSString*)key {
	NSString *str = [self getExtraString:(NSString *)key];
	if (!str) return INT_MAX;
	return [str intValue];
}

- (float) getExtraFloat:(NSString*)key withDefault:(float)defaultValue {
	NSString *str = [self getExtraString:(NSString *)key];
	if (!str) return defaultValue;
	return [str floatValue];
}

- (float) getExtraFloat:(NSString*)key {
    return [self getExtraFloat:key withDefault:NAN];
}

+(NSString*)contentPathForName:(NSString*)fn {
    if (!fn) return nil;
	NSArray *a = [fn componentsSeparatedByString:@"."];
	NSString *basename = [a objectAtIndex:0];
	NSString *ext = [a objectAtIndex:1];
	NSString *storePath = [[NSBundle mainBundle] pathForResource:basename ofType:ext inDirectory:@"Content"];
	return storePath;
}

-(NSMutableDictionary*) contentDescriptor {
    NSManagedObject *c = self;
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (c) {
        NSString *val;
        
        val = [c valueForKey:@"name"];
        if (val) [params setObject:val forKey:@"name"];
        val = [c valueForKey:@"displayName"];
        if (val) [params setObject:val forKey:@"displayName"];
        val = [c valueForKey:@"uniqueID"];
        if (val) [params setObject:val forKey:@"uniqueID"];
    }
    return params;
}

-(NSString*)contentPathForFile {
    return [Content contentPathForName:self.file];
}

+(NSData*)dataForName:(NSString*)fn {
	NSString *path = [Content contentPathForName:fn];
	return [NSData dataWithContentsOfFile:path];
}

- (NSArray*) getChildrenByName:(NSString*)name {
    if (!self.managedObjectContext) return [NSArray array];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Content" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchBatchSize:100];
	[fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"parent == %@ AND name == %@",self, name]];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES];
	NSArray * sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
	[sortDescriptor release];
	[sortDescriptors release];

	NSArray *a = [self.managedObjectContext executeFetchRequest:fetchRequest error:NULL];
	[fetchRequest release];
    return a;
}

-(Content*) getChildByName:(NSString*)name {
    if (!self.managedObjectContext) return nil;

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Content" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchLimit:1];
    [fetchRequest setFetchBatchSize:1];
	[fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"parent == %@ AND name == %@",self, name]];
	NSArray *a = [self.managedObjectContext executeFetchRequest:fetchRequest error:NULL];
	[fetchRequest release];
	if (a.count > 0) return [a objectAtIndex:0];
	return nil;
}

-(NSString*) getValueByName:(NSString*)name {
    Content *valueItem = [self getChildByName:name];
    if (!valueItem) return nil;
    return [valueItem getExtraString:@"value"];
}

-(float) getFloatValueByName:(NSString*)name withDefault:(float)defaultValue {
    NSString *valueStr = [self getValueByName:name];
    return valueStr ? defaultValue : [valueStr floatValue];
}

- (ContentViewController*) getViewController {

    Content* refContent = self.ref;
    if (refContent) return [refContent getViewController];

	NSString *uiClass = self.ui;
	if (uiClass == nil) uiClass = @"ContentViewController";
	ContentViewController *vc = [[[NSClassFromString(uiClass) alloc]init]autorelease];
    if (vc == nil) {
        NSLog(@"%@ not found",uiClass);
    }
	vc.content = self;
	return vc;
}

+(UIImage*)imageNamed:(NSString*)fn {
    UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"Content/%@",fn]];
    return image;
}

-(UIImage*)uiImage {
	NSString *imageFN = self.image;
	if (imageFN) {
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"Content/%@",imageFN]];
//		UIImage *image = [UIImage imageWithData:[self contentForName:imageFN]];
		return image;
	}
	return nil;
}

-(UIImage*)uiIcon {
	NSString *imageFN = self.icon;
	if (imageFN) {
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"Content/%@",imageFN]];
//		UIImage *image = [UIImage imageWithData:[self contentForName:imageFN]];
		return image;
	}
	return nil;
}

-(NSArray *)properChildren {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Content" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchBatchSize:1];
	[fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"parent == %@ AND !(name BEGINSWITH '@')",self]];

    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES];
	NSArray * sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
	[sortDescriptor release];
	[sortDescriptors release];

	NSArray *a = [self.managedObjectContext executeFetchRequest:fetchRequest error:NULL];
	[fetchRequest release];
	return a;
}
@end
