//
//  DynamicSubView.h
//  iStressLess
//


//

#import <UIKit/UIKit.h>

@protocol Layoutable
@required
    -(float)    contentHeight;
    -(float)    contentHeightWithFrame:(CGRect)r;
    -(float)    contentWidth;
    -(void)     setContentSizeChanged;
    -(float)    internalPaddingTop;
    -(float)    internalPaddingBottom;
@end

@interface DynamicSubView : UIView <Layoutable> {
}

@property (nonatomic) float topMargin;
@property (nonatomic) float childMargin;
@property (nonatomic) BOOL matchBounds;



@end
