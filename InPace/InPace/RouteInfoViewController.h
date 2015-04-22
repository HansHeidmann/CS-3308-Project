//
//  RouteInfoViewController.h
//  InPace
//
//  Created by Madison Rockwell on 4/16/15.
//  Copyright (c) 2015 Madison Rockwell. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <MapKit/MKAnnotation.h>
#import "Database.h"

@interface RouteInfoViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate>

@property (nonatomic, retain) IBOutlet MKMapView *mapView;
@property(nonatomic, retain) CLLocationManager *locationManager;

@property (nonatomic) long long int routeID;
@property (nonatomic, strong) Database *dbManager;
@property (nonatomic, strong) NSMutableArray *arrRouteCoord;

-(void) loadRouteData;

@end
