//Bluetooh Discover Class
//based heavily on code found in the XCode stater project found here
//http://www.raywenderlich.com/73306/arduino-tutorial-integrating-bluetooth-le-and-ios 

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "BTSendRec.h"

/** \brief Class responsible for finding and connecting/disconnecting peripheral

This class is largely a wrapper around the CBCentralManager class and also acts as its delegate object. As such, many of its functions are implemented so the class conforms to the CBCentralManagerDelegate protocol.
*/
@interface BTDiscover: NSObject <CBCentralManagerDelegate> {
  //declare out ivars to back our properties
  BTSendRec* _wristband;
  CBCentralManager* _manager;
  CBPeripheral* _bt_periph;
}
@property (strong, nonatomic) BTSendRec* wristband; /**<Pointer to class to handle sending and receiving data to and from the Bluetooth peripheral */
@property (strong) CBCentralManager* manager; /**<Pointer to the internal central manager object */
@property (strong) CBPeripheral* bt_periph; /**<Pointer to the discovered Bluetooth peripheral */

/** Initiate scan for the InPace wristband
*/
- (void) scanForWristband;

//the functions below are to conform with the CBCentralManagerDelegate
//protocol. They will be called automatically after certain events occur

/** This function is called whenever the CBCentralManager object changes its state. This function is required by the CBCentralManagerDelegate protocol.
\param central The central manager object
*/
- (void) centralManagerDidUpdateState:(CBCentralManager*) central;
/** This function is called when a peripheral was discovered during scanning by the CBCentralManager object. Part of the CBCentralManagerDelegate protocol.
\param central The central manager object
\param peripheral The discovered peripheral
\param advertisementData The advertisement data (if any)
\param RSSI The signal strength
*/
- (void) centralManager:(CBCentralManager*) central didDiscoverPeripheral:(CBPeripheral*) peripheral advertisementData:(NSDictionary*) advertisementData RSSI:(NSNumber*) RSSI;
/** This function is called when a peripheral was successfully connected to by our CBCentralManager object. Part of the CBCentralManagerDelegateProtocol.
\param central The CBCentralManager object
\param peripheral The peripheral that just got connected
*/
- (void) centralManager:(CBCentralManager*) central didConnectPeripheral:(CBPeripheral*) peripheral;
/** This function is called when a peripheral has disconnected. Part of the CBCentralManagerDelegate protocol.
\param central The central manager object
\param peripheral The peripheral that has been disconnected
\param error The cause of faliure, if any
*/
- (void) centralManager:(CBCentralManager*) central didDisconnectPeripheral:(CBPeripheral*) peripheral error:(NSError*) error;
@end
