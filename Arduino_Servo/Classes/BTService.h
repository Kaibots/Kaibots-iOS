//
//  BTService.h
//  Arduino_Servo
//
//  Created by Owen Lacy Brown on 5/21/14.
//  Copyright (c) 2014 Razeware LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

/* Services & Characteristics UUIDs */
#define RWT_BLE_SERVICE_UUID		[CBUUID UUIDWithString:@"0000ffe0-0000-1000-8000-00805f9b34fb"]
#define RWT_POSITION_CHAR_UUID		[CBUUID UUIDWithString:@"0000ffe1-0000-1000-8000-00805f9b34fb"]

/* Notifications */
static NSString* const RWT_BLE_SERVICE_CHANGED_STATUS_NOTIFICATION = @"kBLEServiceChangedStatusNotification";


/* BTService */
@interface BTService : NSObject <CBPeripheralDelegate>

@property  (strong, nonatomic) NSMutableArray *servicesArray;
@property  (strong, nonatomic) NSMutableArray *namesArray;

- (instancetype)initWithPeripheral:(CBPeripheral *)peripheral;
- (void)reset;
- (void)startDiscoveringServices;
- (void)writePosition:(UInt8)position;
- (BOOL)setNewName:(NSString *)name;

@end
