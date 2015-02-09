//
//  HistoryGraphViewController.m
//  iStressLess
//


//

#import "HistoryGraphViewController.h"

@implementation HistoryGraphViewController

@synthesize dataForPlot;

-(void)loadView {
	[super loadView];
	
	scrollView.autoresizesSubviews = TRUE;
	scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	contentView.autoresizesSubviews = TRUE;
	contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

	hostingView = [[CPTGraphHostingView alloc] initWithFrame:contentView.bounds];
	hostingView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	[contentView addSubview:hostingView];
}

-(void)viewDidLoad 
{
    [super viewDidLoad];
	
	boundLinePlot = nil;
	
    // Create graph from theme
    graph = [[CPTXYGraph alloc] initWithFrame:CGRectZero];
	//CPTheme *theme = [CPTheme themeNamed:kCPPlainWhiteTheme];
    //[graph applyTheme:theme];
	//	graph.opaque = FALSE;
	//	graph.backgroundColor = [[UIColor clearColor] CGColor];
    hostingView.hostedGraph = graph;
	//	hostingView.opaque = FALSE;
	//	hostingView.backgroundColor = [UIColor clearColor];
	
	// Border
	//    graph.plotAreaFrame.borderLineStyle = ;
    graph.plotAreaFrame.cornerRadius = 10.0f;
	
    graph.paddingLeft = 10.0;
	graph.paddingTop = 10.0;
	graph.paddingRight = 10.0;
	graph.paddingBottom = 10.0;
    
    // Setup plot space
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)graph.defaultPlotSpace;
    plotSpace.allowsUserInteraction = NO;
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(-28.0) length:CPTDecimalFromFloat(120+10)];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(-10) length:CPTDecimalFromFloat(85)];
	
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
	x.visibleRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(-20) length:CPTDecimalFromFloat(120+20)];
	x.labelRotation = M_PI/4;
    
    CPTMutableLineStyle *lineStyle = [x.axisLineStyle mutableCopy];
	lineStyle.lineColor = [CPTColor whiteColor];
    x.axisLineStyle = lineStyle;

    CPTMutableTextStyle *textStyle = [x.labelTextStyle mutableCopy];
	textStyle.color = [CPTColor whiteColor];
    x.labelTextStyle = textStyle;

	x.labelingPolicy = CPTAxisLabelingPolicyNone;
    x.orthogonalCoordinateDecimal = CPTDecimalFromString(@"0");
	NSArray *customTickLocations = [NSArray arrayWithObjects:[NSDecimalNumber numberWithInt:0], [NSDecimalNumber numberWithInt:30], [NSDecimalNumber numberWithInt:60], [NSDecimalNumber numberWithInt:90], nil];
	NSArray *xAxisLabels = [NSArray arrayWithObjects:@"May", @"June", @"July", @"August", @"September", nil];
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
    
    lineStyle = [y.axisLineStyle mutableCopy];
	lineStyle.lineColor = [CPTColor whiteColor];
    y.axisLineStyle = lineStyle;

	y.visibleRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0) length:CPTDecimalFromFloat(85-17)];
	//	y.labelRotation = M_PI;
	y.labelingPolicy = CPTAxisLabelingPolicyNone;
    
    textStyle = [y.labelTextStyle mutableCopy];
	textStyle.fontSize = 12;
	textStyle.color = [CPTColor whiteColor];
    y.labelTextStyle = textStyle;
    
    //y.majorIntervalLength = CPDecimalFromString(@"17");
    //y.minorTicksPerInterval = 17;
    y.orthogonalCoordinateDecimal = CPTDecimalFromString(@"-20");
	NSArray *customYTickLocations = [NSArray arrayWithObjects:[NSDecimalNumber numberWithInt:10], [NSDecimalNumber numberWithInt:37.5], [NSDecimalNumber numberWithInt:65], nil];
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
	
		
	/*
	 // Create a green plot area
	 CPScatterPlot *dataSourceLinePlot = [[[CPScatterPlot alloc] init] autorelease];
	 dataSourceLinePlot.identifier = @"Green Plot";
	 dataSourceLinePlot.dataLineStyle.lineWidth = 3.f;
	 dataSourceLinePlot.dataLineStyle.lineColor = [CPColor greenColor];
	 //	dataSourceLinePlot.dataLineStyle.dashPattern = [NSArray arrayWithObjects:[NSNumber numberWithFloat:5.0f], [NSNumber numberWithFloat:5.0f], nil];
	 dataSourceLinePlot.dataSource = self;
	 
	 // Put an area gradient under the plot above
	 CPColor *areaColor = [CPColor colorWithComponentRed:0.3 green:1.0 blue:0.3 alpha:0.8];
	 CPGradient *areaGradient = [CPGradient gradientWithBeginningColor:areaColor endingColor:[CPColor clearColor]];
	 areaGradient.angle = -90.0f;
	 areaGradientFill = [CPFill fillWithGradient:areaGradient];
	 dataSourceLinePlot.areaFill = areaGradientFill;
	 dataSourceLinePlot.areaBaseValue = CPDecimalFromString(@"1.75");
	 
	 // Animate in the new plot, as an example
	 dataSourceLinePlot.opacity = 0.0f;
	 [graph addPlot:dataSourceLinePlot];
	 
	 CABasicAnimation *fadeInAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
	 fadeInAnimation.duration = 1.0f;
	 fadeInAnimation.removedOnCompletion = NO;
	 fadeInAnimation.fillMode = kCAFillModeForwards;
	 fadeInAnimation.toValue = [NSNumber numberWithFloat:1.0];
	 [dataSourceLinePlot addAnimation:fadeInAnimation forKey:@"animateOpacity"];
	 */	
    // Add some initial data
	NSMutableArray *contentArray = [NSMutableArray arrayWithCapacity:100];
	NSUInteger i;
	float fy = 60;
	//(85.0-17.0)*rand()/(float)RAND_MAX;
	
	for ( i = 0; i < 15; i++ ) {
		float fx = (8.0*i) - 20.0;
		id x = [NSNumber numberWithFloat:fx];
		id y = [NSNumber numberWithFloat:fy + (14 * rand()/(float)RAND_MAX) - 7];
		[contentArray addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:x, @"x", y, @"y", nil]];
		fy = fy * 0.9;
	}
	self.dataForPlot = contentArray;
	
}

-(void) viewWillAppear:(BOOL)animated {
	[super viewWillAppear:(BOOL)animated];
	if (boundLinePlot) {
		boundLinePlot.opacity = 0.0f;
		[graph removePlot:boundLinePlot];
		[boundLinePlot release];
		boundLinePlot = nil;
	}
}

- (void) viewDidAppear:(BOOL)animated {
	[super viewDidAppear:(BOOL)animated];

	// Create a blue plot area
	boundLinePlot = [[CPTScatterPlot alloc] init];
    boundLinePlot.identifier = @"Blue Plot";
    
    CPTMutableLineStyle *lineStyle = [boundLinePlot.dataLineStyle mutableCopy];
	lineStyle.miterLimit = 1.0f;
	lineStyle.lineWidth = 3.0f;
	lineStyle.lineColor = [CPTColor colorWithComponentRed:0.5 green:0.5 blue:1.0 alpha:1.0];
    boundLinePlot.dataLineStyle = lineStyle;
    [lineStyle release];
    
    boundLinePlot.dataSource = self;
	boundLinePlot.opacity = 0.0f;
	[graph addPlot:boundLinePlot];
	
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
}

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot {
    return [dataForPlot count];
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    NSNumber *num = [[dataForPlot objectAtIndex:index] valueForKey:(fieldEnum == CPTScatterPlotFieldX ? @"x" : @"y")];
	// Green plot gets shifted above the blue
	if ([(NSString *)plot.identifier isEqualToString:@"Green Plot"])
	{
		if ( fieldEnum == CPTScatterPlotFieldY )
			num = [NSNumber numberWithDouble:[num doubleValue] + 1.0];
	}
    return num;
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
    [super dealloc];
}


@end
