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
    
    
    //graphing
    self.hostView = [[CPTGraphHostingView alloc] initWithFrame:self.statsView.bounds];
    [self.statsView addSubview:self.hostView];
    
    // Create a CPTGraph object and add to hostView
    CPTGraph* graph = [[CPTXYGraph alloc] initWithFrame:self.hostView.bounds];
    self.hostView.hostedGraph = graph;
    
    // Get the (default) plotspace from the graph so we can set its x/y ranges
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) graph.defaultPlotSpace;
    
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
    
    
    
    //mapping
    self.mapView.delegate = self;
    
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake(40.012603, -105.279182);
    MKCoordinateSpan span = MKCoordinateSpanMake(.005, .005);
    MKCoordinateRegion region = MKCoordinateRegionMake(center, span);
    [self.mapView setRegion: region animated: YES];
    
    [self.mapView setMapType:MKMapTypeHybrid];
    [self.mapView setZoomEnabled:YES];
    [self.mapView setScrollEnabled:YES];
    
    for (int i = 0; i < [self.arrRouteCoords count]; i++) {
        coords[i] = CLLocationCoordinate2DMake([[[self.arrRouteCoords objectAtIndex: i] objectAtIndex: 0] doubleValue], [[[self.arrRouteCoords objectAtIndex: i] objectAtIndex: 1] doubleValue]);
    }
    
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
@end
