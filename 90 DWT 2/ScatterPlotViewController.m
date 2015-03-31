//
//  ScatterPlotViewController.m
//  90 DWT 1
//
//  Created by Grant, Jared on 5/8/13.
//  Copyright (c) 2013 Grant, Jared. All rights reserved.
//

#import "ScatterPlotViewController.h"

@interface ScatterPlotViewController ()

@end

@implementation ScatterPlotViewController

//@synthesize hostView = hostView_;

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - UIViewController lifecycle methods
///*

-(void)viewDidLoad {
    
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self initPlot];
}

-(void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    [self initPlot];
}

#pragma mark - Chart behavior
-(void)initPlot {
    
    //NSLog(@"Allow iPad Graph");
    
    self.matches = [self databaseMatches];
    [self configureHost];
    [self configureGraph];
    [self configurePlots];
    [self configureAxes];
    [self configureLegend];

    /*
    if ([[DWT2IAPHelper sharedInstance] productPurchased:@"com.grantsoftware.90DWT2.slidergraph"]) {
    
        //NSLog(@"Allow iPad Graph");
        
        self.matches = [self databaseMatches];
        [self configureHost];
        [self configureGraph];
        [self configurePlots];
        [self configureAxes];
        [self configureLegend];
    } else {
        self.hostView.backgroundColor = [UIColor clearColor];
    }
     */
}

-(void)configureHost {
    
	//self.hostView = [(CPTGraphHostingView *) [CPTGraphHostingView alloc] initWithFrame:self.view.bounds];
	self.hostView.allowPinchScaling = YES;
	//[self.view addSubview:self.hostView];
}

-(void)configureGraph {
    
	// 1 - Create the graph
	CPTGraph *graph = [[CPTXYGraph alloc] initWithFrame:self.hostView.bounds];
	[graph applyTheme:[CPTTheme themeNamed:kCPTDarkGradientTheme]];
	self.hostView.hostedGraph = graph;
    
	// 2 - Set graph title
    
    // Check to see what device you are using iPad or iPhone.
    NSString *deviceModel = [UIDevice currentDevice].model;
    
    // Only display the title if using iPad
    if ([deviceModel isEqualToString:@"iPad"] || [deviceModel isEqualToString:@"iPad Simulator"]) {
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        NSString *title = appDelegate.exerciseName;
        graph.title = title;
    }
    
	// 3 - Create and set text style
	CPTMutableTextStyle *titleStyle = [CPTMutableTextStyle textStyle];
	titleStyle.color = [CPTColor whiteColor];
	titleStyle.fontName = @"Helvetica-Bold";
	titleStyle.fontSize = 16.0f;
	graph.titleTextStyle = titleStyle;
	graph.titlePlotAreaFrameAnchor = CPTRectAnchorTop;
	graph.titleDisplacement = CGPointMake(0.0f, 10.0f);
    
	// 4 - Set padding for plot area
	[graph.plotAreaFrame setPaddingLeft:30.0f];
	[graph.plotAreaFrame setPaddingBottom:35.0f];
    
	// 5 - Enable user interactions for plot space
	CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) graph.defaultPlotSpace;
	plotSpace.allowsUserInteraction = YES;
}

-(void)configurePlots {
    
	// 1 - Get graph and plot space
	CPTGraph *graph = self.hostView.hostedGraph;
	CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) graph.defaultPlotSpace;
    
	// 2 - Create the three plots
	CPTScatterPlot *aaplPlot = [[CPTScatterPlot alloc] init];
	aaplPlot.dataSource = self;
	aaplPlot.identifier = @"REPS";
	CPTColor *aaplColor = [CPTColor redColor];
	[graph addPlot:aaplPlot toPlotSpace:plotSpace];
	CPTScatterPlot *googPlot = [[CPTScatterPlot alloc] init];
	googPlot.dataSource = self;
	googPlot.identifier = @"WEIGHT";
	CPTColor *googColor = [CPTColor greenColor];
	[graph addPlot:googPlot toPlotSpace:plotSpace];
    
    // 3 - Set up plot space
	[plotSpace scaleToFitPlots:[NSArray arrayWithObjects:aaplPlot, googPlot, nil]];
	CPTMutablePlotRange *xRange = [plotSpace.xRange mutableCopy];
	[xRange expandRangeByFactor:CPTDecimalFromCGFloat(1.1f)];
	plotSpace.xRange = xRange;
	CPTMutablePlotRange *yRange = [plotSpace.yRange mutableCopy];
	[yRange expandRangeByFactor:CPTDecimalFromCGFloat(1.2f)];
	plotSpace.yRange = yRange;
    
	// 4 - Create styles and symbols
	CPTMutableLineStyle *aaplLineStyle = [aaplPlot.dataLineStyle mutableCopy];
	aaplLineStyle.lineWidth = 2.5;
	aaplLineStyle.lineColor = aaplColor;
	aaplPlot.dataLineStyle = aaplLineStyle;
	CPTMutableLineStyle *aaplSymbolLineStyle = [CPTMutableLineStyle lineStyle];
	aaplSymbolLineStyle.lineColor = aaplColor;
	CPTPlotSymbol *aaplSymbol = [CPTPlotSymbol ellipsePlotSymbol];
	aaplSymbol.fill = [CPTFill fillWithColor:aaplColor];
	aaplSymbol.lineStyle = aaplSymbolLineStyle;
	aaplSymbol.size = CGSizeMake(6.0f, 6.0f);
	aaplPlot.plotSymbol = aaplSymbol;
	CPTMutableLineStyle *googLineStyle = [googPlot.dataLineStyle mutableCopy];
	googLineStyle.lineWidth = 1.0;
	googLineStyle.lineColor = googColor;
	googPlot.dataLineStyle = googLineStyle;
	CPTMutableLineStyle *googSymbolLineStyle = [CPTMutableLineStyle lineStyle];
	googSymbolLineStyle.lineColor = googColor;
	CPTPlotSymbol *googSymbol = [CPTPlotSymbol starPlotSymbol];
	googSymbol.fill = [CPTFill fillWithColor:googColor];
	googSymbol.lineStyle = googSymbolLineStyle;
	googSymbol.size = CGSizeMake(6.0f, 6.0f);
	googPlot.plotSymbol = googSymbol;
}

-(void)configureAxes {
    
	// 1 - Create styles
	CPTMutableTextStyle *axisTitleStyle = [CPTMutableTextStyle textStyle];
	axisTitleStyle.color = [CPTColor whiteColor];
	axisTitleStyle.fontName = @"Helvetica-Bold";
	axisTitleStyle.fontSize = 12.0f;
	CPTMutableLineStyle *axisLineStyle = [CPTMutableLineStyle lineStyle];
	axisLineStyle.lineWidth = 2.0f;
	axisLineStyle.lineColor = [CPTColor whiteColor];
	CPTMutableTextStyle *axisTextStyle = [[CPTMutableTextStyle alloc] init];
	axisTextStyle.color = [CPTColor whiteColor];
	axisTextStyle.fontName = @"Helvetica-Bold";
	axisTextStyle.fontSize = 11.0f;
	CPTMutableLineStyle *tickLineStyle = [CPTMutableLineStyle lineStyle];
	tickLineStyle.lineColor = [CPTColor whiteColor];
	tickLineStyle.lineWidth = 2.0f;
	CPTMutableLineStyle *gridLineStyle = [CPTMutableLineStyle lineStyle];
	tickLineStyle.lineColor = [CPTColor blackColor];
	tickLineStyle.lineWidth = 1.0f;
    
	// 2 - Get axis set
	CPTXYAxisSet *axisSet = (CPTXYAxisSet *) self.hostView.hostedGraph.axisSet;
    
	// 3 - Configure x-axis
	CPTAxis *x = axisSet.xAxis;
	x.title = @"Week";
	x.titleTextStyle = axisTitleStyle;
	x.titleOffset = 15.0f;
	x.axisLineStyle = axisLineStyle;
	x.labelingPolicy = CPTAxisLabelingPolicyNone;
	x.labelTextStyle = axisTextStyle;
	x.majorTickLineStyle = axisLineStyle;
	x.majorTickLength = 4.0f;
	x.tickDirection = CPTSignNegative;
    CGFloat dateCount = [[self matches] count];
	NSMutableSet *xLabels = [NSMutableSet setWithCapacity:dateCount];
	NSMutableSet *xLocations = [NSMutableSet setWithCapacity:dateCount];
	NSInteger i = 0;
	for (NSString *date in [[self matches] valueForKey:@"week"]) {
        
        // Remove the work "week " from the string leaving only the number at the end 
        NSString *cleanDate = [[NSString alloc] initWithString:[date substringFromIndex:5]];
		CPTAxisLabel *label = [[CPTAxisLabel alloc] initWithText:cleanDate  textStyle:x.labelTextStyle];
		CGFloat location = i++;
		label.tickLocation = CPTDecimalFromCGFloat(location);
		label.offset = x.majorTickLength;
		if (label) {
			[xLabels addObject:label];
			[xLocations addObject:[NSNumber numberWithFloat:location]];
		}
	}
	x.axisLabels = xLabels;
	x.majorTickLocations = xLocations;
    
	// 4 - Configure y-axis
	CPTAxis *y = axisSet.yAxis;
	y.title = @"Reps / Weight";
	y.titleTextStyle = axisTitleStyle;
	y.titleOffset = -40.0f;
	y.axisLineStyle = axisLineStyle;
	y.majorGridLineStyle = gridLineStyle;
	y.labelingPolicy = CPTAxisLabelingPolicyNone;
	y.labelTextStyle = axisTextStyle;
	y.labelOffset = 16.0f;
	y.majorTickLineStyle = axisLineStyle;
	y.majorTickLength = 4.0f;
	y.minorTickLength = 2.0f;
	y.tickDirection = CPTSignPositive;
	NSInteger majorIncrement = 5;
	NSInteger minorIncrement = 1;
    
    CGFloat yMax = [self findYMax];
    //NSLog(@"yMax = %f", yMax);
    
	NSMutableSet *yLabels = [NSMutableSet set];
	NSMutableSet *yMajorLocations = [NSMutableSet set];
	NSMutableSet *yMinorLocations = [NSMutableSet set];
	for (NSInteger j = minorIncrement; j <= yMax; j += minorIncrement) {
		NSUInteger mod = j % majorIncrement;
		if (mod == 0) {
			CPTAxisLabel *label = [[CPTAxisLabel alloc] initWithText:[NSString stringWithFormat:@"%i", j] textStyle:y.labelTextStyle];
			NSDecimal location = CPTDecimalFromInteger(j);
			label.tickLocation = location;
			label.offset = -y.majorTickLength - y.labelOffset;
			if (label) {
				[yLabels addObject:label];
			}
			[yMajorLocations addObject:[NSDecimalNumber decimalNumberWithDecimal:location]];
		} else {
			[yMinorLocations addObject:[NSDecimalNumber decimalNumberWithDecimal:CPTDecimalFromInteger(j)]];
		}
	}
	y.axisLabels = yLabels;
	y.majorTickLocations = yMajorLocations;
	y.minorTickLocations = yMinorLocations;
}

#pragma mark - Rotation
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
}

#pragma mark - CPTPlotDataSource methods
-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot {
    
    return [[self databaseMatches] count];
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index {
    
    NSInteger valueCount = [self.matches count];
    
	switch (fieldEnum) {
		case CPTScatterPlotFieldX:
			if (index < valueCount) {
				return [NSNumber numberWithUnsignedInteger:index];
			}
			break;
			
		case CPTScatterPlotFieldY:
			if ([plot.identifier isEqual:@"REPS"] == YES) {
                // REPS
                return [[self.matches valueForKey:@"reps"] objectAtIndex:index];
        
			} else if ([plot.identifier isEqual:@"WEIGHT"] == YES) {
                // WEIGHT
                return [[self.matches valueForKey:@"weight"] objectAtIndex:index];
                
			} 
			break;
	}
     
	return [NSDecimalNumber zero];
}

- (void)configureLegend {
    
    // 1 - Get graph instance
    CPTGraph *graph = self.hostView.hostedGraph;
    
    // 2 - Create legend
    CPTLegend *theLegend = [CPTLegend legendWithGraph:graph];
    
    // 3 - Configure legend
    theLegend.numberOfColumns = 2;
    theLegend.fill = [CPTFill fillWithColor:[CPTColor whiteColor]];
    theLegend.borderLineStyle = [CPTLineStyle lineStyle];
    theLegend.cornerRadius = 5.0;
    
    // 4 - Add legend to graph
    graph.legend = theLegend;
    graph.legendAnchor = CPTRectAnchorBottomRight;
    CGFloat legendPadding = -(self.view.bounds.size.width /8);
    graph.legendDisplacement = CGPointMake(legendPadding, 0.0);
}

- (float)findYMax {
    
    float repsMax = 0;
    float weightMax = 0;
    NSArray *repsArray = [[self matches] valueForKey:@"reps"];
    NSArray *weightArray = [[self matches] valueForKey:@"weight"];
    
    // Find Reps Max
    for (int i = 0; i < [repsArray count]; i++) {
        
        float tempRepsMax = [repsArray[i] floatValue];
        
        if (tempRepsMax > repsMax) {
            repsMax = tempRepsMax;
        }
    }
    
    // Find Weight Max
    for (int i = 0; i < [weightArray count]; i++) {
        
        float tempWeightMax = [weightArray[i] floatValue];
        
        if (tempWeightMax > weightMax) {
            weightMax = tempWeightMax;
        }
    }
    
    // Return the larger of the 2 max's
    if (repsMax > weightMax) {
        return repsMax;
        
    } else {
        return weightMax;
    }
}

@end
