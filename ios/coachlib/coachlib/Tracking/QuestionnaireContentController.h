//
//  TrackingTopView.h
//  iStressLess
//


//

#import <UIKit/UIKit.h>
#import "ContentViewController.h"
#import "NavController.h"

@interface QuestionnaireContentController : NavController {
}

+ (NSDate*)getLastTimeSeriesTime:(NSString*)series;
+ (NSManagedObject*)getLastTimeSeriesEntry:(NSString*)series;
+ (NSArray*)getTimeSeriesHistory:(NSString*)series withMaxCount:(int)count;
+ (void) scheduleAssessmentReminderFor:(NSString*)series atInterval:(NSString*)interval andUserInfo:(NSDictionary*)dict;
+(NSDate*) addDelta:(NSString*)interval toDate:(NSDate*)lastTime;

@end
