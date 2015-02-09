//
//  RelaxationIntroController.h
//  iStressLess
//


//

#import <Foundation/Foundation.h>
#import "ContentViewController.h"
#import "ContentListViewController.h"
#import "StyledTextView.h"

@interface PCLSchedulerController : ContentListViewController {
}

@property (nonatomic,retain) NSString *seriesToSchedule;
@property (nonatomic,retain) StyledTextView *nextAssessmentMsgView;

@end
