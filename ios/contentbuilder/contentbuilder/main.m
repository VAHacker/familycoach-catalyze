
#import <objc/objc-auto.h>
#import "ResourceParser.h"
#import <sys/stat.h>

NSManagedObjectModel *managedObjectModel();
NSManagedObjectContext *managedObjectContext();


int
timeval_subtract (result, x, y)
struct timespec *result, *x, *y;
{
    /* Perform the carry for the later subtraction by updating y. */
    if (x->tv_nsec < y->tv_nsec) {
        long long nsec = (y->tv_nsec - x->tv_nsec) / 1000000000 + 1;
        y->tv_nsec -= 1000000000 * nsec;
        y->tv_sec += nsec;
    }
    if (x->tv_nsec - y->tv_nsec > 1000000) {
        long long nsec = (x->tv_nsec - y->tv_nsec) / 1000000000;
        y->tv_nsec += 1000000000 * nsec;
        y->tv_sec -= nsec;
    }
    
    /* Compute the time remaining to wait.
     tv_nsec is certainly positive. */
    result->tv_sec = x->tv_sec - y->tv_sec;
    result->tv_nsec = x->tv_nsec - y->tv_nsec;
    
    /* Return 1 if result is negative. */
    return x->tv_sec < y->tv_sec;
}

int main (int argc, const char * argv[]) {

    NSString* xmlFile = [[[NSProcessInfo processInfo] arguments] objectAtIndex:1];
    NSString* dbFile = [[[NSProcessInfo processInfo] arguments] objectAtIndex:2];
    NSString* contentSrcDir = [[[NSProcessInfo processInfo] arguments] objectAtIndex:3];
    NSString* contentDstDir = [[[NSProcessInfo processInfo] arguments] objectAtIndex:4];

    NSLog(@"Building %@ to %@",xmlFile,dbFile);

    struct stat xmlStat;
    struct stat dbStat;
    struct timespec result;

    stat([xmlFile UTF8String],&xmlStat);
    stat([dbFile UTF8String],&dbStat);
    
    if (timeval_subtract(&result, &xmlStat.st_mtimespec,&dbStat.st_mtimespec) == 1) {
        stat([contentSrcDir UTF8String],&xmlStat);
        stat([contentDstDir UTF8String],&dbStat);
        if (timeval_subtract(&result, &xmlStat.st_mtimespec,&dbStat.st_mtimespec) == 1) {
            NSLog(@"No work to do");
            exit(0);
        }
    }
    
	// Create the managed object context
    NSManagedObjectContext *context = managedObjectContext();
    
	ResourceParser *parser = [[ResourceParser alloc] init];
    parser.contentSrcDir = contentSrcDir;
    parser.contentDstDir = contentDstDir;
	[parser convertFile:xmlFile into:context];
    [parser release];
    
	// Save the managed object context
    NSError *error = nil;
	[context commitEditing];
    if (![context save:&error]) {
        NSLog(@"Error while saving\n%@",
              ([error localizedDescription] != nil) ? [error localizedDescription] : @"Unknown Error");
        exit(1);
    }
    
    [[NSFileManager defaultManager] removeItemAtPath:contentDstDir error:NULL];
    [[NSFileManager defaultManager] moveItemAtPath:[contentDstDir stringByAppendingPathExtension:@"tmp"] toPath:contentDstDir error:NULL];

    [[NSFileManager defaultManager] removeItemAtPath:dbFile error:NULL];
    [[NSFileManager defaultManager] moveItemAtPath:[dbFile stringByAppendingPathExtension:@"tmp"] toPath:dbFile error:NULL];

    return 0;
}

NSManagedObjectModel *managedObjectModel() {
    
    static NSManagedObjectModel *model = nil;
    
    if (model != nil) {
        return model;
    }
    
	NSString *path = [[[NSProcessInfo processInfo] arguments] objectAtIndex:0];
	path = [path stringByDeletingLastPathComponent];
    NSLog(@"Looking for model in %@\n",path);
	NSURL *modelURL = [NSURL fileURLWithPath:[path stringByAppendingPathComponent:@"coachlib.momd/coachlib.mom"]];
    model = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    NSLog(@"Found model at %@\n",model);
    
    return model;
}

NSManagedObjectContext *managedObjectContext() {
	
    static NSManagedObjectContext *context = nil;
    if (context != nil) {
        return context;
    }
    
    context = [[NSManagedObjectContext alloc] init];
    
    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: managedObjectModel()];
    [context setPersistentStoreCoordinator: coordinator];
    
    NSString *STORE_TYPE = NSSQLiteStoreType;
	
	NSString *path = [[[NSProcessInfo processInfo] arguments] objectAtIndex:2];
    path = [path stringByAppendingPathExtension:@"tmp"];
	NSURL *url = [NSURL fileURLWithPath:path];
	[[NSFileManager defaultManager] removeItemAtURL:url error:NULL];
    
	NSError *error;
    NSPersistentStore *newStore = [coordinator addPersistentStoreWithType:STORE_TYPE configuration:nil URL:url
                                                                  options:@{NSSQLitePragmasOption: @{@"journal_mode":@"DELETE"}} error:&error];
    [coordinator release];

    if (newStore == nil) {
        NSLog(@"Store Configuration Failure\n%@",
              ([error localizedDescription] != nil) ?
              [error localizedDescription] : @"Unknown Error");
    }
    
    return context;
}

