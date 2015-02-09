//
//  CorePlotView.m
//  iStressLess
//
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CorePlotView.h"


@implementation CorePlotView

@synthesize plotData,plot,nowish;

-(BOOL)isAccessibilityElement {
    return TRUE;    
}

-(NSString *)accessibilityLabel {
    return descriptiveLabel;
}

-(void)didMoveToWindow {
    [super didMoveToWindow];
    self.backgroundColor = [UIColor whiteColor];
    self.layer.cornerRadius = 7.0;
    self.layer.masksToBounds = TRUE;
}

-(void)setPlotData:(NSArray *)data {
    NSMutableString *str = [[NSMutableString alloc] init];
    if (self.pagingMsg) {
        [str appendString:self.pagingMsg];
        [str appendString:@".  "];
    }
    [str appendString:@"Graph of "];
    [str appendString:self.plot.graph.title];
    [str appendString:@".  "];
    [str appendString:[NSString stringWithFormat:@"Scores range from 0 to %d.  ",self.highValue]];

    plotData = data;
    NSMutableArray *a = [[NSMutableArray alloc] initWithCapacity:plotData.count];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"EEEE MMMM dd"];
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    [timeFormatter setDateFormat:@"hh:mma"];
    double scoreVal,lastScoreVal=NAN;
    for (int i=0;i<data.count;i++) {
        NSManagedObject *o = [data objectAtIndex:i];
        NSDate *time = (NSDate*)[o valueForKey:@"time"];
        NSNumber *score = (NSNumber*)[o valueForKey:@"value"];
        scoreVal = [score doubleValue];
        NSString *relativeComment = @"Score ";
        if (!isnan(lastScoreVal)) {
            if (scoreVal > lastScoreVal) {
                relativeComment = @"Higher score ";
            } else if (scoreVal < lastScoreVal) {
                relativeComment = @"Lower score ";
            } else if (scoreVal == lastScoreVal) {
                relativeComment = @"Same score ";
            }
        }
        UIAccessibilityElement *elm = [[UIAccessibilityElement alloc] initWithAccessibilityContainer:self];
        NSString *label = [NSString stringWithFormat:@"%@of %.1f on %@ at %@.  ",
                           relativeComment, scoreVal ,[formatter stringFromDate:time],[timeFormatter stringFromDate:time]];
        [str appendString:label];
        elm.accessibilityLabel = label;

        NSDecimal xy[2];
        double secondsAgo = -[time timeIntervalSinceDate:nowish];
        double daysAgo = (((secondsAgo / 60) / 60) / 24);
        double xValue = 100-daysAgo;
        xy[0] = CPTDecimalFromDouble(xValue);
        xy[1] = CPTDecimalFromDouble(scoreVal);
        lastScoreVal = scoreVal;

        CGPoint pt = [plot plotAreaViewPointForPlotPoint:xy];
        CGRect r = CGRectMake(pt.x-5, pt.y-5, 10, 10);
        elm.accessibilityFrame = r;
        elm.accessibilityTraits = UIAccessibilityTraitStaticText;
        [a addObject:elm];
        [elm release];
    }
    
    [formatter release];
    [timeFormatter release];
    
    descriptiveLabel = str;
    plotDataAccessibilityElements = a;
    [plotDataAccessibilityElements retain];
}

- (NSInteger)accessibilityElementCount {
    int i = plotDataAccessibilityElements.count;
    return i;
}

- (id)accessibilityElementAtIndex:(NSInteger)index {
    id elm = [plotDataAccessibilityElements objectAtIndex:index];
    return elm;
}

-(NSInteger)indexOfAccessibilityElement:(id)element {
    return [plotDataAccessibilityElements indexOfObject:element];
}

- (void)dealloc {
    [plotDataAccessibilityElements release];
    [descriptiveLabel release];
    [super dealloc];
}

@end
