//
//  BTDiscovery.m
//  Arduino_Servo
//
//  Created by Owen Lacy Brown on 5/21/14.
//  Copyright (c) 2014 Razeware LLC. All rights reserved.
//

#import "BTDiscovery.h"


@interface BTDiscovery ()
@property (strong, nonatomic) CBPeripheral *peripheralBLE;
@property (strong, nonatomic) NSMutableArray *arrayOfPeripherals;
// Connected peripheral
@end

@implementation BTDiscovery
@synthesize nameToConnectTo;
#pragma mark - Lifecycle

- (NSMutableArray *)namesArray{
    if(!_namesArray){
        _namesArray = [[NSMutableArray alloc] init];
    }
    return _namesArray;
}
- (NSMutableArray *)arrayOfPeripherals{
    if(!_arrayOfPeripherals){
        _arrayOfPeripherals = [[NSMutableArray alloc] init];
    }
    return _arrayOfPeripherals;
}

+ (instancetype)sharedInstance {
  static BTDiscovery *this = nil;
  static dispatch_once_t onceToken;

  dispatch_once(&onceToken, ^{
    this = [[BTDiscovery alloc] init];
  });
  return this;
}

- (instancetype)init {
  self = [super init];
  if (self) {
    dispatch_queue_t centralQueue = dispatch_queue_create("com.raywenderlich", DISPATCH_QUEUE_SERIAL);
    self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:centralQueue options:nil];
    self.bleService = nil;
  }
  return self;
}

- (void)startScanning {
  [self.centralManager scanForPeripheralsWithServices:@[RWT_BLE_SERVICE_UUID] options:nil];
}

#pragma mark - Custom Accessors

- (void)setBleService:(BTService *)bleService {
  // Using a setter so the service will be properly started and reset
  if (_bleService) {
    [_bleService reset];
    _bleService = nil;
  }
  
  _bleService = bleService;
  if (_bleService) {
    [_bleService startDiscoveringServices];
  }
}

#pragma mark - CBCentralManagerDelegate

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    NSLog(@"Discovered peripheral with name: %@",peripheral.name);
    if(![self.namesArray containsObject:peripheral.name]){
        [self.namesArray addObject:peripheral.name];
    }
  // Be sure to retain the peripheral or it will fail during connection.
  
  // Validate peripheral information
  if (!peripheral || !peripheral.name || ([peripheral.name isEqualToString:@""])) {
    return;
  }
    if (!self.peripheralBLE || (self.peripheralBLE.state == CBPeripheralStateDisconnected)) {
        self.peripheralBLE = peripheral;
        self.peripheralBLE = nil;
    }
  // If not already connected to a peripheral, then connect to this one
    //save the peripherals
    
    if (!self.peripheralBLE || (self.peripheralBLE.state == CBPeripheralStateDisconnected)) {
        [self.arrayOfPeripherals addObject:peripheral];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"DiscoveredNotification" object:self];
    // Retain the peripheral before trying to connect
        //self.peripheralBLE = peripheral;
    
    // Reset service
    //self.bleService = nil;
    
    // Connect to peripheral
    //[self.centralManager connectPeripheral:peripheral options:nil];
        }
}
- (BOOL)connectToPeripheralWithName:(NSString *)name{
    NSLog(@"Called connect to peripheral with name");
    for(CBPeripheral *peripheral in self.arrayOfPeripherals){
        if([peripheral.name isEqualToString:name]){
            //if not connected
            if(peripheral.state != CBPeripheralStateConnected){
            //Retain the peripheral before trying to connect
            self.peripheralBLE = peripheral;
            //Reset the service
            self.bleService = nil;
            //Connect to the peripheral
            [self.centralManager connectPeripheral:peripheral options:nil];
            
                return YES;
            }
        }
    }
    return NO;
}


- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
  
  if (!peripheral) {
    return;
  }
  
  // Create new service class
  if (peripheral == self.peripheralBLE) {
    self.bleService = [[BTService alloc] initWithPeripheral:peripheral];
  }
  
  // Stop scanning for new devices
  [self.centralManager stopScan];
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
  
  if (!peripheral) {
    return;
  }
  
  // See if it was our peripheral that disconnected
  if (peripheral == self.peripheralBLE) {
    self.bleService = nil;
      self.peripheralBLE = nil;
      [self.arrayOfPeripherals removeAllObjects];
      [self.namesArray removeAllObjects];
  }
  
  // Start scanning for new devices
  [self startScanning];
}

#pragma mark - Private

- (void)clearDevices {
  self.bleService = nil;
  self.peripheralBLE = nil;
    [self.arrayOfPeripherals removeAllObjects];
    [self.namesArray removeAllObjects];
}
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
  switch (self.centralManager.state) {
    case CBCentralManagerStatePoweredOff:
    {
      [self clearDevices];
      break;
    }
      
    case CBCentralManagerStateUnauthorized:
    {
      // Indicate to user that the iOS device does not support BLE.
      break;
    }
      
    case CBCentralManagerStateUnknown:
    {
      // Wait for another event
      break;
    }
      
    case CBCentralManagerStatePoweredOn:
    {
      [self clearDevices];
      [self startScanning];
        
      break;
    }
      
    case CBCentralManagerStateResetting:
    {
      [self clearDevices];
      break;
    }
      
    case CBCentralManagerStateUnsupported:
    {
      break;
    }
      
    default:
      break;
  }
  
}

@end
