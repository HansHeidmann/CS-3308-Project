//
//  RoutesViewController.m
//  InPace2
//
//  Created by Madison Rockwell on 3/30/15.
//  Copyright (c) 2015 Madison Rockwell. All rights reserved.
//

#import "RoutesViewController.h"
#import "Database.h"
#import <UIKit/UIKit.h>
#import "RouteInfoViewController.h"

/** ViewController for viewing all routes in a tableview, option to click on route and view more info
 */
@interface RoutesViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tblRoutes;/**<table view*/

@property (nonatomic, strong) Database *dbManager;/**<instance of database*/

@property (nonatomic, strong) NSMutableArray *arrRoutesInfo;/**<array for holding info of all routes in DB*/

@property (nonatomic)long long int routeID;/**<holds ID of current route*/

/** Method for loading data from database and putting it into the tableview
 */
-(void)loadData;

@end

@implementation RoutesViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.title = @"My Routes";
    
    // Make self the delegate and datasource of the table view.
    self.tblRoutes.delegate = self;
    self.tblRoutes.dataSource = self;
    
    self.dbManager = [[Database alloc] init_dbfile:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Database.db"]];
    
    [self loadData];
    
}

-(void)loadData{
    // Form the query.
    NSString *query = @"select * from Routes;";
    
    // Get the results.
    [self.arrRoutesInfo removeAllObjects];
    
    [self.dbManager query:query];
    self.arrRoutesInfo = [[NSMutableArray alloc] initWithArray:self.dbManager.results];
    
    // Reload the table view.
    [self.tblRoutes reloadData];
    NSLog(@"Got to reloadData");
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    NSLog(@"Got inside of numberOfSectionsInTableView");
    return 1;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSLog(@"Got inside of tableView:numberOfRowsInSection");
    return self.arrRoutesInfo.count;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"Got inside of tableView:heightForRowAtIndexPath");
    return 60.0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    // Dequeue the cell.
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"idCellRecord" forIndexPath:indexPath];
    
    NSInteger indexOfName = [self.dbManager.columns indexOfObject:@"Name"];
    NSInteger indexOfDistance = [self.dbManager.columns indexOfObject:@"Distance"];
    NSInteger indexOfTime = [self.dbManager.columns indexOfObject:@"Time"];
    
    
    // Set the loaded data to the appropriate cell labels.
    cell.textLabel.text = [NSString stringWithFormat:@"%@ Distance: %@ Meters" , [[self.arrRoutesInfo objectAtIndex:indexPath.row] objectAtIndex:indexOfName], [[self.arrRoutesInfo objectAtIndex:indexPath.row] objectAtIndex:indexOfDistance]];
    
    NSLog(@"GOT HERE inside tableView:cellForRowAtIndexPath");
    
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Time: %@ Seconds", [[self.arrRoutesInfo objectAtIndex:indexPath.row] objectAtIndex:indexOfTime]];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    self.routeID = [[[self.arrRoutesInfo objectAtIndex:indexPath.row] objectAtIndex:0] intValue];
    
    [self performSegueWithIdentifier:@"RouteInfoViewController" sender:self];
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    RouteInfoViewController *routeInfoViewController = [segue destinationViewController];
    
    routeInfoViewController.routeID = self.routeID;
}


@end
