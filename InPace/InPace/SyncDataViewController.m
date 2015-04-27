///
///
/// SyncDataViewController.m
///
///



#import "SyncDataViewController.h"

#import "BTDiscover.h"


/** ViewController for showing bluetooth data after syncing
 */
@interface SyncDataViewController ()

@property (weak, nonatomic) IBOutlet UITextView *testTextView;/**<textview for showing data*/
@property (strong) BTDiscover* discover;/**<instance of BTDiscover, to discover peripherals*/


-(void) getData;

@end

@implementation SyncDataViewController

@synthesize testTextView;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"SyncData";
    

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void) getData {
    
    self.discover = [[BTDiscover alloc] init];
    
    if (self.discover.manager.state != CBCentralManagerStatePoweredOn) {
        NSLog(@"must be powered on");
    }

}

-(void) viewDidDisappear:(BOOL)animated {
    
    
}
 


- (void) viewDidAppear:(BOOL)animated {
    
    self.testTextView.text = @"Hello";
    
    [self getData];
    NSLog(@" getData was called");
    
    /*
    Database* db = [[Database alloc] init_dbfile:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Database.db"]];
    
    [self.discover.wristband readBluetooth:db];
    */
    
    [self performSelector:@selector(readBluetoothData) withObject:(self) afterDelay:(3)];
     
 
}



- (void) readBluetoothData {

    Database* db = [[Database alloc] init_dbfile:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Database.db"]];
    [self.discover.wristband readBluetooth:db];
    NSLog(@"readBluetooth Data was called");
    
}




/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
