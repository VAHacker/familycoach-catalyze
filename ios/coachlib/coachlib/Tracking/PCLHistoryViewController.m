//
//  HistoryGraphViewController.m
//  iStressLess
//


//

#import <MessageUI/MessageUI.h>
#import "CorePlot-CocoaTouch.h"
#import "PCLHistoryViewController.h"
#import "UIAlertView+MKBlockAdditions.h"
#import "iStressLessAppDelegate.h"
#import "ThemeManager.h"
#import "CPTPlotGroup.h"
#import "CenteringView.h"

@interface UIAccessiblePageViewController : UIPageViewController
@property(readwrite, retain, nonatomic) NSArray *seriesList;
@end

@implementation UIAccessiblePageViewController
-(BOOL)accessibilityScroll:(UIAccessibilityScrollDirection)direction {
    UIViewController *newOne = nil;
    UIPageViewControllerNavigationDirection dir;
    if ((direction == UIAccessibilityScrollDirectionNext) || (direction == UIAccessibilityScrollDirectionRight)) {
        newOne = [self.dataSource pageViewController:self viewControllerAfterViewController:[self.viewControllers objectAtIndex:0]];
        dir = UIPageViewControllerNavigationDirectionForward;
    } else if ((direction == UIAccessibilityScrollDirectionPrevious) || (direction == UIAccessibilityScrollDirectionLeft)) {
        newOne = [self.dataSource pageViewController:self viewControllerBeforeViewController:[self.viewControllers objectAtIndex:0]];
        dir = UIPageViewControllerNavigationDirectionReverse;
    }

    if (newOne) {
        NSArray *prev = self.viewControllers;
        //NSString *page = [NSString stringWithFormat:@"Page %d of %d", [self.seriesList indexOfObject:newOne]+1, self.seriesList.count];
        [self setViewControllers:@[newOne]
                                          direction:dir
                                           animated:TRUE
                                         completion:^(BOOL foo){
                                             [self.delegate pageViewController:self didFinishAnimating:TRUE previousViewControllers:prev transitionCompleted:TRUE];
                                             //UIAccessibilityPostNotification(UIAccessibilityPageScrolledNotification, page);
                                             UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, ((UIViewController*)[self.viewControllers objectAtIndex:0]).view);
                                         }];
        return TRUE;
    }
    return TRUE;
}
@end


#define END_OF_GRAPH 100.0

@interface Series : UIViewController <CPTPlotDataSource>
    @property(retain, nonatomic) NSString *name;
    @property(retain, nonatomic) Content *contentObj;
    @property(retain, nonatomic) NSArray *plotData;
    @property(retain, nonatomic) UIView *containerView;
    @property(retain, nonatomic) CorePlotView *plotView;
    @property(nonatomic) float lowValue;
    @property(nonatomic) float highValue;
    @property(retain, nonatomic) NSDate *nowish;
@end
@implementation Series

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot {
    return self.plotData ? self.plotData.count : 0;
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
	NSManagedObject *pclScore = (NSManagedObject*)[self.plotData objectAtIndex:index];
	if (fieldEnum == CPTScatterPlotFieldX) {
		NSDate *timestamp = (NSDate *)[pclScore valueForKey:@"time"];
		double secondsAgo = -[timestamp timeIntervalSinceDate:self.nowish];
		double daysAgo = (((secondsAgo / 60) / 60) / 24);
		double xValue = END_OF_GRAPH-daysAgo;
		return [NSNumber numberWithDouble:xValue];
	} else {
        NSNumber *val = (NSNumber*)[pclScore valueForKey:@"value"];
        NSLog(@"value(%d)=%@",index,val);
		return val;
	}
}

@end

@implementation PCLHistoryViewController

- (NSArray*)getSeriesData:(NSString*)series withLimit:(int)count {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSManagedObjectContext *context = [iStressLessAppDelegate instance].udManagedObjectContext;
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"TimeSeries" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"series == %@",series]];
    
	if (count) [fetchRequest setFetchLimit:count];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"time" ascending:YES],nil]];
	NSArray *a = [context executeFetchRequest:fetchRequest error:NULL];
	[fetchRequest release];
	
	return a;
}

- (NSArray*)gatherSeries {
    NSMutableArray *seriesList = [NSMutableArray array];
    for (Content *c in [self.content getChildrenByName:@"@series"]) {
        Series *series = [[[Series alloc] init] autorelease];
        series.contentObj = c;
        series.name = [c getExtraString:@"series"];
        NSString *range = [c getExtraString:@"range"];
        NSArray *a = [range componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        series.lowValue = [((NSString*)[a objectAtIndex:0]) floatValue];
        series.highValue = [((NSString*)[a objectAtIndex:1]) floatValue];
        series.plotData = [self getSeriesData:series.name withLimit:0];
        [seriesList addObject:series];
        
        NSManagedObject *datum = [series.plotData objectAtIndex:series.plotData.count-1];
        NSNumber *val = (NSNumber*)[datum valueForKey:@"value"];
        [self setVariable:series.name to:val];
    }
    
    return seriesList;
}

// Dismisses the email composition interface when users tap Cancel or Send. Proceeds to update the message field with the result of the operation.
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    NSString *msg=nil;
	// Notifies users about errors associated with the interface
	switch (result)
	{
		case MFMailComposeResultCancelled:
			msg = @"Result: canceled";
			break;
		case MFMailComposeResultSaved:
			msg = @"Result: saved";
			break;
		case MFMailComposeResultSent:
			msg = @"Result: sent";
			break;
		case MFMailComposeResultFailed:
			msg = @"Result: failed";
			break;
		default:
			msg = @"Result: not sent";
			break;
	}
    NSLog(@"%@",msg);
	[controller dismissModalViewControllerAnimated:YES];
}

-(void)sendEmail:(Content*)source
{
    [self navigateToHere];
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"ContactReference"];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"preferred == TRUE"];
    NSArray *a = [[iStressLessAppDelegate instance].udManagedObjectContext executeFetchRequest:fetchRequest error:NULL];
    if (a.count == 0) {
        [UIAlertView alertViewWithTitle:@"No Preferred Contact" message:@"You haven't designated a contact as your preferred mental health professional.  Do this before sending your PCL scores." cancelButtonTitle:@"Never mind" otherButtonTitles:@[@"Go to Settings"] onDismiss:^(int buttonIndex) {
            [self navigateToContentName:@"setup"];
        } onCancel:NULL];
        return;
    }
    NSManagedObject *contactObject = [a objectAtIndex:0];
    NSNumber *refID = [contactObject valueForKey:@"refID"];
    ABRecordRef rec = ABAddressBookGetPersonWithRecordID([iStressLessAppDelegate instance].sharedAddressBook, [refID intValue]);
    CFTypeRef emailAddress = ABRecordCopyValue(rec, kABPersonEmailProperty);
    if (!emailAddress) {
        [UIAlertView alertViewWithTitle:@"No E-mail Address" message:@"You don't have an e-mail address recorded for your preferred mental health professional." cancelButtonTitle:@"Never mind" otherButtonTitles:@[@"Go to Settings"] onDismiss:^(int buttonIndex) {
            [self navigateToContentName:@"setup"];
        } onCancel:NULL];
        return;
    }
    
	// Set up recipients
    NSString *email = nil;
    for(CFIndex x=0;x<ABMultiValueGetCount(emailAddress);x++) {
        NSString *label = (NSString *)ABMultiValueCopyLabelAtIndex(emailAddress,x);
        NSString *value = (NSString *)ABMultiValueCopyValueAtIndex(emailAddress,x);
        if ([label isEqualToString:(NSString *)kABWorkLabel]) {
            email = [[value copy] autorelease];
        } else if (!email) {
            email = [[value copy] autorelease];
        }
        
        [label release];
        [value release];
    }

    CFRelease(emailAddress);
    
    if (!email) {
        [UIAlertView alertViewWithTitle:@"No Email Address" message:@"Please provide an email address for your preferred mental heath professional. Do this before sending your PCL scores." cancelButtonTitle:@"Nevermind" otherButtonTitles:@[@"Go to Settings"] onDismiss:^(int buttonIndex) {
            [self navigateToContentName:@"setup"];
        } onCancel:nil];
        return;
    }
    
	MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
	picker.mailComposeDelegate = self;
	
	[picker setSubject:@"PCL Results"];
    
	NSArray *toRecipients = @[email];
	
	[picker setToRecipients:toRecipients];
/*
	NSArray *ccRecipients = [NSArray arrayWithObjects:@"second@example.com", @"third@example.com", nil];
	NSArray *bccRecipients = [NSArray arrayWithObject:@"fourth@example.com"];
	[picker setCcRecipients:ccRecipients];
	[picker setBccRecipients:bccRecipients];
*/

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    
    fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"PCLScore"];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"time" ascending:YES],nil]];
    NSArray *scores = [[iStressLessAppDelegate instance].udManagedObjectContext executeFetchRequest:fetchRequest error:NULL];
    NSMutableString *csv = [NSMutableString string];
    [csv appendString:@"Time,Score\n"];
    for (NSManagedObject *o in scores) {
        NSDate *time = [o valueForKey:@"time"];
        NSNumber *score = [o valueForKey:@"score"];
        [csv appendFormat:@"\"%@\",\"%@\"\n",[dateFormatter stringFromDate:time],score];
    }
    [dateFormatter release];
    NSData *data = [csv dataUsingEncoding:NSUTF8StringEncoding];
	[picker addAttachmentData:data mimeType:@"text/csv" fileName:@"PCL Results.csv"];
	
	// Fill out the email body text
	NSString *emailBody = @"Please review my latest PCL results.";
	[picker setMessageBody:emailBody isHTML:NO];
	
	[[iStressLessAppDelegate instance] presentModalViewController:picker animated:YES];
    [picker release];
}

-(CPTScatterPlot*)convertSeries:(Series*)series {
    // Create a blue plot area
	CPTScatterPlot *boundLinePlot = [[[CPTScatterPlot alloc] init] autorelease];
    boundLinePlot.identifier = @"Blue Plot";
    
    CPTMutableLineStyle *lineStyle = [boundLinePlot.dataLineStyle mutableCopy];
	lineStyle.miterLimit = 1.0f;
	lineStyle.lineWidth = 3.0f;
	lineStyle.lineColor = [CPTColor colorWithComponentRed:0.5 green:0.5 blue:1.0 alpha:1.0];
    boundLinePlot.dataLineStyle = lineStyle;
    boundLinePlot.dataSource = series;
	boundLinePlot.opacity = 0.0f;
    [lineStyle release];
    
	// Do a blue gradient
	CPTColor *areaColor1 = [CPTColor colorWithComponentRed:0.5 green:0.5 blue:1.0 alpha:0.95];
    CPTGradient *areaGradient1 = [CPTGradient gradientWithBeginningColor:areaColor1 endingColor:[CPTColor clearColor]];
    areaGradient1.angle = -90.0f;
    CPTFill *areaGradientFill = [CPTFill fillWithGradient:areaGradient1];
    boundLinePlot.areaFill = areaGradientFill;
    boundLinePlot.areaBaseValue = [[NSDecimalNumber zero] decimalValue];
	
	// Add plot symbols
	CPTMutableLineStyle *symbolLineStyle = [CPTMutableLineStyle lineStyle];
	symbolLineStyle.lineColor = [CPTColor blackColor];
	CPTPlotSymbol *plotSymbol = [CPTPlotSymbol ellipsePlotSymbol];
	plotSymbol.fill = [CPTFill fillWithColor:[CPTColor colorWithComponentRed:0.5 green:0.5 blue:1.0 alpha:1.0]];
	plotSymbol.lineStyle = symbolLineStyle;
    plotSymbol.size = CGSizeMake(10.0, 10.0);
    boundLinePlot.plotSymbol = plotSymbol;
	
	CABasicAnimation *fadeInAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
	fadeInAnimation.duration = 1.0f;
	fadeInAnimation.removedOnCompletion = NO;
	fadeInAnimation.fillMode = kCAFillModeForwards;
	fadeInAnimation.toValue = [NSNumber numberWithFloat:1.0];
	[boundLinePlot addAnimation:fadeInAnimation forKey:@"animateOpacity"];
    
    return boundLinePlot;
}

-(CorePlotView*)makePlotWithRect:(CGRect)frame forSeries:(Series*)series NS_RETURNS_RETAINED {
	CorePlotView *hostingView = [[CorePlotView alloc] initWithFrame:frame];
	
    // Create graph from theme
    CPTXYGraph *graph = [[[CPTXYGraph alloc] initWithFrame:CGRectZero] autorelease];
	//CPTheme *theme = [CPTheme themeNamed:kCPPlainWhiteTheme];
    //[graph applyTheme:theme];
	//	graph.opaque = FALSE;
	//	graph.backgroundColor = [[UIColor clearColor] CGColor];
    hostingView.hostedGraph = graph;
	//	hostingView.opaque = FALSE;
	//	hostingView.backgroundColor = [UIColor clearColor];
	
	// Border
	//    graph.plotAreaFrame.borderLineStyle = ;
    //	CPTTheme *graphTheme = [CPTTheme themeNamed:kCPTPlainWhiteTheme];
    //    [graph applyTheme:graphTheme];
    /*
     graph.plotAreaFrame.cornerRadius = 7.0f;
     graph.opaque = FALSE;
     graph.backgroundColor = [[UIColor clearColor] CGColor];
     hostingView.opaque = FALSE;
     hostingView.backgroundColor = [UIColor clearColor];
     */
    
    graph.title = series.contentObj.title;
    CPTMutableTextStyle *textStyle = [graph.titleTextStyle mutableCopy];
    textStyle.fontSize = 18;
    graph.titleTextStyle = textStyle;
    [textStyle release];

    graph.titleDisplacement = CGPointMake(0, 10);
    graph.paddingLeft = 0;
	graph.paddingTop = 30;
	graph.paddingRight = 10;
	graph.paddingBottom = 10;
    
    float lowRange = 17;
    float highRange = 85;
    if (series) {
        lowRange = series.lowValue;
        highRange = series.highValue;
    }
    float rangeLen = highRange - lowRange;
    
    // Setup plot space
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)graph.defaultPlotSpace;
    plotSpace.allowsUserInteraction = NO;
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(-28.0) length:CPTDecimalFromFloat(120+10)];
    
    float plotRangeYLow = lowRange-rangeLen*20/85;
    float plotRangeYHigh = highRange+rangeLen*20/85;
    NSLog(@"plotRange = %f,%f",plotRangeYLow,plotRangeYHigh);
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(plotRangeYLow) length:CPTDecimalFromFloat(plotRangeYHigh)];
	
    // Axes
	CPTXYAxisSet *axisSet = (CPTXYAxisSet *)graph.axisSet;
    CPTXYAxis *x = axisSet.xAxis;
	//x.axisLineStyle = nil;
	
	/*
	 x.majorIntervalLength = CPDecimalFromString(@"0.5");
	 x.orthogonalCoordinateDecimal = CPDecimalFromString(@"2");
	 x.minorTicksPerInterval = 2;
	 NSArray *exclusionRanges = [NSArray arrayWithObjects:
	 [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(1.99) length:CPDecimalFromFloat(0.02)],
	 [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(0.99) length:CPDecimalFromFloat(0.02)],
	 [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(2.99) length:CPDecimalFromFloat(0.02)],
	 nil];
	 x.labelExclusionRanges = exclusionRanges;
	 */
	x.visibleRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(-15) length:CPTDecimalFromFloat(120+20)];
	x.labelRotation = M_PI/4;
    
    ThemeManager *theme = [ThemeManager sharedManager];
    UIColor *textColor = [theme colorForName:@"textColor"];
    CPTColor *cpColor = [CPTColor colorWithCGColor:[textColor CGColor]];
    
    CPTMutableLineStyle *lineStyle = [x.axisLineStyle mutableCopy];
	lineStyle.lineColor = cpColor;
    x.axisLineStyle = lineStyle;
    [lineStyle release];
    
    textStyle = [x.labelTextStyle mutableCopy];
    textStyle.color = cpColor;
	x.labelTextStyle = textStyle;
    [textStyle release];
    x.labelOffset = -4;
	
    x.labelingPolicy = CPTAxisLabelingPolicyNone;
    x.orthogonalCoordinateDecimal = CPTDecimalFromFloat(lowRange);
	
	NSCalendar *cal = [NSCalendar currentCalendar];
	unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
	NSDateComponents *dc = [cal components:unitFlags fromDate:nowish];
	
	double currentMonthTick = END_OF_GRAPH;
	currentMonthTick -= ([dc day]-15);
	[dc setDay:15];
	NSDate *currentDate = [cal dateFromComponents:dc];
	NSMutableArray *customTickLocations = [NSMutableArray arrayWithCapacity:5];
	NSMutableArray *xAxisLabels = [NSMutableArray arrayWithCapacity:5];
	while (currentMonthTick >= -20) {
		int monthIndex = [dc month];
		NSString *monthName = monthList[monthIndex-1];
		[xAxisLabels insertObject:monthName atIndex:0];
		[customTickLocations insertObject:[NSDecimalNumber numberWithDouble:currentMonthTick] atIndex:0];
		if (monthIndex == 1) {
			monthIndex = 12;
			[dc setYear:[dc year]-1];
		} else {
			monthIndex--;
		}
        
		[dc setMonth:monthIndex];
		NSDate *newDate = [cal dateFromComponents:dc];
		currentMonthTick += (([newDate timeIntervalSinceDate:currentDate] / 60) / 60) / 24;
		currentDate = newDate;
	}
	
    //	NSArray *customTickLocations = [NSArray arrayWithObjects:[NSDecimalNumber numberWithInt:0], [NSDecimalNumber numberWithInt:30], [NSDecimalNumber numberWithInt:60], [NSDecimalNumber numberWithInt:90], nil];
    //	NSArray *xAxisLabels = [NSArray arrayWithObjects:@"May", @"June", @"July", @"August", @"September", nil];
	NSUInteger labelLocation = 0;
	NSMutableArray *customLabels = [NSMutableArray arrayWithCapacity:[xAxisLabels count]];
	for (NSNumber *tickLocation in customTickLocations) {
		CPTAxisLabel *newLabel = [[CPTAxisLabel alloc] initWithText: [xAxisLabels objectAtIndex:labelLocation++] textStyle:x.labelTextStyle];
		newLabel.tickLocation = [tickLocation decimalValue];
		newLabel.offset = x.labelOffset + x.majorTickLength;
		newLabel.rotation = M_PI/4;
		[customLabels addObject:newLabel];
		[newLabel release];
	}
	x.axisLabels =  [NSSet setWithArray:customLabels];
    
    CPTXYAxis *y = axisSet.yAxis;
	//y.axisLineStyle = nil;
    
    lineStyle = [y.axisLineStyle mutableCopy];
	lineStyle.lineColor = cpColor;
    y.axisLineStyle = lineStyle;
    [lineStyle release];
    
	y.visibleRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(lowRange) length:CPTDecimalFromFloat(highRange)];
	//	y.labelRotation = M_PI;
	y.labelingPolicy = CPTAxisLabelingPolicyNone;
    
    textStyle = [y.labelTextStyle mutableCopy];
    textStyle.color = cpColor;
    textStyle.fontSize = 12;
	y.labelTextStyle = textStyle;
    [textStyle release];
    
    //y.majorIntervalLength = CPDecimalFromString(@"17");
    //y.minorTicksPerInterval = 17;
    y.orthogonalCoordinateDecimal = CPTDecimalFromFloat(-15);
	NSArray *customYTickLocations = [NSArray arrayWithObjects:[NSDecimalNumber numberWithFloat:lowRange+rangeLen*10/75.0f], [NSDecimalNumber numberWithFloat:lowRange+rangeLen*37.5/75.0f], [NSDecimalNumber numberWithFloat:lowRange+rangeLen*65/75.0f], nil];
	NSArray *yAxisLabels = [NSArray arrayWithObjects:@"Low", @"Medium", @"High", nil];
	labelLocation = 0;
	NSMutableArray *yCustomLabels = [NSMutableArray arrayWithCapacity:[yAxisLabels count]];
	for (NSNumber *tickLocation in customYTickLocations) {
		CPTAxisLabel *newLabel = [[CPTAxisLabel alloc] initWithText: [yAxisLabels objectAtIndex:labelLocation++] textStyle:y.labelTextStyle];
		newLabel.tickLocation = [tickLocation decimalValue];
		newLabel.offset = y.labelOffset + y.majorTickLength;
		newLabel.rotation = M_PI/2;
		[yCustomLabels addObject:newLabel];
		[newLabel release];
	}
	y.axisLabels =  [NSSet setWithArray:yCustomLabels];
    graph.plotAreaFrame.plotGroup.masksToBounds = TRUE;
    graph.plotAreaFrame.plotGroup.paddingLeft = 19;

    CPTScatterPlot *boundLinePlot = [self convertSeries:series];
    [graph addPlot:boundLinePlot];
    NSString *page = [NSString stringWithFormat:@"Page %d of %d", [self.seriesList indexOfObject:series]+1, self.seriesList.count];
    hostingView.pagingMsg = page;
    hostingView.highValue = series.highValue;
    hostingView.plot = boundLinePlot.plotSpace;
    hostingView.plotData = series.plotData;
    hostingView.nowish = nowish;

    return hostingView;
}

-(void) configureFromContent {
    
    self.seriesList = [self gatherSeries];
    
    NSArray *history = ((Series*)[self.seriesList objectAtIndex:0]).plotData;
	nowish = [NSDate date];
    
	NSDate *earliest = nil;
	int len = history.count;
	for (int i=0;i<len;i++) {
		NSManagedObject *pclScore = (NSManagedObject*)[history objectAtIndex:i];
		NSDate *timestamp = (NSDate *)[pclScore valueForKey:@"time"];
		if (!earliest || ([timestamp timeIntervalSinceDate:earliest] < 0)) earliest = timestamp;
	}
	
	if (!earliest) {
		nowish = [nowish dateByAddingTimeInterval:(115 * 24*60*60)];
	} else {
		if ([nowish timeIntervalSinceDate:earliest] < (115 * 24*60*60)) {
			nowish = [earliest dateByAddingTimeInterval:(115 * 24*60*60)];
		}
	}
    
	[nowish retain];
    
    for (Series *s in self.seriesList) {
        s.nowish = nowish;
    }

    int height = 200;

    CGRect r = contentView.bounds;
	r.size.height = height;
    r.size.width -= 20;
    r.size.height -= 10;
    
    int seriesCount = 0;
    for (Series *s in self.seriesList) {
        CorePlotView *hostingView = [self makePlotWithRect:r forSeries:s];
        UIView *v = [CenteringView centeredView:hostingView];
        CGRect centeringFrame = r;
        centeringFrame.size.width += 20;
        v.frame = centeringFrame;
        s.plotView = [hostingView autorelease];
        s.containerView = v;
        s.view = v;
        seriesCount++;
    }

    self.pageViewController = [[[UIAccessiblePageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil] autorelease];
    self.pageViewController.seriesList = self.seriesList;
    self.pageViewController.dataSource = self;
    
    [self.pageViewController setViewControllers:@[[self.seriesList objectAtIndex:0]]
                                      direction:UIPageViewControllerNavigationDirectionForward
                                       animated:NO
                                     completion:NULL];
    
    self.pageViewController.delegate = self;
    
    r = contentView.bounds;
	r.size.height = height;
    
    UIView *container = [[[UIView alloc] initWithFrame:r] autorelease];

    r.size.height = height-10;
    self.pageViewController.view.frame = r;
    [container addSubview:self.pageViewController.view];
    
    r.origin.y = height-8;
    r.size.height = 8;
    self.pageControl = [[[UIPageControl alloc] initWithFrame:r] autorelease];
    self.pageControl.numberOfPages = self.seriesList.count;
    self.pageControl.currentPage = 0;
    self.pageControl.pageIndicatorTintColor = [UIColor whiteColor];
    self.pageControl.currentPageIndicatorTintColor = [UIColor colorWithRed:0.5 green:0.5 blue:1.0 alpha:1.0];
    self.pageControl.isAccessibilityElement = FALSE;
    self.pageControl.hidden = (seriesCount < 2);
    [container addSubview:self.pageControl];
    
    [self addCenteredView:container];
    
    self.selectedSeries = 0;
    
    
/*
    CorePlotView *hostingView = [self makePlotWithRect:r forSeries:firstSeries];
    //	hostingView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    //	[self.dynamicView addSubview:hostingView];
    [self addCenteredView:hostingView];
*/
 
	[super configureFromContent];
    
    [self addButtonWithText:@"Clear History" callingBlock:^(UIButton *button) {
		UIAlertView *alert =
        [[UIAlertView alloc] initWithTitle:@"Clear History"
                                   message:@"Are you sure you want to clear your assessment history? You won't be able to compare new assessment results with these earlier results."
                                  delegate:self cancelButtonTitle:@"Nevermind" otherButtonTitles:@"Yes, clear it",nil];
		[alert show];
		[alert release];
	}];
    
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Help" style:UIBarButtonItemStyleBordered target:self action:@selector(helpTapped)] autorelease];
    [self registerAction:@"sendEmail" withSelector:@selector(sendEmail:)];
}

-(void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed {
    UIViewController *vc = [pageViewController.viewControllers objectAtIndex:0];
    int index = [self.seriesList indexOfObject:vc];
    self.pageControl.currentPage = index;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pvc viewControllerBeforeViewController:(UIViewController *)vc
{
    int index = [self.seriesList indexOfObject:vc];
    if (index <= 0) return nil;
    return [self.seriesList objectAtIndex:index-1];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pvc viewControllerAfterViewController:(UIViewController *)vc
{
    int index = [self.seriesList indexOfObject:vc];
    if (index >= self.seriesList.count-1) return nil;
    return [self.seriesList objectAtIndex:index+1];
}

-(void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 1) {
        for (Series *s in self.seriesList) {
            NSArray *a = s.plotData;
            for (NSManagedObject *o in a) {
                [[iStressLessAppDelegate instance].udManagedObjectContext deleteObject:o];
            }
        }
		[[iStressLessAppDelegate instance].udManagedObjectContext save:nil];
		[self.navigationController popToRootViewControllerAnimated:TRUE];
	}
}

static NSString *monthList[] = {
	@"Jan",
	@"Feb",
	@"Mar",
	@"Apr",
	@"May",
	@"Jun",
	@"Jul",
	@"Aug",
	@"Sep",
	@"Oct",
	@"Nov",
	@"Dec"
};

-(void) viewWillAppear:(BOOL)animated {
	[super viewWillAppear:(BOOL)animated];
}

- (void) viewDidAppear:(BOOL)animated {
	[super viewDidAppear:(BOOL)animated];

}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[nowish release];
	
    [super dealloc];
}


@end
