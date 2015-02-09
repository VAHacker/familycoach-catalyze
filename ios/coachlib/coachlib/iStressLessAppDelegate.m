//
//  iStressLessAppDelegate.m
//  iStressLess
//


//

#import "iStressLessAppDelegate.h"
#import "ManageSymptomsNavController.h"
#import "ContentListViewController.h"
#import "MediaPlayer/MediaPlayer.h"
#import "Flurry.h"
#import "EventLog.h"
#import "UIKit/UIAccessibility.h"
#import "mHealth/Campaign/VaPtsdExplorerCampaign.h"
#import "LoginView.h"
#import "AssessNavigationController.h"
#import "CCAlertView.h"
#import "OpenMHealthSession.h"
#import "Content+ContentExtensions.h"
#import "ExerciseRef.h"
#import "SymptomRef.h"
#import "GWebView.h"
#import "UIAlertView+MKBlockAdditions.h"
#import "SymptomTrigger.h"
#import "CopingTechnique.h"
#import "Goal.h"
#import "ThemeManager.h"
#import "BackedQueue.h"

@implementation iStressLessAppDelegate

@synthesize window;
@synthesize offscreenWindow;
@synthesize tabList;
@synthesize rootList;
@synthesize globalVariables;

static int sDeviceMajorVersion;
static iStressLessAppDelegate* delegateInstance;

#pragma mark -
#pragma mark Application lifecycle

#ifdef EXPLORER
#define REQUIRE_LOGIN 1
#else
#define REQUIRE_LOGIN 0
#endif

- (void)awakeFromNib {    
	delegateInstance = self;
    globalVariables = [[NSMutableDictionary alloc] init];
}

-(void) doAssessmentOnLaunch {
    Content *c = [self getContentWithName:@"takeAssessment"];
    [self navigateToContent:c];
}

-(void) application:(UIApplication *)application fakeDidReceiveLocalNotification:(UILocalNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    NSString *contentName = [userInfo valueForKey:@"destination"];
    Content *c = [self getContentWithName:contentName];
    if (c) [self navigateToContent:c];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 1) {
        [self application:[UIApplication sharedApplication] fakeDidReceiveLocalNotification:self.pendingNotification];
        self.pendingNotification = nil;
    }
}

-(void) application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    UIApplicationState state = [application applicationState];
    if (state == UIApplicationStateInactive) {
        // Application was in the background when notification was delivered.
        [self application:application fakeDidReceiveLocalNotification:notification];
    } else {
        self.pendingNotification = notification;
        NSString *title = [[[NSBundle mainBundle] infoDictionary]   objectForKey:@"CFBundleName"];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:notification.alertBody delegate:self cancelButtonTitle:@"Close" otherButtonTitles:notification.alertAction,nil];
        [alert show];
        [alert release];
    }

//    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
}

- (void)showLogin {
    if (!loginView) {
        loginView = [[LoginView alloc] initWithNibName:@"LoginView" bundle:[NSBundle mainBundle]];
        window.rootViewController = loginView;
        if (splashScreen) {
            [splashScreen removeFromSuperview];
            [window addSubview:splashScreen];
        }
    }
}
/*
- (void)showEULA {
    [topController view];
    ContentViewController *vc = [self getContentControllerWithName:@"EULA"];
//    GNavigationController *homeNavController = [topController.viewControllers objectAtIndex:0];
    GNavigationController *navController = [[GNavigationController alloc] initWithRootViewController:vc];
//    navController.navigationBar.tintColor = homeNavController.navigationBar.tintColor;

    vc.contentLoadedBlock = ^{
        offscreenWindow.rootViewController = nil;
        window.rootViewController = navController;
        if (splashScreen) {
            [splashScreen removeFromSuperview];
            [navController.view addSubview:splashScreen];
        }
        [navController release];
    };
    
    [vc view];
    offscreenWindow.rootViewController = navController;
    [window addSubview:splashScreen];
}

- (void)showIntro {
    [topController view];
    ContentViewController *vc = [self getContentControllerWithName:@"firstLaunch"];
//    GNavigationController *homeNavController = [topController.viewControllers objectAtIndex:0];
    GNavigationController *navController = [[GNavigationController alloc] initWithRootViewController:vc];
//    navController.navigationBar.tintColor = homeNavController.navigationBar.tintColor;
    [vc addButtonWithText:@"Skip Setup" callingBlock:^(UIButton *button) {
        [UIView transitionFromView:navController.view toView:topController.view duration:0.5 options:UIViewAnimationOptionTransitionFlipFromLeft completion:nil];
        [self setSetting:@"firstLaunch" to:@"yes"];
    }];
    [vc addButtonWithText:@"Continue with Setup" callingBlock:^(UIButton *button) {
        [UIView transitionFromView:navController.view toView:topController.view duration:0.5 options:UIViewAnimationOptionTransitionFlipFromLeft completion:nil];
//        [homeController showSetupAnimated:FALSE];
        [self setSetting:@"firstLaunch" to:@"yes"];
    }];
    
    vc.contentLoadedBlock = ^{
        offscreenWindow.rootViewController = nil;

        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.5];
        [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:window cache:YES];
        [UIView setAnimationDelegate:self];
        window.rootViewController = navController;
        [UIView commitAnimations];
        
        [navController release];
    };
    
    [vc view];
    offscreenWindow.rootViewController = navController;
}
*/
- (NSString*)getFlurryID {
    return [[ThemeManager sharedManager] stringForName:@"flurryID"];
}

- (NSString*)getHockeyAppIdentifier {
  return [[ThemeManager sharedManager] stringForName:@"hockeyAppIdentifier"];
}

- (void) finishInit {
    if (window.rootViewController == loginView) {
/*
        BOOL isFirstLaunch = FALSE;
        NSString *firstLaunchSetting = [self getSetting:@"firstLaunch"];
        if (!firstLaunchSetting || ![firstLaunchSetting isEqual:@"yes"]) {
            isFirstLaunch = TRUE;
            [self showEULA];
        }
*/
    }
    
	app.applicationIconBadgeNumber = 0;
    if (localNotif) {
		[self application:(UIApplication *)app fakeDidReceiveLocalNotification:localNotif];
        [localNotif release];
        localNotif = nil;
    }
 
    if (loginView) {
        [loginView release];
        loginView = nil;
    }
/*    
    if (!testCodeRan) {
        UILocalNotification *n = [[UILocalNotification alloc] init];
        n.fireDate = [[NSDate date] dateByAddingTimeInterval:10];
        n.timeZone = [NSTimeZone defaultTimeZone];
        n.alertBody = @"You have a PTSD Explorer assessment due.  Take it now?";
        n.alertAction = @"Do it";
        n.soundName = UILocalNotificationDefaultSoundName;
        n.applicationIconBadgeNumber = 1;
        n.repeatInterval = NSDayCalendarUnit;    
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
        [[UIApplication sharedApplication] scheduleLocalNotification:n];
        testCodeRan = TRUE;
    }
*/ 
}

- (BOOL)navigateToContent:(Content *)content {
    return [self navigateToContent:content withData:nil];
}

- (BOOL)navigateToContent:(Content *)content withData:(NSDictionary*)data {
    NSMutableArray *path = [NSMutableArray array];
    Content *parent = (Content*)content.parent;
    [path insertObject:content atIndex:0];
    while (parent && (parent != rootController.content)) {
        [path insertObject:parent atIndex:0];
        parent = (Content*)parent.parent;
    }
    
    return [rootController navigateToContentWithPath:path startingAt:0 withData:data];
}

- (void)startSession {
    [startTime release];
    startTime = [NSDate date];
    [startTime retain];

    [AppLaunchedEvent logWithAccessibilityFeaturesActiveOnLaunch:UIAccessibilityIsVoiceOverRunning()];

    NSString *lastSessionEndTimeStr = [self getSetting:@"lastSessionEndTime"];
    NSDate *lastSessionEndTime = lastSessionEndTimeStr ? [dateFormatter dateFromString:lastSessionEndTimeStr] : nil;
    if (lastSessionEndTime) {
        NSTimeInterval interval = [startTime timeIntervalSinceDate:lastSessionEndTime];
        long long intervalInMillis = interval * 1000LL;
        [TimeElapsedBetweenSessionsEvent logWithTimeElapsedBetweenSessions:intervalInMillis];
    }
    
    [self setSetting:@"lastSessionStartTime" to:[dateFormatter stringFromDate:startTime]];
    
    activeSince = [NSDate date];
    [activeSince retain];
}

-(void) endSession {
    
    [self setSetting:@"lastSessionEndTime" to:[dateFormatter stringFromDate:[NSDate date]]];

    if (activeSince) {
        NSString *intervalStr = [self getSetting:@"totalUptime"];
        long long intervalInMillis = intervalStr ? [intervalStr longLongValue] : 0;
        
        NSTimeInterval interval = -[activeSince timeIntervalSinceNow];
        intervalInMillis += interval * 1000LL;
        
        NSString *uptimeStr = [NSString stringWithFormat:@"%lld",intervalInMillis];
        [TotalTimeOnAppEvent logWithTotalTimeOnApp:intervalInMillis];
        [self setSetting:@"totalUptime" to:uptimeStr];
        
        [activeSince release];
        activeSince = nil;
    }

    [AppExitedEvent logWithAppExitedAccessibilityFeaturesActive:UIAccessibilityIsVoiceOverRunning()];
}

-(void)dismissCalendarPickerModal {
    NSString *calID = [self getSetting:@"eventCalendar"];
    if (!calID) {
        [UIAlertView alertViewWithTitle:@"No Calendar Selected" message:@"You haven't chosen a calendar.  Are you sure you don't wish to choose a calendar for PTSD Coach events?" cancelButtonTitle:@"Oops" otherButtonTitles:@[@"I'm sure"] onDismiss:^(int buttonIndex) {
            [currentModal.presentingViewController dismissViewControllerAnimated:TRUE completion:^{
                calendarFetchBlock(nil);
                [calendarFetchBlock release];
                calendarFetchBlock = nil;
            }];
        } onCancel:NULL];
    } else {
        [currentModal.presentingViewController dismissViewControllerAnimated:TRUE completion:^{
            EKCalendar *cal = [self.eventStore calendarWithIdentifier:calID];
            calendarFetchBlock(cal);
            [calendarFetchBlock release];
            calendarFetchBlock = nil;
        }];
    }

}

- (void)presentModalViewController:(UIViewController *)modalViewController animated:(BOOL)animated {
    UIViewController *c = self.window.rootViewController;
    while ([c presentedViewController]) {
        c = [c presentedViewController];
    }
    [c presentModalViewController:modalViewController animated:animated];
}

-(void)passCalendarForEventsFor:(ContentViewController*)parentCVC to:(void (^)(EKCalendar *calendar))block {
    [self passCalendarForEventsFor:parentCVC afterAskingForWhichCalendar:TRUE to:block];
}

-(void)passCalendarForEventsFor:(ContentViewController*)parentCVC afterAskingForWhichCalendar:(BOOL)ask to:(void (^)(EKCalendar *calendar))block {
    EKEventStore *eventStore = self.eventStore;

    void (^blockCopy)(EKCalendar *calendar) = [block copy];
    
    VoidBlock completion = ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (ask) {
                NSString *calID = [self getSetting:@"eventCalendar"];
                if (calID) {
                    EKCalendar *cal = [eventStore calendarWithIdentifier:calID];
                    if (cal) {
                        blockCopy(cal);
                        [blockCopy release];
                        return;
                    }
                }
                
                ContentViewController *cvc = [self getContentControllerWithName:@"pickCalendar"];
                GNavigationController *nc = [[GNavigationController alloc] initWithRootViewController:cvc];
                cvc.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissCalendarPickerModal)];
                
                calendarFetchBlock = blockCopy;
                currentModal = nc;
                [window.rootViewController presentViewController:nc animated:TRUE completion:NULL];
            } else {
                EKCalendar *cal = [eventStore defaultCalendarForNewEvents];
                blockCopy(cal);
                [blockCopy release];
                return;
            }
        });
    };
    
    if ([eventStore respondsToSelector:@selector(requestAccessToEntityType:completion:)]) {
        VoidBlock completionCopy = [completion copy];
        [eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
            if (!granted) {
                blockCopy(nil);
                [blockCopy release];
                return;
            }
            
            completionCopy();
            [completionCopy release];
        }];
    } else {
        completion();
    }
}

-(EKEventStore *)eventStore {
    if (!_eventStore) {
        _eventStore = [[EKEventStore alloc] init];
    }
    return _eventStore;
}

- (void) initSettings {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Setting"];
	NSArray *a = [self.udManagedObjectContext executeFetchRequest:fetchRequest error:NULL];
    
    for (NSManagedObject *o in a) {
        NSString *name = [o valueForKey:@"name"];
        NSString *value = [o valueForKey:@"value"];
        if (value) {
            [globalVariables setObject:[[value copy] autorelease] forKey:name];
        } else {
            [globalVariables removeObjectForKey:name];
        }
    }

    NSString *timeOfDayStr = [[iStressLessAppDelegate instance] getSetting:@"assessmentTimeOfDay"];
    if (!timeOfDayStr) {
        [[iStressLessAppDelegate instance] setSetting:@"assessmentTimeOfDay" to:@"9:00PM"];
        [[iStressLessAppDelegate instance] setSetting:@"assessmentDayOfWeek" to:@"1"];
    }
}

- (ABAddressBookRef)sharedAddressBook {
    if (!_addressBook) {
        _addressBook = (ABAddressBookRef)ABAddressBookCreate();
    }
    return _addressBook;
}

void uncaughtExceptionHandler(NSException *exception) {
//    [Flurry logError:@"Uncaught" message:@"Crash!" exception:exception];
    NSLog(@"CRASH: %@", exception);
    NSLog(@"Stack Trace: %@", [exception callStackSymbols]);
    // Internal error reporting
}

NSUInteger DeviceSystemMajorVersion() {
    static NSUInteger _deviceSystemMajorVersion = -1;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        NSString *systemVersion = [UIDevice currentDevice].systemVersion;
        _deviceSystemMajorVersion = [[systemVersion componentsSeparatedByString:@"."][0] intValue];
    });
    
    return _deviceSystemMajorVersion;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
    NSString *flurryID = [self getFlurryID];
	if (flurryID) [Flurry startSession:flurryID];


  // If we're using the HockeyApp framework for test deployment, then initialize it.
  Class hockeyKlass = NSClassFromString(@"BITHockeyManager");
  if (hockeyKlass) {
    NSString *hockeyAppIdentifier = [self getHockeyAppIdentifier];
    hockeyAppIdentifier = @"207a5b3accfffb500492d2e8aef37ece";
    
    if (hockeyAppIdentifier) {
      if ([hockeyKlass respondsToSelector:@selector(sharedHockeyManager)]) {
        id hockeyManager = [hockeyKlass performSelector:@selector(sharedHockeyManager)];
        
        [hockeyManager performSelector:@selector(configureWithIdentifier:) withObject:hockeyAppIdentifier];
        [hockeyManager performSelector:@selector(startManager)];

        id hockeyManagerAuthenticator = [hockeyManager performSelector:@selector(authenticator)];
        [hockeyManagerAuthenticator performSelector:@selector(authenticateInstallation)];
      }
    }
  }

    sDeviceMajorVersion = DeviceSystemMajorVersion();
    /*
    OpenMHealthSession *session = [[OpenMHealthSession alloc] init];
    [session open];
    */

    Campaign *campaign = [[VaPtsdExplorerCampaign alloc] init];
    eventLog = [[EventLog alloc] initForCampaign:campaign];
    [campaign release];

    testCodeRan = FALSE;
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    startTime = [NSDate date];
    [startTime retain];
            
    app = application;
    [app retain];
	localNotif = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    [localNotif retain];
	createdUserDataForFirstTime = FALSE;

    [self initSettings];
    
    application.statusBarStyle = UIStatusBarStyleBlackOpaque;
    UIScreen* mainscr = [UIScreen mainScreen];
    CGSize screenSize = mainscr.currentMode.size;

	UIImage *splash = nil;
    if (screenSize.height > 960) {
        splash = [UIImage imageNamed:@"Default-568h@2x.png"];
        splashScreen = [[UIImageView alloc] initWithImage:splash];
        splashScreen.contentScaleFactor = 2;
    } else {
        splash = [UIImage imageNamed:@"Default.png"];
        splashScreen = [[UIImageView alloc] initWithImage:splash];
    }
    
    splashScreen.contentMode = UIViewContentModeBottom;
	
	delegateInstance = self;
	window.backgroundColor = [UIColor blackColor];
	
	srand(CFAbsoluteTimeGetCurrent());

	offscreenWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];

    CGRect screenBounds = window.bounds;
    topController = [[UIViewController alloc] init];
    CGRect r = [UIScreen mainScreen].applicationFrame;
    topController.view.frame = r;
    window.rootViewController = topController;
    float offsetY = r.origin.y;
    if ([iStressLessAppDelegate deviceMajorVersion] < 7) {
        screenBounds.origin.y -= offsetY;
    }
    splashScreen.frame = screenBounds;
    [topController.view addSubview:splashScreen];

    if (REQUIRE_LOGIN) {
        attemptUsername = [self getSetting:@"ohmage_username"];
        [attemptUsername retain];
        attemptPassword = [self getSetting:@"ohmage_password"];
        [attemptPassword retain];
        [self attemptLogin];
    } else {
        [self finishInit];
    }

    BOOL isFirstLaunch = FALSE;
    //NSString *firstLaunchSetting = [self getSetting:@"firstLaunch"];
    isFirstLaunch = FALSE;

	NSDate *fadeTime = [[NSDate date] dateByAddingTimeInterval:(isFirstLaunch ? 3 : 1)];

    [GWebView initScriptEngineAndThen:^{
        Content *rootContent = [self getContentWithName:@"ROOT"];
        CGRect r = topController.view.bounds;
//        r.origin.y += 20;
//        r.size.height -= 20;
        rootController = [[rootContent getViewController] retain];
        rootController.view.frame = r;
        [topController.view insertSubview:rootController.view belowSubview:splashScreen];
        [topController addChildViewController:rootController];
        rootController.contentVisible = TRUE;
        
        NSTimeInterval interval = [fadeTime timeIntervalSinceNow];
        if (interval <= 0) {
            [self startupTimer];
        } else {
            [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(startupTimer) userInfo:nil repeats:NO];
        }
    }];
    
//    window.rootViewController = topController;
    [window makeKeyAndVisible];

    return YES;
}

-(UILocalNotification*)getLocalNotificationWithID:(NSString*)notificationID {
    for (UILocalNotification *old in [UIApplication sharedApplication].scheduledLocalNotifications) {
        NSDictionary *oldUserInfo = old.userInfo;
        NSString *oldID = [oldUserInfo objectForKey:@"id"];
        if ([oldID isEqualToString:notificationID]) {
            return old;
        }
    }
    
    return nil;
}

-(void)rescheduleLocalNotification:(UILocalNotification*)n {
    NSDictionary *userInfo = n.userInfo;
    NSString *notificationID = [userInfo objectForKey:@"id"];
    UILocalNotification *old = [self getLocalNotificationWithID:notificationID];
    if (old) {
        [[UIApplication sharedApplication] cancelLocalNotification:old];
    }
    
    [[UIApplication sharedApplication] scheduleLocalNotification:n];
}

-(void)attemptLogin {
    if (!attemptUsername || !attemptPassword) {
        [self showLogin];
    } else {
        [eventLog setUsername:attemptUsername andPassword:attemptPassword];
        [eventLog tryLogin];
    }
}

-(void)logout {
    [self setSetting:@"ohmage_username" to:nil];
    [self setSetting:@"ohmage_password" to:nil];    
    [self applicationWillTerminate:app];
    exit(0);
}

-(void)logoutAndReset {
	NSArray *searchPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentFolderPath = [searchPaths objectAtIndex:0];
	NSString *storePath = [documentFolderPath stringByAppendingPathComponent:@"userdata.db"];

	[[NSFileManager defaultManager] removeItemAtPath:storePath error:NULL];

    exit(0);
}

-(void)loginSucceeded {
    [self setSetting:@"ohmage_username" to:attemptUsername];
    [self setSetting:@"ohmage_password" to:attemptPassword];
    [self finishInit];
}

-(void)loginFailed:(NSString*)msg {
    if (msg == NetworkConnectivityErrorMsg) {
        if (window.rootViewController != loginView) {
            // If we are already past the login view, and the error is simple connectivity issues, ignore it
            NSLog(@"Ignoring connectivity problem and allowing offline usage with cached login");
            return;
        }
    }
    
    if (!loginView) {
    }
    
    [loginView reset];
    CCAlertView *alert = [[CCAlertView alloc] initWithTitle:@"Login Error" message:msg];
    [alert addButtonWithTitle:@"Ok" block:^{ 
        if (!loginView) {
            [self setSetting:@"ohmage_username" to:nil];
            [self setSetting:@"ohmage_password" to:nil];    
            [self applicationWillTerminate:app];
            exit(0);
        }
    }];
    [alert show];
    [alert release];
}

-(void)attemptLoginWithUsername:(NSString*)username andPassword:(NSString*)password {
    [attemptUsername release];
    attemptUsername = username;
    [attemptUsername retain];
    
    [attemptPassword release];
    attemptPassword = password;
    [attemptPassword retain];

    return [self attemptLogin];
}

-(void)fadeFinished {
	[splashScreen removeFromSuperview];
	[splashScreen release];
	splashScreen = nil;
    if ([window.rootViewController respondsToSelector:@selector(username)]) {
        [[(LoginView*)window.rootViewController username] becomeFirstResponder];
    }
}

-(void) startupTimer {
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:1];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(fadeFinished)];
	splashScreen.alpha = 0;
	[UIView commitAnimations];
}

- (void)preloadContentViewFor:(ContentViewController*)cvc andThenRunBlock:(void(^)())block {
	[cvc view];
	cvc.contentLoadedBlock = ^{
		offscreenWindow.rootViewController = nil;
		block();
	};
	offscreenWindow.rootViewController = cvc;
}

+ (int) deviceMajorVersion {
    return sDeviceMajorVersion;
}

+ (iStressLessAppDelegate*) instance {
	return delegateInstance;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    [self endSession];

    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // XXXXXXX BROKEN
    
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
/*
	if (topController.selectedIndex == 3) {
		ManageSymptomsNavController *vc = [topController.viewControllers objectAtIndex:3];
        if ([vc respondsToSelector:@selector(isInExercise)] && [vc isInExercise]) {
			return;
		}
	}
    
    BOOL reset = TRUE;
    if ([[topController.viewControllers objectAtIndex:1] onAppSuspend] && (topController.selectedIndex == 1)) reset = FALSE;
    if ([[topController.viewControllers objectAtIndex:2] onAppSuspend] && (topController.selectedIndex == 2)) reset = FALSE;
    if ([[topController.viewControllers objectAtIndex:3] onAppSuspend] && (topController.selectedIndex == 3)) reset = FALSE;
    if ([topController.viewControllers count] == 5) {
        if ([[topController.cviewControllersobjectAtIndex:4] onAppSuspend] && (topController.selectedIndex == 4)) reset = FALSE;
    }

    if (reset) topController.selectedIndex = 0;

 */
    [eventLog closeLog];
    [heartbeat logEvent:@"session_end" withParameters:nil];
    NSLog(@"unsubscribing to reachability");
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
    [[BackedQueue sharedQueue] synchronizeToDisk];
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // let's clear out the session token triggering a sign in because we don't know how long the app was inactive, it likely invalidated our old session
    [BackedQueue sharedQueue];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"token"];
    NSString *sessionId = [[NSUUID UUID] UUIDString];
    [[NSUserDefaults standardUserDefaults] setValue:sessionId forKey:@"sessionId"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [heartbeat logEvent:@"session_start" withParameters:nil];
    
    [self startSession];
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"__catalyze_reachability"];
    
    NSLog(@"subscribing to reachability");
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    [reachability startNotifier];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    NSNotification *notification = [NSNotification notificationWithName:@"reachability" object:reachability];
    [self reachabilityChanged:notification];
}


/**
 applicationWillTerminate: saves changes in the application's managed object context before the application terminates.
 */
- (void)applicationWillTerminate:(UIApplication *)application {
    [AppExitedEvent logWithAppExitedAccessibilityFeaturesActive:UIAccessibilityIsVoiceOverRunning()];
    [eventLog close];
    [eventLog release];
    eventLog = nil;

    NSError *error = nil;
    if (managedObjectContext_ != nil) {
        if ([managedObjectContext_ hasChanges] && ![managedObjectContext_ save:&error]) {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

- (void)reachabilityChanged:(NSNotification *)note {
    NSLog(@"reachability changed");
    Reachability *curReach = [note object];
    NSParameterAssert([curReach isKindOfClass:[Reachability class]]);
    
    // try to avoid naming conflicts
    if ([curReach currentReachabilityStatus] == NotReachable) {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"__catalyze_reachability"];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"__catalyze_reachability"];
        [heartbeat checkQueue];
    }
}

#pragma mark -
#pragma mark Core Data stack

- (Item*)getItemWithName:(NSString*)name {
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Item" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
	[fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"name == %@",name]];
	NSArray *learnArray = [self.managedObjectContext executeFetchRequest:fetchRequest error:NULL];
	[fetchRequest release];
	if (learnArray.count == 0) return nil;
	return [learnArray objectAtIndex:0];
}

- (Content*)getContentWithName:(NSString*)name {
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Content" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
	[fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"name == %@",name]];
	NSArray *learnArray = [self.managedObjectContext executeFetchRequest:fetchRequest error:NULL];
	[fetchRequest release];
	if (learnArray.count == 0) return nil;
	return [learnArray objectAtIndex:0];
}

- (ContentViewController*)getContentControllerForObject:(NSManagedObject*)mo withDefaultUI:(NSString*)defaultUIClass {
	if (mo == nil) return nil;
	NSString *uiClass = [mo valueForKey:@"ui"];
	if (uiClass == nil) uiClass = defaultUIClass;
	ContentViewController *vc = [[[NSClassFromString(uiClass) alloc]init]autorelease];
	vc.content = (Content*)mo;
	return vc;
}

- (ContentViewController*)getContentControllerForObject:(NSManagedObject*)mo {
	return [self getContentControllerForObject:mo withDefaultUI:@"ContentViewController"];
}

- (ContentViewController*)getContentControllerWithName:(NSString*)name {
	NSManagedObject *mo = [self getContentWithName:name];
	return [self getContentControllerForObject:mo];
}

- (NSString*)getContentTextWithName:(NSString*)name {
	return [[self getContentWithName:name] valueForKey:@"mainText"];
}

- (NSManagedObject*)getSettingObject:(NSString*)name {
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Setting" inManagedObjectContext:self.udManagedObjectContext];
    [fetchRequest setEntity:entity];
	[fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"name == %@",name]];
	NSArray *learnArray = [self.udManagedObjectContext executeFetchRequest:fetchRequest error:NULL];
	[fetchRequest release];
	if (learnArray == nil) return nil;
	if (learnArray.count == 0) return nil;
	return [learnArray objectAtIndex:0];
}

- (NSString*)getSetting:(NSString *)name {
    return [globalVariables objectForKey:name];
/*
	NSManagedObject *o = [self getSettingObject:name];
	if (o == nil) return nil;
	return [o valueForKey:@"value"];
*/ 
}

- (void)setSetting:(NSString *)name to:(NSString*)value {
    if (value) {
        [globalVariables setObject:[[value copy] autorelease] forKey:name];
    } else {
        [globalVariables removeObjectForKey:name];
    }
    
	NSManagedObject *o = [self getSettingObject:name];
	if (o == nil) {
        if (value == nil) return;
		o = [NSEntityDescription insertNewObjectForEntityForName:@"Setting"	inManagedObjectContext:self.udManagedObjectContext];
		[o setValue:name forKey:@"name"];
        [o setValue:value forKey:@"value"];
	} else {
        if (value == nil) {
            [[self udManagedObjectContext] deleteObject:o];
        } else {
            [o setValue:value forKey:@"value"];
        }
    }
    
    NSError *err = nil;
	[self.udManagedObjectContext save:&err];
    if (err) {
        NSLog(@"Error saving settings: %@",err);
    }
}

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext {
    
    if (managedObjectContext_ != nil) {
        return managedObjectContext_;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext_ = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [managedObjectContext_ setPersistentStoreCoordinator:coordinator];
    }
    return managedObjectContext_;
}

-(NSManagedObject*)exerciseScoreFor:(NSManagedObject*)content {
	NSManagedObject *exerciseScore = nil;
	NSManagedObjectContext *udContext = self.udManagedObjectContext;
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"ExerciseScore" inManagedObjectContext:udContext];
	[fetchRequest setEntity:entity];
	NSString *oidStr = [content valueForKey:@"uniqueID"];
	[fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"refID == %@",oidStr]];
	NSArray *exerciseScores = [udContext executeFetchRequest:fetchRequest error:NULL];
	[fetchRequest release];
	if (exerciseScores && exerciseScores.count) {
		exerciseScore = [exerciseScores objectAtIndex:0];
	}
	
	return exerciseScore;
}

-(void)setExerciseScoreValue:(int)score forContent:(NSManagedObject*)exerciseContent {
	NSManagedObject *parent = nil;
	NSManagedObject *scoreObj = [self exerciseScoreFor:exerciseContent];
	NSManagedObject *scoreParentObj = nil;
	NSManagedObject *exerciseScore = nil;
	NSManagedObjectContext *udContext = self.udManagedObjectContext;
	BOOL categoryLevelFavorite;
	if (!scoreObj) {
		exerciseScore = [NSEntityDescription insertNewObjectForEntityForName:@"ExerciseScore" inManagedObjectContext:udContext];
		scoreObj = exerciseScore;
		parent = [exerciseContent valueForKey:@"parent"];
		NSNumber *catLevelFavNum = [parent valueForKey:@"categoryLevelFavorite"];
		categoryLevelFavorite = catLevelFavNum ? [catLevelFavNum boolValue] : FALSE;
		NSString *oidStr = [exerciseContent valueForKey:@"uniqueID"];
		NSString *parentOidStr = [parent valueForKey:@"uniqueID"];
		
		[scoreObj setValue:oidStr forKey:@"refID"];
		[scoreObj setValue:parentOidStr forKey:@"parentRefID"];
		[scoreObj setValue:[exerciseContent valueForKey:@"displayName"] forKey:@"displayName"];
		[scoreObj setValue:[parent valueForKey:@"displayName"] forKey:@"parentDisplayName"];
		[scoreObj setValue:[NSNumber numberWithBool:FALSE] forKey:@"isCategory"];
		[scoreObj setValue:[NSNumber numberWithBool:!categoryLevelFavorite] forKey:@"inFavoriteList"];
	} else {
		parent = [exerciseContent valueForKey:@"parent"];
		NSNumber *catLevelFavNum = [parent valueForKey:@"categoryLevelFavorite"];
		categoryLevelFavorite = catLevelFavNum ? [catLevelFavNum boolValue] : FALSE;
	}
	
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	[fetchRequest setEntity:[scoreObj entity]];
	[fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"refID == %@",[scoreObj valueForKey:@"parentRefID"]]];
	NSArray *parents = [udContext executeFetchRequest:fetchRequest error:NULL];
	[fetchRequest release];
	
	if (parents && parents.count) {
		scoreParentObj = [parents objectAtIndex:0];
	} else {
		scoreParentObj = [NSEntityDescription insertNewObjectForEntityForName:@"ExerciseScore" inManagedObjectContext:udContext];
		NSManagedObject *grandparent = [parent valueForKey:@"parent"];
		NSString *grandparentOidStr = [grandparent valueForKey:@"uniqueID"];
		[scoreParentObj setValue:[scoreObj valueForKey:@"parentRefID"] forKey:@"refID"];
		[scoreParentObj setValue:grandparentOidStr forKey:@"parentRefID"];
		[scoreParentObj setValue:[parent valueForKey:@"displayName"] forKey:@"displayName"];
		[scoreParentObj setValue:[grandparent valueForKey:@"displayName"] forKey:@"parentDisplayName"];
		[scoreParentObj setValue:[NSNumber numberWithBool:TRUE] forKey:@"isCategory"];
		[scoreParentObj setValue:[NSNumber numberWithBool:categoryLevelFavorite] forKey:@"inFavoriteList"];
	}
	
	int positiveScoreParent = [[scoreParentObj valueForKey:@"positiveScore"] intValue];
	int negativeScoreParent = [[scoreParentObj valueForKey:@"negativeScore"] intValue];
	int positiveScore = [[scoreObj valueForKey:@"positiveScore"] intValue];
	int negativeScore = [[scoreObj valueForKey:@"negativeScore"] intValue];
	
	if (score > 0) {
		negativeScoreParent -= negativeScore;
		negativeScore = 0;
		positiveScore = score;
		positiveScoreParent += positiveScore;
	} else if (score < 0) {
		positiveScoreParent -= positiveScore;
		positiveScore = 0;
		negativeScore = score;
		negativeScoreParent += negativeScore;
	} else {
		positiveScoreParent -= positiveScore;
		negativeScoreParent -= negativeScore;
		positiveScore = 0;
		negativeScore = 0;
	}
	
	[scoreObj setValue:[NSNumber numberWithInt:positiveScore] forKey:@"positiveScore"];
	[scoreObj setValue:[NSNumber numberWithInt:negativeScore] forKey:@"negativeScore"];
	[scoreParentObj setValue:[NSNumber numberWithInt:positiveScoreParent] forKey:@"positiveScore"];
	[scoreParentObj setValue:[NSNumber numberWithInt:negativeScoreParent] forKey:@"negativeScore"];
	
	[udContext save:nil];
}

- (void) resetApp {
	NSArray *searchPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentFolderPath = [searchPaths objectAtIndex:0];
	NSString *storePath = [documentFolderPath stringByAppendingPathComponent:@"userdata.db"];
	[[NSFileManager defaultManager] removeItemAtPath:storePath error:NULL];
    exit(0);
}

- (void) resetTools {
	NSManagedObjectContext *udContext = self.udManagedObjectContext;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"ExerciseRef"];
    [fetchRequest setIncludesPropertyValues:FALSE];
    NSArray *toDelete = [udContext executeFetchRequest:fetchRequest error:NULL];
    for (ExerciseRef *s in toDelete) {
        s.positiveScore = @0;
        s.negativeScore = @0;
        s.sectionName = @"Available Tools";
        s.sectionOrder = @1;
    }
    
    NSError *err = nil;
    [udContext save:&err];
    if (err) {
        NSLog(@"%@",err);
    }
}

- (void)createExampleGoalsFromContent:(Content*)contentParent withRoot:(Goal*)goalParent atLevel:(int)level {
    NSMutableOrderedSet *children = [NSMutableOrderedSet orderedSet];
    for (Content *c in contentParent.children) {
        Goal *g = [NSEntityDescription insertNewObjectForEntityForName:@"Goal" inManagedObjectContext:goalParent.managedObjectContext];
        g.displayName = c.displayName;
        g.expanded = [NSNumber numberWithBool:TRUE];
        g.parent = goalParent;
        g.notes = [c getExtraString:@"notes"];
        g.level = [NSNumber numberWithInt:level];
        [children addObject:g];
        [self createExampleGoalsFromContent:c withRoot:g atLevel:level+1];
    }

    if (children.count) goalParent.children = children;
}

- (void) createScores {
	NSManagedObjectContext *context = self.managedObjectContext;
	NSManagedObjectContext *udContext = self.udManagedObjectContext;
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"SymptomRef"];
    [fetchRequest setIncludesPropertyValues:FALSE];
    NSArray *toDelete = [udContext executeFetchRequest:fetchRequest error:NULL];
    for (SymptomRef *s in toDelete) { [udContext deleteObject:s]; }

    fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Symptom"];
    [fetchRequest setFetchBatchSize:100];
    NSArray *symptoms = [context executeFetchRequest:fetchRequest error:NULL];
    
    NSMutableDictionary *symptomMap = [NSMutableDictionary dictionaryWithCapacity:symptoms.count];
    NSMutableDictionary *symptomMapByName = [NSMutableDictionary dictionaryWithCapacity:symptoms.count];
    for (Content *c in symptoms) {
        SymptomRef *s = [NSEntityDescription insertNewObjectForEntityForName:@"SymptomRef" inManagedObjectContext:udContext];
        s.refID = c.uniqueID;
        s.displayName = c.displayName;
        s.sectionName = nil;
        [symptomMap setObject:s forKey:s.refID];
        [symptomMapByName setObject:s forKey:c.name];
    }
    
    NSMutableDictionary *categoryMap = [NSMutableDictionary dictionaryWithCapacity:symptoms.count];
    fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"ExerciseCategory"];
    [fetchRequest setFetchBatchSize:100];
    NSArray *categories = [context executeFetchRequest:fetchRequest error:NULL];
    
    fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Content"];
    [fetchRequest setFetchBatchSize:100];
	[fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"!(category = nil)"]];
    NSArray *exercises = [context executeFetchRequest:fetchRequest error:NULL];
    
	NSMutableArray *results = [NSMutableArray arrayWithArray:categories];
    [results addObjectsFromArray:exercises];
    
    fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"ExerciseRef"];
    [fetchRequest setIncludesPropertyValues:FALSE];
    toDelete = [udContext executeFetchRequest:fetchRequest error:NULL];
    for (ExerciseRef *s in toDelete) { [udContext deleteObject:s]; }
    
    for (Content *c in results) {
        ExerciseRef *s = [NSEntityDescription insertNewObjectForEntityForName:@"ExerciseRef" inManagedObjectContext:udContext];
        s.refID = c.uniqueID;
        s.parent = nil;
        s.displayName = c.displayName;
        s.inFavoriteList = @0;
        s.sectionName = @"Available Tools";
        s.sectionOrder = @1;
        if ([c.entity.name isEqualToString:@"ExerciseCategory"]) {
            s.isCategory = @1;
            s.childCount = @0;
            s.weight = @0;
            NSNumber *categoryLevelFavorite = [c valueForKey:@"categoryLevelFavorite"];
            if (categoryLevelFavorite != nil) {
                s.addressable = categoryLevelFavorite;
            }
            [categoryMap setObject:s forKey:c.uniqueID];
        } else {
            s.isCategory = @0;
            s.parent = [categoryMap objectForKey:((Content*)c.parent).uniqueID];
            s.parent.childCount = [NSNumber numberWithInt:[s.parent.childCount intValue] + 1];
            s.childCount = @0;
            s.weight = c.weight;
            for (Content *symptom in c.helpsWithSymptoms) {
                [s addHelpsWithSymptomsObject:[symptomMap objectForKey:symptom.uniqueID]];
            }
            Content *cat = (Content*)c.category;
            if (cat) {
                NSNumber *categoryLevelFavorite = [cat valueForKey:@"categoryLevelFavorite"];
                if (categoryLevelFavorite != nil) {
                    s.addressable = [categoryLevelFavorite boolValue] ? @0 : @1;
                }
            }
        }
    }

    fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"JournalEntry"];
    [fetchRequest setIncludesPropertyValues:FALSE];
    toDelete = [udContext executeFetchRequest:fetchRequest error:NULL];
    for (NSManagedObject *s in toDelete) { [udContext deleteObject:s]; }
    
    fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"SymptomTrigger"];
    [fetchRequest setIncludesPropertyValues:FALSE];
    toDelete = [udContext executeFetchRequest:fetchRequest error:NULL];
    for (NSManagedObject *s in toDelete) { [udContext deleteObject:s]; }

    fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"CopingTechnique"];
    [fetchRequest setIncludesPropertyValues:FALSE];
    toDelete = [udContext executeFetchRequest:fetchRequest error:NULL];
    for (NSManagedObject *s in toDelete) { [udContext deleteObject:s]; }
    
    Content *defaultSymptomTriggers = [self getContentWithName:@"defaultSymptomTriggers"];
    if (defaultSymptomTriggers) {
        for (Content *c in defaultSymptomTriggers.children) {
            SymptomTrigger *s = [NSEntityDescription insertNewObjectForEntityForName:@"SymptomTrigger" inManagedObjectContext:udContext];
            s.displayName = c.displayName;
            s.permanent = [NSNumber numberWithBool:TRUE];
            NSString *appliesTo = [c getExtraString:@"appliesTo"];
            NSArray *a = [appliesTo componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            for (NSString *symptomName in a) {
                [s addAppliesToObject:[symptomMapByName objectForKey:symptomName]];
            }
        }
    }

    Content *defaultCopingTechniques = [self getContentWithName:@"defaultCopingTechniques"];
    if (defaultCopingTechniques) {
        for (Content *c in defaultCopingTechniques.children) {
            CopingTechnique *s = [NSEntityDescription insertNewObjectForEntityForName:@"CopingTechnique" inManagedObjectContext:udContext];
            s.displayName = c.displayName;
            NSString *appliesTo = [c getExtraString:@"appliesTo"];
            NSArray *a = [appliesTo componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            for (NSString *symptomName in a) {
                NSLog(@"%@",symptomName);
                [s addAppliesToObject:[symptomMapByName objectForKey:symptomName]];
            }
        }
    }

    fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Goal"];
    [fetchRequest setIncludesPropertyValues:FALSE];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"displayName == 'EXAMPLES'"]];
    toDelete = [udContext executeFetchRequest:fetchRequest error:NULL];
    for (NSManagedObject *s in toDelete) { [udContext deleteObject:s]; }

    Content *exampleGoals = [self getContentWithName:@"exampleGoals"];
    if (exampleGoals) {
        Goal *g = [NSEntityDescription insertNewObjectForEntityForName:@"Goal" inManagedObjectContext:udContext];
        g.displayName = @"EXAMPLES";
        g.level = [NSNumber numberWithInt:0];
        [self createExampleGoalsFromContent:exampleGoals withRoot:g atLevel:1];
    }

    NSError *err = nil;
    [udContext save:&err];
    if (err) {
        NSLog(@"%@",err);
    }
}

- (NSManagedObjectContext *)udManagedObjectContext {
    
    if (udManagedObjectContext_ != nil) {
        return udManagedObjectContext_;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self udPersistentStoreCoordinator];
    if (coordinator != nil) {
        udManagedObjectContext_ = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [udManagedObjectContext_ setPersistentStoreCoordinator:coordinator];
    }
	
    if (recreateRefs) [self createScores];
#if BUILD_DEMO
	if (createdUserDataForFirstTime) {
        	/*
		NSManagedObject *rid = [self getContentWithName:@"rid"];
		NSManagedObject *pmr = [self getContentWithName:@"progressiveRelaxation"];
		NSManagedObject *db = [self getContentWithName:@"deepBreathing"];
		NSManagedObject *planToReduceIsolation = [self getContentWithName:@"planToReduceIsolation"];
		NSManagedObject *soothWithMyAudio = [self getContentWithName:@"soothWithMyAudio"];
		NSManagedObject *soothWithMyPictures = [self getContentWithName:@"soothWithMyPictures"];
		[self setExerciseScoreValue:1 forContent:rid];
		[self setExerciseScoreValue:1 forContent:pmr];
		[self setExerciseScoreValue:1 forContent:db];
		[self setExerciseScoreValue:1 forContent:planToReduceIsolation];
		[self setExerciseScoreValue:1 forContent:soothWithMyAudio];
		[self setExerciseScoreValue:1 forContent:soothWithMyPictures];
		
		int i;
		float fy = 3.8;
		float startingTime = -100 * 24*60*60;
		for ( i = 0; i < 15; i++ ) {
			float fx = (8.0*i) - 20.0;
			float score = fy + (1 * rand()/(float)RAND_MAX) - 0.5;

			NSManagedObject *newPCL = [NSEntityDescription insertNewObjectForEntityForName:@"TimeSeries" inManagedObjectContext:udManagedObjectContext_];
			[newPCL setValue:[NSDate dateWithTimeIntervalSinceNow:startingTime+(fx*24*60*60)] forKey:@"time"];
			[newPCL setValue:[NSNumber numberWithFloat:score] forKey:@"value"];
			[newPCL setValue:@"nsiAverage" forKey:@"series"];

			newPCL = [NSEntityDescription insertNewObjectForEntityForName:@"TimeSeries" inManagedObjectContext:udManagedObjectContext_];
			[newPCL setValue:[NSDate dateWithTimeIntervalSinceNow:startingTime+(fx*24*60*60)] forKey:@"time"];
			[newPCL setValue:[NSNumber numberWithFloat:score] forKey:@"value"];
			[newPCL setValue:@"nsiCognitiveAverage" forKey:@"series"];

            newPCL = [NSEntityDescription insertNewObjectForEntityForName:@"TimeSeries" inManagedObjectContext:udManagedObjectContext_];
			[newPCL setValue:[NSDate dateWithTimeIntervalSinceNow:startingTime+(fx*24*60*60)] forKey:@"time"];
			[newPCL setValue:[NSNumber numberWithFloat:0.5] forKey:@"value"];
			[newPCL setValue:@"nsiEmotionalAverage" forKey:@"series"];

            newPCL = [NSEntityDescription insertNewObjectForEntityForName:@"TimeSeries" inManagedObjectContext:udManagedObjectContext_];
			[newPCL setValue:[NSDate dateWithTimeIntervalSinceNow:startingTime+(fx*24*60*60)] forKey:@"time"];
			[newPCL setValue:[NSNumber numberWithFloat:score] forKey:@"value"];
			[newPCL setValue:@"nsiSleepAverage" forKey:@"series"];
			
			fy = fy * 0.96;
		}
		
		[udManagedObjectContext_ save:nil];
		*/
	}
#endif
	
    return udManagedObjectContext_;
}


/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel {
    
    if (managedObjectModel_ != nil) {
        return managedObjectModel_;
    }
    NSString *modelPath = [[NSBundle mainBundle] pathForResource:@"coachlib" ofType:@"momd"];
    NSURL *modelURL = [NSURL fileURLWithPath:modelPath];
    managedObjectModel_ = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];    
    return managedObjectModel_;
}

- (NSManagedObjectModel *)udManagedObjectModel {
    
    if (udManagedObjectModel_ != nil) {
        return udManagedObjectModel_;
    }
    NSString *modelPath = [[NSBundle mainBundle] pathForResource:@"userdata" ofType:@"mom"];
    NSURL *modelURL = [NSURL fileURLWithPath:modelPath];
    udManagedObjectModel_ = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];    
    return udManagedObjectModel_;
}

- (NSPersistentStoreCoordinator *)tempPersistentStoreCoordinator {
    
    if (tempPersistentStoreCoordinator_ != nil) {
        return tempPersistentStoreCoordinator_;
    }
    
    tempPersistentStoreCoordinator_ = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self udManagedObjectModel]];
    return tempPersistentStoreCoordinator_;
}

- (NSPersistentStoreCoordinator *)udPersistentStoreCoordinator {
    
    if (udPersistentStoreCoordinator_ != nil) {
        return udPersistentStoreCoordinator_;
    }
    
    recreateRefs = FALSE;
    
	//    NSURL *storeURL = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"storedata.db"]];
	
	NSArray *searchPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentFolderPath = [searchPaths objectAtIndex:0];
	NSString *storePath = [documentFolderPath stringByAppendingPathComponent:@"userdata.db"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:storePath]) {
        NSString *dbPath = [[NSBundle mainBundle] pathForResource:@"storedata" ofType:@"db"];
        NSDictionary *attrs = [[NSFileManager defaultManager] attributesOfItemAtPath:storePath error:NULL];
        NSDate *udbLastMod = [attrs fileModificationDate];
        attrs = [[NSFileManager defaultManager] attributesOfItemAtPath:dbPath error:NULL];
        NSDate *dbLastMod = [attrs fileModificationDate];
        if ([dbLastMod compare:udbLastMod] == NSOrderedDescending) {
            NSLog(@"clearing user data");
            recreateRefs = TRUE;
        }
    } else {
        recreateRefs = TRUE;
        createdUserDataForFirstTime = TRUE;
    }
    
	NSURL *storeURL = [[NSURL alloc] initFileURLWithPath:storePath];
	
	//NSLog(@"%@",storeURL);
    
    NSError *error = nil;
    udPersistentStoreCoordinator_ = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self udManagedObjectModel]];
    if (![udPersistentStoreCoordinator_ addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil] error:&error]) {
        /*
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter: 
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        [[NSFileManager defaultManager] removeItemAtPath:storePath error:NULL];
        if (![udPersistentStoreCoordinator_ addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
            abort();
        }
    }
	
	[storeURL release];
    
    return udPersistentStoreCoordinator_;
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    
    if (persistentStoreCoordinator_ != nil) {
        return persistentStoreCoordinator_;
    }
    
//    NSURL *storeURL = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"storedata.db"]];

	NSString *storePath = [[NSBundle mainBundle] pathForResource:@"storedata" ofType:@"db"];
    NSLog(@"%@",storePath);
	NSURL *storeURL = [[NSURL alloc] initFileURLWithPath:storePath];
	
	//NSLog(@"%@",storeURL);
    
    NSError *error = nil;
    persistentStoreCoordinator_ = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![persistentStoreCoordinator_ addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:@{NSReadOnlyPersistentStoreOption:@YES, NSSQLitePragmasOption: @{@"journal_mode":@"DELETE"}} error:&error]) {
        /*
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter: 
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
	
	[storeURL release];
    
    return persistentStoreCoordinator_;
}


#pragma mark -
#pragma mark Application's Documents directory

/**
 Returns the path to the application's Documents directory.
 */
- (NSString *)applicationDocumentsDirectory {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc {
    
    [managedObjectContext_ release];
    [managedObjectModel_ release];
    [persistentStoreCoordinator_ release];
    [udManagedObjectContext_ release];
    [udManagedObjectModel_ release];
    [udPersistentStoreCoordinator_ release];
    [tempPersistentStoreCoordinator_ release];
	[splashScreen release];
    
    [topController release];
    [rootController release];
    [window release];
    [super dealloc];
}


@end

