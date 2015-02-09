//
//  FavoritesListViewController.h
//  iStressLess
//


//

#import <Foundation/Foundation.h>
#import "ContentListViewController.h"
#import "Reminder+ReminderExtensions.h"

@interface ReminderListController : ContentListViewController <EKEventEditViewDelegate,UINavigationControllerDelegate> {
}

@property (nonatomic,retain) Reminder *selectedReminder;

@end
