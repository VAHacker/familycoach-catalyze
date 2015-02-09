//
//  GridView.h
//  iStressLess
//


//

#import <UIKit/UIKit.h>


@interface HorizontalLayout : UIView {
}

@property (nonatomic) float outerMarginX;
@property (nonatomic) float outerMarginY;
@property (nonatomic) float cellMarginX;
@property (nonatomic) float cellMarginY;

- (id)initWithViews:(int)count,...;
- (id)initWithViewArray:(NSArray*)a;
	
@end
