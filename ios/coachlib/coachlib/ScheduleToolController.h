//
//  RelaxationIntroController.h
//  iStressLess
//


//

#import <Foundation/Foundation.h>
#import <EventKitUI/EventKitUI.h>
#import "ToolListController.h"
#import "ExerciseRef.h"

@interface ScheduleToolController : ToolListController <EKEventEditViewDelegate,UINavigationControllerDelegate> {
}

@property (nonatomic, retain) Content *selectedContent;

@end
