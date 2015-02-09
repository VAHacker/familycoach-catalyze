//
//  FavoritesListViewController.h
//  iStressLess
//


//

#import <Foundation/Foundation.h>
#import "ContentViewController.h"

@interface AlarmController : ContentViewController {
}

@property (nonatomic, retain) NSString *alarmName;
@property (nonatomic, retain) NSString *alarmDestination;
@property (nonatomic, retain) NSString *alarmAction;
@property (nonatomic, retain) NSString *alarmBody;

@end
