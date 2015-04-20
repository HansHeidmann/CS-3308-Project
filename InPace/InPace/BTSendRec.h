//Bluetooh SendRec class
//based heavily off code found here:
//http://www.raywenderlich.com/73306/arduino-tutorial-integrating-bluetooth-le-and-ios

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <math.h>
#import <time.h>
#import "Database.h"

/** \file BTSendRec.h
    \brief Bluetooth send and receive functionality

This file defines the necessary functions and macros to handle reading data from the InPace wristband, parsing it, submitting it to the database, reading values out of the database, and sending the necessary data to the wristband.
*/

/** This macro expands to a CBUUID object that represents the UUID of the Bluetooth shield used in the InPace wristband.
*/
#define BLE_UUID [CBUUID UUIDWithString: @"713D0000-503E-4C75-BA94-3148F18D941E"]
/** This macro expands to a CBUUID object that represents the UUID of the Read characteristic on the Bluetooth shield.
*/
#define RX_UUID [CBUUUID UUIDWithString: @"713D0002-503E-4C75-BA94-3148F18D941E"]
/** This macro expands to a CBUUID object that represents the UUID of the Write characteristic on the Bluetooth shield.
*/
#define TX_UUID [CBUUID UUIDWIthString: @"713D0003-503E-4C75-BA94-3148F18D941E"]
/** No idea what this does or why it's here, honestly...
*/
#define RWT_BLE_SERVICE_CHANGED_STATUS_NOTIFICATION @"stuff goes here"
/** This macro expands to the mean radius of the Earth in meters.
*/
#define RADIUS 6371000
/** This macro expands to the value of pi.
*/
#define PI 3.1415926
/** This macro takes the value x and converts it into radians.
*/
#define to_rad(x) ((double) x * PI / 180)

/** \brief Class responsible for doing the data transmission to the connected peripheral

This class is largely a wrapper around CBPeripheral and also acts as its delegate object. As such, many functions are implemented so the class conforms to the CBPeripheralDelegate protocol.
*/
@interface BTSendRec : NSObject <CBPeripheralDelegate> {
  NSMutableDictionary* discoveredCharacteristics;
- (instancetype) initWithPeripheral:(CBPeripheral*) peripheral;
- (void) startDiscoveringServices;
- (void) reset;
/** \param filename The name of the file whose content is to be parsed and placed into a database
\param db The database where the data will be stored
*/
- (void) writeFile: (NSString*) filename toDatabase: (Database*) db;
/** This function uses the Haversine Formula to compute the distance between two pairs of GPS coordinates. Both input parameters are assumed to be arrays of doubles of the form [Latitude, Longitude], both of which are in degrees.
\param p1 An array of doubles of size 2 containing a pair of GPS coordinates
\param p2 An array of doubles of size 2 containing a pair of GPS coordinates
\return The function returns the calculated distance between the two points
*/
- (double) distance: (double*) p1 secondPoint: (double*) p2;
/** This function computes the difference between two timestamps. Both paramaters are assumed to be arrays of doubles of the form [Year, Month, Day, Hour, Minute, Second].
\param start An array of ints of size 6 containing time information
\param end An array of ints of size 6 containing time information
\return The function returns the difference bewtween the two times in seconds
*/
- (int) time: (int*) start endTime: (int*) end;
- (void) peripheral: (CBPeripheral*) peripheral didDiscoverServices: (NSError*) error;
- (void) peripheral: (CBPeripheral*) peripheral didDiscoverCharacteristicsForService: (CBService*) service error: (NSError*) error;
- (void) sendBTServiceNotificationWithIsBluetoothConnected: (BOOL) isBluetoothConnected;
@end
