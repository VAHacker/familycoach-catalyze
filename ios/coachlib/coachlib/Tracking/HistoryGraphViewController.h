//
//  HistoryGraphViewController.h
//  iStressLess
//


//

#import <UIKit/UIKit.h>
#import "CorePlot-CocoaTouch.h"
#import "ConstructedViewController.h"
	
@interface HistoryGraphViewController : ConstructedViewController <CPTPlotDataSource> {
	CPTGraphHostingView *hostingView;
	CPTXYGraph *graph;
	NSMutableArray *dataForPlot;
	CPTScatterPlot *boundLinePlot;
}

@property(readwrite, retain, nonatomic) NSMutableArray *dataForPlot;

@end
