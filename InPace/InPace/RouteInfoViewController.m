//
//  RouteInfoViewController.m
//  InPace2
//
//  Created by Madison Rockwell on 4/16/15.
//  Copyright (c) 2015 Madison Rockwell. All rights reserved.
//

#import "RouteInfoViewController.h"
#import <MapKit/MapKit.h>
#import <MapKit/MKAnnotation.h>
#import "Database.h"
#import "CorePlot-CocoaTouch.h"

double y = 0;

@interface RouteInfoViewController ()

@end

@implementation RouteInfoViewController
@synthesize statsView, routeView;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.dbManager = [[Database alloc] init_dbfile:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Database.db"]];
    
    [self loadRouteCoords];
    CLLocationCoordinate2D coords[[self.arrRouteCoords count]];
    
    [self loadRouteData];
    
    self.title = [NSString stringWithFormat: @"%d Meters in %d Minutes", (int)ceil([[[self.arrRouteData objectAtIndex: 0] objectAtIndex: 0] doubleValue]),(int)ceil([[[self.arrRouteData objectAtIndex: 0] objectAtIndex: 1] floatValue]/60.0)];
    
    //graphing
    self.hostView = [[CPTGraphHostingView alloc] initWithFrame:self.statsView.bounds];
    [self.statsView addSubview:self.hostView];
    self.hostView.allowPinchScaling = YES;
    
    // Create a CPTGraph object and add to hostView
    CPTGraph* graph = [[CPTXYGraph alloc] initWithFrame:self.hostView.bounds];
    self.hostView.hostedGraph = graph;
    
    // Get the (default) plotspace from the graph so we can set its x/y ranges
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) graph.defaultPlotSpace;
    // Enable user interactions for plot space
    plotSpace.allowsUserInteraction = YES;
    
    float xAxisMax = ([[[self.arrRouteData objectAtIndex: 0] objectAtIndex: 1] floatValue])/60;
    float yAxisMax = [[[self.arrRouteData objectAtIndex: 0] objectAtIndex: 0] floatValue];
    
    // Note that these CPTPlotRange are defined by START and LENGTH (not START and END) !!
    [plotSpace setYRange: [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat( 0 ) length:CPTDecimalFromFloat( yAxisMax )]];
    [plotSpace setXRange: [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat( 0 ) length:CPTDecimalFromFloat( xAxisMax )]];
    
    // Create the plot (we do not define actual x/y values yet, these will be supplied by the datasource...)
    CPTScatterPlot* plot = [[CPTScatterPlot alloc] initWithFrame:CGRectZero];
    
    // Let's keep it simple and let this class act as datasource (therefore we implemtn <CPTPlotDataSource>)
    plot.dataSource = self;
    
    // Finally, add the created plot to the default plot space of the CPTGraph object we created before
    [graph addPlot:plot toPlotSpace:graph.defaultPlotSpace];
    
    
    CPTMutableLineStyle *plotLineStyle = [plot.dataLineStyle mutableCopy];
    plotLineStyle.lineWidth = 2.5;
    plotLineStyle.lineColor = [CPTColor redColor];
    plot.dataLineStyle = plotLineStyle;
    
    // Create and set text style
    CPTMutableTextStyle *titleStyle = [CPTMutableTextStyle textStyle];
    titleStyle.color = [CPTColor whiteColor];
    titleStyle.fontName = @"Helvetica-Bold";
    titleStyle.fontSize = 16.0f;
    graph.titleTextStyle = titleStyle;
    graph.titlePlotAreaFrameAnchor = CPTRectAnchorTop;
    graph.titleDisplacement = CGPointMake(0.0f, 10.0f);
    //Set padding for plot area
    [graph.plotAreaFrame setPaddingLeft:16.0f];
    [graph.plotAreaFrame setPaddingBottom:44.0f];
    
    
    
    
    // 2 - Get axis set
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *) self.hostView.hostedGraph.axisSet;
    CPTAxis *x = axisSet.xAxis;
    x.title = @"Time (min)";
    // Configure y-axis
    CPTAxis *y = axisSet.yAxis;
    y.title = @"Distance (m)";
    y.titleOffset = -20.0f;
//    y.axisLineStyle = axisLineStyle;
//    y.majorGridLineStyle = gridLineStyle;
    y.labelingPolicy = CPTAxisLabelingPolicyNone;
    y.labelTextStyle = titleStyle;
    y.labelOffset = 16.0f;
//    y.majorTickLineStyle = axisLineStyle;
    y.majorTickLength = 4.0f;
    y.minorTickLength = 2.0f;
    y.tickDirection = CPTSignPositive;
    NSInteger majorIncrement = 100;
    NSInteger minorIncrement = 50;
    CGFloat yMax = 700.0f;  // should determine dynamically based on max price
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

    
    
    
    //mapping
    self.mapView.delegate = self;
    
    double lonMin = 0;
    double lonMax = 0;
    double latMin = 0;
    double latMax = 0;
    double lat = 0;
    double lon = 0;
    
    for (int i = 0; i < [self.arrRouteCoords count]; i++) {
        
        lat = [[[self.arrRouteCoords objectAtIndex: i] objectAtIndex: 0] doubleValue];
        lon = [[[self.arrRouteCoords objectAtIndex: i] objectAtIndex: 1] doubleValue];
        
        coords[i] = CLLocationCoordinate2DMake(lat, lon);
        
        if (i ==0){
            latMin = lat;
            latMax = lat;
            lonMin = lon;
            lonMax = lon;
        }
        
        if (lat < latMin){
            latMin = lat;
        }
        if (lat > latMax){
            latMax = lat;
        }
        if (lon < lonMin){
            lonMin = lon;
        }
        if (lon > lonMax){
            lonMax = lon;
        }
    }
    
    double latCenter = (latMin + latMax)/2;
    double lonCenter = (lonMin + lonMax)/2;
    NSLog(@"LATCENTER: %f LONCENTER: %f", latCenter, lonCenter);
    
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake(latCenter, lonCenter);
    MKCoordinateSpan span = MKCoordinateSpanMake(.005, .005);
    MKCoordinateRegion region = MKCoordinateRegionMake(center, span);
    [self.mapView setRegion: region animated: YES];
    
    [self.mapView setMapType:MKMapTypeHybrid];
    [self.mapView setZoomEnabled:YES];
    [self.mapView setScrollEnabled:YES];
    
    MKPolyline *routeMap = [MKPolyline polylineWithCoordinates:coords count:[self.arrRouteCoords count]];
    
    [self.mapView addOverlay:routeMap];
    
}



//CPTPlotDataSource methods
-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot {
    return [self.arrRouteCoords count];
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index {
    double x = index/30.0000000;
    
    // This method is actually called twice per point in the plot, one for the X and one for the Y value
    if(fieldEnum == CPTScatterPlotFieldX)
    {
        NSLog(@"XVALUE: %f", x);
        // Return x value, which will, depending on index, be between -4 to 4
        return [NSNumber numberWithDouble: x];
    } else {
        if(index != 0){
            
            double p1[] = {[[[self.arrRouteCoords objectAtIndex: index-1] objectAtIndex: 0] doubleValue], [[[self.arrRouteCoords objectAtIndex: index-1] objectAtIndex: 1] doubleValue]};
            
            double p2[] = {[[[self.arrRouteCoords objectAtIndex: index] objectAtIndex: 0] doubleValue], [[[self.arrRouteCoords objectAtIndex: index] objectAtIndex: 1] doubleValue]};
            
            double lat1 = to_rad(p1[0]);
            double lat2 = to_rad(p2[0]);
            double lon1 = to_rad(p1[1]);
            double lon2 = to_rad(p1[1]);
            double t1 = pow(sin((lat2 - lat1) / 2), 2);
            double t2 = pow(sin((lon2 - lon1) / 2), 2);
            double t3 = cos(lat1) * cos(lat2) * t2;
            y = y + (2 * RADIUS * asin(sqrt(t1 + t3)));
        }
        NSLog(@"YVALUE: %f", y);
        // Return y value, for this example we'll be plotting y = x * x
        return [NSNumber numberWithDouble: y];
    }
}




//Mapping
-(void)loadRouteCoords {
    
    NSString *query = [NSString stringWithFormat:@"select Latitude, Longitude from Coordinates where RouteID=%lld", self.routeID];
    
    [self.arrRouteCoords removeAllObjects];
    
    [self.dbManager query:query];
    self.arrRouteCoords = [[NSMutableArray alloc] initWithArray:self.dbManager.results];
    
}

-(void)loadRouteData {
    
    NSString *query = [NSString stringWithFormat:@"select Distance, Time from Routes where ID=%lld", self.routeID];
    
    [self.arrRouteData removeAllObjects];
    
    [self.dbManager query:query];
    self.arrRouteData = [[NSMutableArray alloc] initWithArray:self.dbManager.results];
    
}

-(MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    
    MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc] initWithPolyline:overlay];
    
    renderer.strokeColor = [[UIColor redColor] colorWithAlphaComponent:1.0];
    
    renderer.lineWidth = 3;
    
    return renderer;
}


- (IBAction)segmentValueChanged:(UISegmentedControl *)sender {
    switch (sender.selectedSegmentIndex) {
        case 0:
            self.statsView.hidden = YES;
            self.routeView.hidden = NO;
            break;
            
        case 1:
            self.statsView.hidden = NO;
            self.routeView.hidden = YES;
            break;
            
        default:
            break;
    }
    
}

-(void)viewDidDisappear:(BOOL)animated{
    y = 0;
}
@end
