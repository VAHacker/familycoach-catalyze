//
//  iStressLess_Desktop_AppDelegate.h
//  iStressLess Desktop
//


//

#import <Cocoa/Cocoa.h>

@interface ResourceParser : NSObject<NSXMLParserDelegate> 
{
	NSXMLParser *parser;
	NSMutableArray *stack;
	int orderIndexStack[64];
	int stackDepth;
	
	NSManagedObjectContext *managedObjectContext;
    
    NSString *contentSrcDir;
    NSString *contentDstDir;
    NSMutableSet *contentFiles;    
}

@property (nonatomic, retain) NSString * contentSrcDir;
@property (nonatomic, retain) NSString * contentDstDir;

- (void)convertFile:(NSString*)xmlFilename into:(NSManagedObjectContext*)context;

@end
