//
//  RouteInfoViewController.h
//  InPace2
//
//  Created by Madison Rockwell on 4/16/15.
//  Copyright (c) 2015 Madison Rockwell. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <MapKit/MKAnnotation.h>

@interface RouteInfoViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate>

@property (nonatomic, retain) IBOutlet MKMapView *mapView;
@property(nonatomic, retain) CLLocationManager *locationManager;

@end
