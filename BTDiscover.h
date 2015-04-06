//Bluetooh Discover Class
//based heavily on code found in the XCode stater project found here
//http://www.raywenderlich.com/73306/arduino-tutorial-integrating-bluetooth-le-and-ios 

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

//wrapper around CBCentralManager and acts as its delegate object
//responsible for finding and connecting/disconnecting to a peripheral
@interface BTDiscover: NSObject <CBCentralManagerDelegate> {
  //declare out ivars to back our properties
  BTSendRec* _wristband;
  CBCentralManager* _manager;
  CBPeripheral* _bt_periph;
}
@property (strong) BTSendRec* wristband;
@property (strong) CBCentralManager* manager;
@property (strong) CBPeripheral* bt_periph;
- (void) scanForWristband;
//the functions below are to conform with the CBCentralManagerDelegate
//protocol. They will be called automatically after certain events occur
- (void) centralManagerDidUpdateState:(CBCentralManager*) central;
- (void) centralManager:(CBCentralManager*) central didDiscoverPeripheral:(CBPeripheral*) peripheral advertisementData:(NSDictionary*) advertisementData RSSI:(NSNumber*) RSSI;
- (void) centralManager:(CBCentralManager*) central didConnectPeripheral:(CBPeripheral*) peripheral;
- (void) centralManager:(CBCentralManager*) central didDisconnectPeripheral:(CBPeripheral*) peripheral error:(NSError*) error;
@end
