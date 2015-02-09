//
//  HistoryGraphViewController.h
//  iStressLess
//


//

#import <UIKit/UIKit.h>
#import "CorePlot-CocoaTouch.h"
#import "ContentViewController.h"
#import "CorePlotView.h"

@class UIAccessiblePageViewController;

@interface PCLHistoryViewController : ContentViewController<UIAlertViewDelegate, MFMailComposeViewControllerDelegate,UIPageViewControllerDataSource,UIPageViewControllerDelegate> {
	NSDate *nowish;
}

@property(readwrite, retain, nonatomic) UIAccessiblePageViewController *pageViewController;
@property(readwrite, retain, nonatomic) UIPageControl *pageControl;
@property(readwrite, nonatomic) int selectedSeries;
@property(readwrite, retain, nonatomic) NSArray *seriesList;

@end
