//
//  DynamicSubView.h
//  iStressLess
//


//

#import <UIKit/UIKit.h>
#import "DynamicSubView.h"

@interface LayoutableProxyView : UIView <Layoutable> {
}

@property (assign) UIView *proxyUp;

-(void)setToPreferredHeight;

@end
