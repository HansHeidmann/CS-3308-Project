///
///
/// SyncDataViewController.m
///
///



#import "SyncDataViewController.h"

#import "BTDiscover.h"



@interface SyncDataViewController ()

@property (weak, nonatomic) IBOutlet UITextView *testTextView;


-(void) getData;

@end

@implementation SyncDataViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"SyncData";
    
    [self getData];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void) getData {
    
    BTDiscover* bluetoothDiscoverer = [[BTDiscover alloc] init];
    
    [bluetoothDiscoverer scanForWristband];
    
    self.testTextView.text = @"something";
    
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
