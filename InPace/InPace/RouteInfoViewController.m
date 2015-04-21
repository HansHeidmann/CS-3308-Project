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

@interface RouteInfoViewController ()

@end

@implementation RouteInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.mapView.delegate = self;
    self.mapView = [[MKMapView alloc] initWithFrame:self.view.frame];
    //self.locationManager = [[CLLocationManager alloc] init];
    //self.locationManager.delegate = self;
    
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake(40.0274, -105.2519);
    MKCoordinateSpan span = MKCoordinateSpanMake(10, 10);
    MKCoordinateRegion region = MKCoordinateRegionMake(center, span);
    [self.mapView setRegion: region animated: YES];
    
    [self.mapView setMapType:MKMapTypeStandard];
    [self.mapView setZoomEnabled:YES];
    [self.mapView setScrollEnabled:YES];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
