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

@interface RouteInfoViewController ()

@end

@implementation RouteInfoViewController
@synthesize statsView, routeView;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.mapView.delegate = self;
    
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake(40.012603, -105.279182);
    MKCoordinateSpan span = MKCoordinateSpanMake(.005, .005);
    MKCoordinateRegion region = MKCoordinateRegionMake(center, span);
    [self.mapView setRegion: region animated: YES];
    
    [self.mapView setMapType:MKMapTypeHybrid];
    [self.mapView setZoomEnabled:YES];
    [self.mapView setScrollEnabled:YES];
    
    self.dbManager = [[Database alloc] init_dbfile:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Database.db"]];
    
    [self loadRouteData];
    
    CLLocationCoordinate2D coords[[self.arrRouteCoords count]];
    
    for (int i = 0; i < [self.arrRouteCoords count]; i++) {
        coords[i] = CLLocationCoordinate2DMake([[[self.arrRouteCoords objectAtIndex: i] objectAtIndex: 0] doubleValue], [[[self.arrRouteCoords objectAtIndex: i] objectAtIndex: 1] doubleValue]);
    }
    
    MKPolyline *routeMap = [MKPolyline polylineWithCoordinates:coords count:[self.arrRouteCoords count]];
    
    [self.mapView addOverlay:routeMap];
    
}


-(void)loadRouteData {
    
    NSString *query = [NSString stringWithFormat:@"select Latitude, Longitude from Coordinates where RouteID=%lld", self.routeID];
    
    [self.arrRouteCoords removeAllObjects];
    
    [self.dbManager query:query];
    self.arrRouteCoords = [[NSMutableArray alloc] initWithArray:self.dbManager.results];
    
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
