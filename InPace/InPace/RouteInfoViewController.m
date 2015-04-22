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

@interface RouteInfoViewController ()

@end

@implementation RouteInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.mapView.delegate = self;
    
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake(40.0274, -105.2519);
    MKCoordinateSpan span = MKCoordinateSpanMake(.1, .1);
    MKCoordinateRegion region = MKCoordinateRegionMake(center, span);
    [self.mapView setRegion: region animated: YES];
    
    [self.mapView setMapType:MKMapTypeHybrid];
    [self.mapView setZoomEnabled:YES];
    [self.mapView setScrollEnabled:YES];
    
    self.dbManager = [[Database alloc] init_dbfile:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Database.db"]];
    
    [self loadRouteData];
    
}


-(void)loadRouteData {
    
    NSString *query = [NSString stringWithFormat:@"select * from Coordinates where RouteID=%lld", self.routeID];
    
    [self.arrRouteCoord removeAllObjects];
    
    [self.dbManager query:query];
    self.arrRouteCoord = [[NSMutableArray alloc] initWithArray:self.dbManager.results];
    
    
}


@end
