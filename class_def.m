//Basic Class info that we came up with!
#import <Foundation/Foundation.h>

/*class BluetoothSend
  -should send info to the arduino wristband
  -pulls info from the UserPref class
  -current route to run against
  -delete current GPS data on Arduino
*/
@interface BluetoothSend
//stuff to read info from UserPref
@end

/*class BluetoothRecieve
  -recieve data from Arduino
  -create routes as necessary
*/
@interface BluetoothRec
//stuff to create routes
@end

/*class Route
  +ID
  +database query functionality
  +overall time
  +overall distance
*/
@interface Route {
  int ID;
  double time;
  float distance;
}
//database query functions
@end

/*class Graph
  + associated Route
*/
@interface Graph {
  Route* route;
}
//graph draw functions
@end

/*class UserPref
  +favorite route
  +current route(or new)
  +current time(or new)
*/
@interface UserPref {
  Route* favorite;
  Route* current;
  double time;
}
@end

/*class OverallSettings
  +route sorting setting (date/time)
  +units of measure (miles, km)
*/
@interface Settings {
  NSString* sort;
  NSString* units;
}
@end

/*Database
  -GPS coord
  -Times
  -Users (IDs)
*/
