//
//  CenteringView.h
//  iStressLess
//


//

#import <UIKit/UIKit.h>

#define GRAVITY_CENTER_HORIZONTAL   0x0001
#define GRAVITY_RIGHT               0x0002
#define GRAVITY_LEFT                0x0004
#define GRAVITY_CENTER_VERTICAL     0x0010
#define GRAVITY_BOTTOM              0x0020
#define GRAVITY_TOP                 0x0040

@interface CenteringView : UIView {
}

@property (nonatomic) int gravity;

-(id) initWithView:(UIView *)v;
-(id) initWithView:(UIView *)v usingGravity:(int)gravity;

+(CenteringView*) centeredView:(UIView *)v;
+(CenteringView*) gravityView:(UIView *)v withGravity:(int)gravity;

@end
