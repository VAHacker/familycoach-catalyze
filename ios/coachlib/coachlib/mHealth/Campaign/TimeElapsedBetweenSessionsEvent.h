//
//  Autogenerated... do not edit
//

#import "EventLog.h"
#import "EventRecord.h"

@interface TimeElapsedBetweenSessionsEvent : EventRecord {
	long long timeElapsedBetweenSessions;
}

+ (void)logWithTimeElapsedBetweenSessions:(long long)timeElapsedBetweenSessions;

@property (nonatomic, assign) long long timeElapsedBetweenSessions;

@end
