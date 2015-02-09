//
//  RelaxationIntroController.h
//  iStressLess
//


//

#import <Foundation/Foundation.h>
#import <EventKitUI/EventKitUI.h>
#import "ExerciseInitialController.h"
#import "ContactsListDelegate.h"

@interface ScheduleItController : ExerciseInitialController <EKEventEditViewDelegate> {
}

@property(retain, nonatomic) ContactsListDelegate *contactsListDelegate;

@end
