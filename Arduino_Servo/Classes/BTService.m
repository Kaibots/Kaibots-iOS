//
//  BTService.m
//  Arduino_Servo
//
//  Created by Owen Lacy Brown on 5/21/14.
//  Copyright (c) 2014 Razeware LLC. All rights reserved.
//

#import "BTService.h"


@interface BTService()
@property (strong, nonatomic) CBPeripheral *peripheral;
@property (strong, nonatomic) CBCharacteristic *positionCharacteristic;
@end

@implementation BTService

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
- (NSMutableArray *)servicesArray{
    if(!_servicesArray){
        _servicesArray = [[NSMutableArray alloc] init];
    }
    return _servicesArray;
}
- (NSMutableArray *)namesArray{
    if(!_namesArray){
        _namesArray = [[NSMutableArray alloc] init];
    }
    return _namesArray;
}
- (void)startDiscoveringServices {
  [self.peripheral discoverServices:@[RWT_BLE_SERVICE_UUID]];
}

- (void)reset {
  
  if (self.peripheral) {
    self.peripheral = nil;
  }
  
  // Deallocating therefore send notification  
}

#pragma mark - CBPeripheralDelegate
-(void)peripheral:(CBPeripheral *)peripheral didModifyServices:(NSArray *)invalidatedServices{
    NSLog(@"Peripheral modified services!");
}
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    self.servicesArray = nil;
    self.namesArray = nil;
  NSArray *uuidsForBTService = @[RWT_POSITION_CHAR_UUID];
  
  if (peripheral != self.peripheral) {
    //NSLog(@"Wrong Peripheral.\n");
    return ;
  }
  
  if (error != nil) {
    //NSLog(@"Error %@\n", error);
    return ;
  }
    
    self.servicesArray = nil;
  [self.servicesArray addObjectsFromArray:[peripheral services]];
  if (!self.servicesArray || ![self.servicesArray count]) {
    NSLog(@"No Services");
    return ;
  }
  for (CBService *service in self.servicesArray) {
    if ([[service UUID] isEqual:RWT_BLE_SERVICE_UUID]) {
      [peripheral discoverCharacteristics:uuidsForBTService forService:service];
        [self.namesArray addObject:peripheral.name];
    }
  }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
  NSArray *characteristics = [service characteristics];
  if (peripheral != self.peripheral) {
    NSLog(@"Wrong Peripheral.\n");
    return ;
  }
  
  if (error != nil) {
    NSLog(@"Error %@\n", error);
    return ;
  }
  for (CBCharacteristic *characteristic in characteristics) {
    if ([[characteristic UUID] isEqual:RWT_POSITION_CHAR_UUID]) {
      //  if([peripheral.name isEqualToString:self.selectedName]){
      self.positionCharacteristic = characteristic;
      // Send notification that Bluetooth is connected and all required characteristics are discovered
      [self sendBTServiceNotificationWithIsBluetoothConnected:YES];
       // }
    }
  }
}

#pragma mark - Private

- (void)writePosition:(UInt8)position {
    if (!self.positionCharacteristic) {
        NSLog(@"Could not find position characteristic");
        return;
    }
    NSData *data = nil;
    data = [NSData dataWithBytes:&position length:sizeof(position)];
    [self.peripheral writeValue:data
              forCharacteristic:self.positionCharacteristic
                           type:CBCharacteristicWriteWithoutResponse];
}
- (BOOL)setNewName:(NSString *)name{
    
    if (!self.positionCharacteristic) {
        NSLog(@"Could not find position characteristic");
        return NO;
    }
    NSData *data = nil;
    data = [name dataUsingEncoding:NSUTF8StringEncoding];
    [self.peripheral writeValue:data
              forCharacteristic:self.positionCharacteristic
                           type:CBCharacteristicWriteWithoutResponse];
    NSLog(@"Setting new name to %@", name);
    return YES;
}

- (void)sendBTServiceNotificationWithIsBluetoothConnected:(BOOL)isBluetoothConnected {
  NSDictionary *connectionDetails = @{@"isConnected": @(isBluetoothConnected)};
  [[NSNotificationCenter defaultCenter] postNotificationName:RWT_BLE_SERVICE_CHANGED_STATUS_NOTIFICATION object:self userInfo:connectionDetails];
    
}

@end
