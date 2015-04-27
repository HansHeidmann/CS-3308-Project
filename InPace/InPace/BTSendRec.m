//
//  BTSendRec.m
//  InPaceTESTER
//
//  Created by calvin hicks on 4/7/15.
//  Copyright (c) 2015 calvin hicks. All rights reserved.
//

#import "BTSendRec.h"

@interface BTSendRec()
@property (strong, nonatomic) CBPeripheral *peripheral;
@property (strong, nonatomic) CBCharacteristic *readCharacteristic;
@property (strong, nonatomic) CBCharacteristic *writeCharacteristic;
@end

@implementation BTSendRec

#pragma mark - Lifecycle

- (instancetype)initWithPeripheral:(CBPeripheral *)peripheral {
    self = [super init];
    if (self) {
        self.peripheral = peripheral;
        [self.peripheral setDelegate:self];
        [discoveredCharacteristics initWithCapacity: 2];
        [discoveredCharacteristics setValue: NO forKey: @"RX"];
        [discoveredCharacteristics setValue: NO forKey: @"TX"];
    }
    return self;
}

- (void)dealloc {
    [self reset];
}

- (void)startDiscoveringServices {
    [self.peripheral discoverServices:@[BLE_UUID]];
}

- (void)reset {
    
    if (self.peripheral) {
        self.peripheral = nil;
    }
    
    // Deallocating therefore send notification
    [self sendBTServiceNotificationWithIsBluetoothConnected:NO];
}

- (void) writeFile: (NSString*) filename toDatabase: (Database*) db {
  [db query: @"INSERT INTO \"Routes\" (\"Name\") VALUES ('Route');"];
  long long int rid = db.last_rowid;
  NSString* file = [NSString stringWithContentsOfFile: filename
                                             encoding: NSUTF8StringEncoding
                                                error: NULL];
  NSMutableArray* lines = [[NSMutableArray alloc] init];
  [lines addObjectsFromArray: [file componentsSeparatedByString: @"\n"]];
  //pull out any empty lines that snuck into the file
  NSUInteger index = [lines indexOfObject: @""];
  while (index != NSNotFound) {
    [lines removeObjectAtIndex: index];
    index = [lines indexOfObject: @""];
  }
  int start_time[6];
  int end_time[6];
  double old_point[2];
  double dist = 0;
  int count = [lines count];
  for (int i = 0; i < count; i++) {
    NSArray* data = [(NSString*) [lines objectAtIndex: i] componentsSeparatedByString: @", "];
    double lon = ((NSString*) [data objectAtIndex: 0]).doubleValue;
    double lat = ((NSString*) [data objectAtIndex: 1]).doubleValue;
    [db query: [NSString stringWithFormat: @"INSERT INTO \"Coordinates\" (\"RouteID\", \"Latitude\", \"Longitude\") VALUES (%lld, %f, %f);", rid, lat, lon]];
    //if this is our first time through the loop, store our first
    //GPS point as so we can start calculating distance
    if (i == 0) {
      old_point[0] = lat;
      old_point[1] = lon;
    } else {
      double curr[2] = {lat, lon};
      dist += [self distance: old_point secondPoint: curr];
      old_point[0] = curr[0];
      old_point[1] = curr[1];
    }
    NSArray* time = [[data objectAtIndex: 3] componentsSeparatedByString: @":"];
    int hour = ((NSString*) [time objectAtIndex: 0]).intValue;
    int min = ((NSString*) [time objectAtIndex: 1]).intValue;
    int sec = ((NSString*) [time objectAtIndex: 2]).intValue;
    long long int cid = db.last_rowid;
    [db query: [NSString stringWithFormat: @"INSERT INTO \"Times\" (\"CoordinateID\", \"Hour\", \"Minute\", \"Second\") VALUES (%lld, %d, %d, %d);", cid, hour, min, sec]];
    NSLog(@"lon: %f, lat: %f, hour: %d, min: %d, sec: %d", lon, lat, hour, min, sec);
    //extract relevant timestamps for calculation of total later
    if (i == 0) {
      NSArray* date = [[data objectAtIndex: 2] componentsSeparatedByString: @"/"];
      start_time[1] = ((NSString*) [date objectAtIndex: 0]).intValue;
      start_time[2] = ((NSString*) [date objectAtIndex: 1]).intValue;
      start_time[0] = ((NSString*) [date objectAtIndex: 2]).intValue;
      start_time[3] = hour;
      start_time[4] = min;
      start_time[5] = sec;
    } else if (i == count - 1) {
      NSArray* date = [[data objectAtIndex: 2] componentsSeparatedByString: @"/"];
      end_time[1] = ((NSString*) [date objectAtIndex: 0]).intValue;
      end_time[2] = ((NSString*) [date objectAtIndex: 1]).intValue;
      end_time[0] = ((NSString*) [date objectAtIndex: 2]).intValue;
      end_time[3] = hour;
      end_time[4] = min;
      end_time[5] = sec;
    }
  }
  NSLog(@"distance: %f", dist);
  int time = [self time: start_time endTime: end_time];
  NSLog(@"time: %d", time);
  [db query: [NSString stringWithFormat: @"UPDATE \"Routes\" SET \"Distance\" = %f, \"Time\" = %d, \"Year\" = %d, \"Month\" = %d, \"Day\" = %d WHERE \"ID\" IS %lld;", dist, time, start_time[0], start_time[1], start_time[2], rid]];
}

//use haversine formula to compute the distance b/w two pairs of coordinates
- (double) distance: (double*) p1 secondPoint: (double*) p2 {
  double lat1 = to_rad(p1[0]);
  double lat2 = to_rad(p2[0]);
  double lon1 = to_rad(p1[1]);
  double lon2 = to_rad(p1[1]);
  double t1 = pow(sin((lat2 - lat1) / 2), 2);
  double t2 = pow(sin((lon2 - lon1) / 2), 2);
  double t3 = cos(lat1) * cos(lat2) * t2;
  return 2 * RADIUS * asin(sqrt(t1 + t3));
}

//compute difference in times from start and end
- (int) time: (int*) start endTime: (int*) end {
  struct tm s = {.tm_year = start[0] - 1900,
                 .tm_mon = start[1] - 1,
                 .tm_mday = start[2],
                 .tm_hour = start[3],
                 .tm_min = start[4],
                 .tm_sec = start[5],
                 .tm_isdst = -1};
  struct tm e = {.tm_year = end[0] - 1900,
                 .tm_mon = end[1] - 1,
                 .tm_mday = end[2],
                 .tm_hour = end[3],
                 .tm_min = end[4],
                 .tm_sec = end[5],
                 .tm_isdst = -1};
  return mktime(&e) - mktime(&s);
}

#pragma mark - CBPeripheralDelegate

//called when the peripheral's service has been discovered by the method
//discoverServices:
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    NSLog(@"in peripheral:didDiscoverServices");
    NSArray *services = nil;
    NSArray *uuidsForBTService = @[RX_UUID, TX_UUID];
    
    if (peripheral != self.peripheral) {
        //NSLog(@"Wrong Peripheral.\n");
        return ;
    }
    
    if (error != nil) {
        //NSLog(@"Error %@\n", error);
        return ;
    }
    
    services = [peripheral services];
    if (!services || ![services count]) {
        //NSLog(@"No Services");
        return ;
    }
    
    for (CBService *service in services) {
        if ([[service UUID] isEqual:BLE_UUID]) {
            [peripheral discoverCharacteristics:uuidsForBTService forService:service];
        }
    }
}

//called when peripheral discovers a characteristics to connect to for a
//service by the method discoverCharacteristics:forService:
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    NSLog(@"in peripheral:didDiscoverCharacteristicsForService");
    NSArray     *characteristics    = [service characteristics];
    
    if (peripheral != self.peripheral) {
        //NSLog(@"Wrong Peripheral.\n");
        return ;
    }
    
    if (error != nil) {
        //NSLog(@"Error %@\n", error);
        return ;
    }
    
    for (CBCharacteristic *characteristic in characteristics) {
        if ([[characteristic UUID] isEqual: RX_UUID]) {
            NSLog(@"discovered RX_UUID characteristic");
            self.readCharacteristic = characteristic;
            [discoveredCharacteristics setValue: @YES forKey: @"RX"];
        } else if ([[characteristic UUID] isEqual: TX_UUID]) {
            NSLog(@"discovered TX_UUID characteristic");
            self.writeCharacteristic = characteristic;
            [discoveredCharacteristics setValue: @YES forKey: @"TX"];
        }
            
        // Send notification that Bluetooth is connected and all required characteristics are discovered
        if ([discoveredCharacteristics valueForKey: @"RX"] && [discoveredCharacteristics valueForKey: @"TX"]) {
            [self sendBTServiceNotificationWithIsBluetoothConnected:YES];
        }
    }
}

#pragma mark - Private

- (void)sendBTServiceNotificationWithIsBluetoothConnected:(BOOL)isBluetoothConnected {
    NSDictionary *connectionDetails = @{@"isConnected": @(isBluetoothConnected)};
    [[NSNotificationCenter defaultCenter] postNotificationName:RWT_BLE_SERVICE_CHANGED_STATUS_NOTIFICATION object:self userInfo:connectionDetails];
}



-(void) readBluetooth:(Database*) db {
    NSLog(@"got inside readBluetooth");
    NSMutableArray *newBluetoothData;
    BOOL newDataExists = true;
    
    while (newDataExists) {
        [self.peripheral readValueForCharacteristic:self.readCharacteristic];
        NSString *newData = [[NSString alloc] initWithData: self.readCharacteristic.value encoding:NSUTF8StringEncoding];
        //NSString *newData = self.readCharacteristic.value.description;
        NSLog(@"newData: %@", newData);
        if ([newData isEqual: @""]){
            newDataExists = false;
            NSLog(@"newData = false");
            
        } else {
            [newBluetoothData addObject: newData];
        }
    }
    NSArray *newFiles = [self writeData:newBluetoothData];
    for (NSString* file in newFiles) {
        [self writeFile: file toDatabase: db];
        [[NSFileManager defaultManager] removeItemAtPath:file error: nil];
    }
    
}


-(NSArray*) writeData:(NSMutableArray*) StringArray{
    
    NSMutableArray *returnArray;
    int count = 0;
    NSString *resultString = @"";
    NSString *path;
    NSFileHandle *fh;
    NSInteger *fileNumber = 0;

    //write data to a local file on your machine
    //for (NSString *entry in StringArray) {
    
    for (NSString* line in StringArray) {
   
        //NSLog(@"string: %@", string);
        if([line isEqualToString: @"start"]) {
            path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent: [NSString stringWithFormat: @"data%ln.txt", fileNumber]];
            fileNumber++;
            [[NSFileManager defaultManager] createFileAtPath:path contents:nil attributes:nil];
            fh = [NSFileHandle fileHandleForWritingAtPath:path];
            //[fh open file]
            [returnArray addObject:path];
        }
        if([line isEqualToString: @"end"]) {
            [fh closeFile];
        }
        
        if(count == 3) { //write to file
            
            //[resultString appendString:(string)];
            resultString = [resultString stringByAppendingString: @", "];
            resultString = [resultString stringByAppendingString: line];
            resultString = [resultString stringByAppendingString: @"\n"];
            //NSLog(@"result: %@", resultString);
            [fh writeData:[resultString dataUsingEncoding:NSUnicodeStringEncoding]];
            //
            count = 0;
        }
        
        else if(count < 3) {
            
            if(count != 0) {
                resultString = [resultString stringByAppendingString: @", "];
                //NSLog(@"result: %@", resultString);
            }
            resultString = [resultString stringByAppendingString:line];
            NSLog(@"result: %@", resultString);
            NSLog(@"string: %@", line);
            count++;
        }
    }
    
    return returnArray;
}

//[fh seekToEndOfFile];


@end
