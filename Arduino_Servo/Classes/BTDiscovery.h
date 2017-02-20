//
//  BTDiscovery.h
//  Arduino_Servo
//
//  Created by Owen Lacy Brown on 5/21/14.
//  Copyright (c) 2014 Razeware LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "BTService.h"


@interface BTDiscovery : NSObject <CBCentralManagerDelegate>

+ (instancetype)sharedInstance;
- (BOOL)connectToPeripheralWithName:(NSString *)name;

@property (strong, nonatomic) BTService *bleService;
@property (strong, nonatomic) NSString *nameToConnectTo;
@property (strong, nonatomic) NSMutableArray *namesArray;
@property (strong, nonatomic) CBCentralManager *centralManager;
@end
