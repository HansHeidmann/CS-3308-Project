//Bluetooh SendRec class
//based heavily off code found here:
//http://www.raywenderlich.com/73306/arduino-tutorial-integrating-bluetooth-le-and-ios

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

#define BLE_UUID [CBUUID UUIDWithString: @"713D0000-503E-4C75-BA94-3148F18D941E"]

#define RX_UUID [CBUUID UUIDWithString: @"713D0002-503E-4C75-BA94-3148F18D941E"]

#define TX_UUID [CBUUID UUIDWithString: @"713D0003-503E-4C75-BA94-3148F18D941E"]

#define RWT_BLE_SERVICE_CHANGED_STATUS_NOTIFICATION @"stuff goes here"

//wrapper around CBPeripheral and acts as its delegate object
//responsible for doing the data transmission to the connected peripheral
@interface BTSendRec : NSObject <CBPeripheralDelegate>
- (instancetype) initWithPeripheral:(CBPeripheral*) peripheral;
- (void) startDiscoveringServices;
- (void) reset;
- (void) peripheral: (CBPeripheral*) peripheral didDiscoverServices: (NSError*) error;
- (void) peripheral: (CBPeripheral*) peripheral didDiscoverCharacteristicsForService: (CBService*) service error: (NSError*) error;
- (void) sendBTServiceNotificationWithIsBluetoothConnected: (BOOL) isBluetoothConnected;
@end
