//Bluetooh SendRec class
//based heavily off code found here:
//http://www.raywenderlich.com/73306/arduino-tutorial-integrating-bluetooth-le-and-ios

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

#define BLE_UUID [CBUUID UUIDWithString: @"27EC8B94-9C1A-FE12-3669-780CD087A7A4"]

//wrapper around CBPeripheral and acts as its delegate object
//responsible for doing the data transmission to the connected peripheral
@interface BTSendRec : NSObject
- (instancetype) initWithPeripheral;
@end
