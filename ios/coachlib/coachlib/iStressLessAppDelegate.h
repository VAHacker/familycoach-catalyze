//
//  iStressLessAppDelegate.h
//  iStressLess
//


//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <EventKit/EventKit.h>
#import "ContentListViewController.h"
#import "ButtonGridController.h"
#import "ContentViewController.h"
#import "LoginView.h"
#import "EventLog.h"
#import "Reachability.h"

#define BUILD_DEMO 0

@interface iStressLessAppDelegate : NSObject <UIApplicationDelegate,UIAlertViewDelegate> {
    
    UIApplication *app;
    UIWindow *window;
	UIWindow *offscreenWindow;
    UIViewController *topController;
    ContentViewController *rootController;
	UIImageView *splashScreen;
    UILocalNotification *localNotif;
    LoginView *loginView;
    
    NSMutableArray *rootList;
    NSMutableArray *tabList;
	
@private
    EventLog *eventLog;
    NSDate *startTime;
    NSDate *activeSince;
    NSDateFormatter *dateFormatter;
    NSString *attemptUsername;
    NSString *attemptPassword;
    BOOL testCodeRan;
    BOOL recreateRefs;
    
    NSPersistentStoreCoordinator *tempPersistentStoreCoordinator_;
    NSManagedObjectContext *udManagedObjectContext_;
    NSManagedObjectModel *udManagedObjectModel_;
    NSPersistentStoreCoordinator *udPersistentStoreCoordinator_;
    NSManagedObjectContext *managedObjectContext_;
    NSManagedObjectModel *managedObjectModel_;
    NSPersistentStoreCoordinator *persistentStoreCoordinator_;
	BOOL createdUserDataForFirstTime;
    
    NSMutableDictionary *globalVariables;
    EKEventStore *_eventStore;
    const ABAddressBookRef *_addressBook;
    
    UIViewController *currentModal;
    void (^calendarFetchBlock)(EKCalendar *calendar);
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) UIWindow *offscreenWindow;
@property (nonatomic, readonly) ABAddressBookRef sharedAddressBook;

//@property (nonatomic, retain) ContentViewController *topController;

@property (nonatomic, retain) NSMutableArray *tabList;
@property (nonatomic, retain) NSMutableArray *rootList;

@property (nonatomic, retain) UILocalNotification *pendingNotification;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain, readonly) NSManagedObjectContext *udManagedObjectContext;
@property (nonatomic, retain, readonly) NSManagedObjectModel *udManagedObjectModel;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *tempPersistentStoreCoordinator;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *udPersistentStoreCoordinator;
@property (nonatomic, retain, readonly) EKEventStore *eventStore;

@property (nonatomic, retain, readonly) NSMutableDictionary *globalVariables;

+ (int) deviceMajorVersion;
+ (iStressLessAppDelegate*) instance;
- (NSString *)applicationDocumentsDirectory;

- (void)presentModalViewController:(UIViewController *)modalViewController animated:(BOOL)animated;

- (BOOL)navigateToContent:(Content *)content;
- (BOOL)navigateToContent:(Content *)content withData:(NSDictionary*)data;
- (ContentViewController*)getContentControllerWithName:(NSString*)name;
- (ContentViewController*)getContentControllerForObject:(NSManagedObject*)mo;
- (ContentViewController*)getContentControllerForObject:(NSManagedObject*)mo withDefaultUI:(NSString*)defaultUIClass;

-(void)rescheduleLocalNotification:(UILocalNotification*)n;
-(UILocalNotification*)getLocalNotificationWithID:(NSString*)notificationID;

-(void)passCalendarForEventsFor:(ContentViewController*)parentCVC to:(void (^)(EKCalendar *calendar))block;
-(void)passCalendarForEventsFor:(ContentViewController*)parentCVC afterAskingForWhichCalendar:(BOOL)ask to:(void (^)(EKCalendar *calendar))block ;

- (Item*)getItemWithName:(NSString*)name ;
- (Content*)getContentWithName:(NSString*)name;
- (NSString*)getContentTextWithName:(NSString*)name;

- (NSString*)getSetting:(NSString *)name;
- (void)setSetting:(NSString *)name to:(NSString*)value;

- (void) resetApp;
- (void) resetTools;

- (void)preloadContentViewFor:(ContentViewController*)cvc andThenRunBlock:(void(^)())block;

-(void)attemptLoginWithUsername:(NSString*)username andPassword:(NSString*)password;
-(void)logout;
-(void)logoutAndReset;

@end

