//
//  PhotoViewController.h
//  buy.com
//


//

#import <UIKit/UIKit.h>

@interface PhotoViewController : UIViewController <UIScrollViewDelegate> {
	UIScrollView *scroller;
	UIImageView *photoView;
}

@property (nonatomic, retain) IBOutlet UIScrollView *scroller;
@property (nonatomic, retain) IBOutlet UIImageView *photoView;

-(void) setImage:(UIImage*)image;

@end
