//
//  GridView.h
//  iStressLess
//


//

#import <UIKit/UIKit.h>


@interface GridView : UIView {
}

@property (nonatomic) BOOL includeTopMargin;
@property (nonatomic) int cellsPerRow;
@property (nonatomic) float outerMarginX;
@property (nonatomic) float outerMarginY;
@property (nonatomic) float cellMarginX;
@property (nonatomic) float cellMarginY;
@property (nonatomic) BOOL inLayout;

@end
