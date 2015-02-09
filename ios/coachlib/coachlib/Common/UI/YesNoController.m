//
//  RelaxationIntroController.m
//  iStressLess
//


//

#import "YesNoController.h"
#import "DCRoundSwitch.h"
#import "CenteringView.h"
#import "ThemeManager.h"

@implementation YesNoController

-(void)valueChanged {
    int val = self.yesNoSwitch.on ? 1 : 0;
    NSString *var = [self.content getExtraString:@"selectionVariable"];
    if (var) {
        [self setVariable:var to:[NSNumber numberWithInt:val]];
    }
}

-(void) configureFromContent {
    DCRoundSwitch *yesno = [[DCRoundSwitch alloc] initWithFrame:CGRectMake(0, 0, 100, 35)];
    yesno.onText = @"Yes";
    yesno.offText = @"No";
    yesno.onTintColor = [[ThemeManager sharedManager] colorForName:@"navBarTintColor"];
    self.yesNoSwitch = yesno;
    [yesno addTarget:self action:@selector(valueChanged) forControlEvents:UIControlEventValueChanged];
    UIView *v = [CenteringView gravityView:yesno withGravity:GRAVITY_CENTER_VERTICAL|GRAVITY_CENTER_HORIZONTAL];
    CGRect r = v.frame;
    r.size.width += 15;
    v.frame = r;

	[self addRightSideView:v withMargin:CGPointMake(0, 0)];
	[super configureFromContent];
/*
    yesno.userInteractionEnabled = TRUE;
    self.view.userInteractionEnabled = TRUE;
 */
//    [self addView:yesno usingGravity:GRAVITY_RIGHT];
    [yesno release];
    
    NSString *var = [self.content getExtraString:@"selectionVariable"];
    NSNumber *val = (NSNumber*)[self getVariable:var];
    if (!val) {
        [self setVariable:var to:[NSNumber numberWithInt:0]];
    } else {
        self.yesNoSwitch.on = [val boolValue];
    }
}

@end
