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

/** ViewController for viewing map and graph representation of individual route data
 */
@interface RouteInfoViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate>

@property (nonatomic, retain) IBOutlet MKMapView *mapView;/**<Map View*/

@property (nonatomic) long long int routeID;/**<holds ID of current route*/
@property (nonatomic, strong) Database *dbManager;/**<instance of Database*/
@property (nonatomic, strong) NSMutableArray *arrRouteCoord;/**<array for holding route coordinates from DB*/

/** Method for pulling individual route coordinates based on the routeID
 */
-(void) loadRouteData;

@end
