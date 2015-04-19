#import "BTSendRec.h"
#import "BTDiscover.h"

@implementation BTDiscover
//synthesize getters and setters
@synthesize wristband = _wristband;
@synthesize manager = _manager;
@synthesize bt_periph = _bt_periph;

//constructor
- (instancetype) init {
  self = [super init];
  if (self) {
    //queue needed by CBCentralManager object to function
    dispatch_queue_t d_queue = dispatch_queue_create("name", DISPATCH_QUEUE_SERIAL);
    //init our CBCentralManager, use our BTDiscover object as the delegate
    self.manager = [[CBCentralManager alloc] initWithDelegate: self queue: d_queue];
  }
  return self;
}

//initiate scan for out wristband
- (void) scanForWristband {
  [self.manager scanForPeripheralsWithServices: @[BLE_UUID] options: nil];
}

//called when a peripheral was discovered during scanning by the CBCentralManager object
//central is the manager object, peripheral is the discovered peripheral
//data is the advertisement data (if any), RSSI is the signal strength
- (void) centralManager:(CBCentralManager*) central didDiscoverPeripheral:(CBPeripheral*) peripheral advertisementData:(NSDictionary*) advertisementData RSSI:(NSNumber*) RSSI {
  //make sure peripheral is a valid one
  if (!peripheral || !peripheral.name || [peripheral.name isEqualToString: @""]) {
    return;
  }
  //set as target peripheral if we're not already connected to one
  if (!self.bt_periph || (self.bt_periph.state == CBPeripheralStateDisconnected)) {
    self.bt_periph = peripheral;
  }
  //connect to the target peripheral (or none, if we don't have one set)
  [self.manager connectPeripheral: self.bt_periph options: nil];
}

//called when a peripheral was successfully connected to by our CBCM object
//central is the CBCentralManager object, peripheral is the peripheral that
//just got connected
- (void) centralManager:(CBCentralManager*) central didConnectPeripheral:(CBPeripheral*) peripheral {
  //make sure peripheral is valid. Probably paranoid
  if (!peripheral) {
    return;
  }
  //if the peripheral is the target one we want, we create a Send/Rec class
  //and stop scanning for new devices to connect to
  if (peripheral == self.bt_periph) {
    self.wristband = [[BTSendRec alloc] initWithPeripheral: peripheral];
    [self.manager stopScan];
  }
}

//called when a peripheral has disconnected
//central is the manager object, peripheral is the peripheral that has been
//disconnected, error is cause of faliure if any
- (void) centralManager:(CBCentralManager*) central didDisconnectPeripheral:(CBPeripheral*) peripheral error:(NSError*) error {
  //make sure peripheral is valid. More paranoia?
  if (!peripheral) {
    return;
  }
  //if it was our target peripheral, clear out the Send/Rec service and reset
  //our target
  if (peripheral == self.bt_periph) {
    self.wristband = nil;
    self.bt_periph = nil;
  }
  //start scanning for new peripherals to connect to
  [self scanForWristband];
}

//called whenever the CBCentralManager object changes its state
- (void) centralManagerDidUpdateState:(CBCentralManager*) central {
  if (central.state == CBCentralManagerStateUnknown) {
    //just hang tight. The state is going to update again
  } else if (central.state == CBCentralManagerStateResetting) {
    //need to clear out our stuff so we can reconnect successfully
    self.wristband = nil;
    self.bt_periph = nil;
  } else if (central.state == CBCentralManagerStateUnsupported ||
             central.state == CBCentralManagerStateUnauthorized) {
    //bluetooth cannot be run
  } else if (central.state == CBCentralManagerStatePoweredOff) {
    //clear out our stuff so we can reconnect later
    self.wristband = nil;
    self.bt_periph = nil;
  } else {
    //state here is CBCentralManagerStatePoweredOn
    //all we need to do is start trying to connect to our wristband
    [self scanForWristband];
  }
}
@end