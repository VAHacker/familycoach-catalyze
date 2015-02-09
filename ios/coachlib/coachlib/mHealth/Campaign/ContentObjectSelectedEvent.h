//
//  Autogenerated... do not edit
//

#import "EventLog.h"
#import "EventRecord.h"

@interface ContentObjectSelectedEvent : EventRecord {
	NSString* contentObjectName;
	NSString* contentObjectDisplayName;
	NSString* contentObjectId;
}

+ (void)logWithContentObjectName:(NSString*)contentObjectName withContentObjectDisplayName:(NSString*)contentObjectDisplayName withContentObjectId:(NSString*)contentObjectId;

@property (nonatomic, retain) NSString* contentObjectName;
@property (nonatomic, retain) NSString* contentObjectDisplayName;
@property (nonatomic, retain) NSString* contentObjectId;

@end
