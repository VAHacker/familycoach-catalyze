//
//  CorePlotView.h
//  iStressLess
//
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CorePlot-CocoaTouch.h"

@interface CorePlotView : CPTGraphHostingView {
    CPTPlotSpace *plot;
    NSDate *nowish;
    NSArray *plotData;
    NSArray *plotDataAccessibilityElements;
    NSString *descriptiveLabel;
}

@property(readwrite, assign, nonatomic) CPTPlotSpace *plot;
@property(readwrite, assign, nonatomic) NSDate *nowish;
@property(readwrite, assign, nonatomic) NSArray *plotData;
@property(readwrite, retain, nonatomic) NSString *pagingMsg;
@property(nonatomic) int highValue;

@end
