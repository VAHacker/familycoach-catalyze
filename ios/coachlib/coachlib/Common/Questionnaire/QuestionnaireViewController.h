//
//  QuestionnaireView.h
//  iStressLess
//


//

#import <UIKit/UIKit.h>
#import "QuestionInstance.h"
#import "ContentViewController.h"

struct QPlayer;

@interface QuestionnaireViewController : ContentViewController {
	QPlayer* player;
	NSMutableArray *questions;
}

- (id) initWithPlayer:(QPlayer*)_player;

-(ConstructedView*) createMainViewWithFrame:(CGRect)frame NS_RETURNS_RETAINED ;

- (void) addQuestion:(QuestionInstance*)question;
- (void) updateValidity;

- (void) nextPressed;
- (void) helpPressed;
- (void) cancelPressed;
- (void) donePressed;

@end
