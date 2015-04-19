//
//  BTSendRec.m
//  InPaceTESTER
//
//  Created by calvin hicks on 4/7/15.
//  Copyright (c) 2015 calvin hicks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BTSendRec.h"

@interface BTSendRec()
@property (strong, nonatomic) CBPeripheral *peripheral;
@property (strong, nonatomic) CBCharacteristic *positionCharacteristic;
@end

@implementation BTSendRec

#pragma mark - Lifecycle

- (instancetype)initWithPeripheral:(CBPeripheral *)peripheral {
    self = [super init];
    if (self) {
        self.peripheral = peripheral;
        [self.peripheral setDelegate:self];
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

#pragma mark - CBPeripheralDelegate

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    NSArray *services = nil;
    NSArray *uuidsForBTService = @[TX_UUID];
    
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

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
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
        if ([[characteristic UUID] isEqual:TX_UUID]) {
            self.positionCharacteristic = characteristic;
            
            // Send notification that Bluetooth is connected and all required characteristics are discovered
            [self sendBTServiceNotificationWithIsBluetoothConnected:YES];
        }
    }
}

#pragma mark - Private

- (void)writePosition:(UInt8)position {
    
    // See if characteristic has been discovered before writing to it
    if (!self.positionCharacteristic) {
        return;
    }
    
    NSData  *data   = nil;
    data = [NSData dataWithBytes:&position length:sizeof (position)];
    [self.peripheral writeValue:data forCharacteristic:self.positionCharacteristic type:CBCharacteristicWriteWithResponse];
    
}

- (void)sendBTServiceNotificationWithIsBluetoothConnected:(BOOL)isBluetoothConnected {
    NSDictionary *connectionDetails = @{@"isConnected": @(isBluetoothConnected)};
    [[NSNotificationCenter defaultCenter] postNotificationName:RWT_BLE_SERVICE_CHANGED_STATUS_NOTIFICATION object:self userInfo:connectionDetails];
}

@end