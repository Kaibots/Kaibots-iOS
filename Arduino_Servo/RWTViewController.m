//
//  RWTViewController.m
//  Arduino_Servo
//
//  Created by Owen Lacy Brown on 5/21/14.
//  Copyright (c) 2014 Razeware LLC. All rights reserved.
//

#import "RWTViewController.h"
#import "BTDiscovery.h"
#import "BTService.h"
#import "DevicesTableViewController.h"

@interface RWTViewController ()
@property (strong, nonatomic) NSTimer *timerTXDelay;
@property (nonatomic) BOOL allowTX;
@property (nonatomic) BOOL isConnected;
@property (nonatomic) BOOL forwardPressed;
@property (nonatomic) BOOL reversePressed;
@property (nonatomic) BOOL hitPressed;
@property (nonatomic) NSString *buttonPressed;
@property (nonatomic) NSString *tiltedTo;
@property (nonatomic) NSString *lastCharacter;
@property (weak, nonatomic) IBOutlet UILabel *connectedToLabel;
@property (weak, nonatomic) IBOutlet UIButton *forwardButton;
@property (weak, nonatomic) IBOutlet UIButton *reverseButton;
@property (nonatomic) uint8_t lastposition;
@end

@implementation RWTViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
  [super viewDidLoad];
    self.buttonPressed = @"none";
    self.tiltedTo = @"none";
    //start accelerometer thread
    self.motionManager = [[CMMotionManager alloc] init];
    self.motionManager.accelerometerUpdateInterval = .05;
    
    [self.motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue]
                                             withHandler:^(CMAccelerometerData *accelerometerData, NSError *error) {
                                                 [self outputAccelerationData:accelerometerData.acceleration];
                                                 if(error){
                                                     NSLog(@"%@", error);
                                                 }
                                             }];
  
  self.allowTX = YES;
  
  // Watch Bluetooth connection
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
}
-(void)outputAccelerationData:(CMAcceleration)acceleration
{
    //if the button is pressed proceed to check what to send
        //if the iPhone is tilted to the left, proceed to send
        if(acceleration.x<-.35){
            self.tiltedTo = @"left";
            if(!self.forwardPressed && !self.reversePressed)
                [self sendPosition:(uint8_t)[@"A" characterAtIndex:0]];
            else if(self.forwardPressed)
                [self sendPosition:(uint8_t)[@"T" characterAtIndex:0]];
            else if(self.reversePressed)
                [self sendPosition:(uint8_t)[@"G" characterAtIndex:0]];
        } else if (acceleration.x>.35){
            self.tiltedTo = @"right";
            if(!self.forwardPressed && !self.reversePressed)
                [self sendPosition:(uint8_t)[@"D" characterAtIndex:0]];
            else if(self.forwardPressed)
                [self sendPosition:(uint8_t)[@"Y" characterAtIndex:0]];
            else if(self.reversePressed)
                [self sendPosition:(uint8_t)[@"J" characterAtIndex:0]];
        } else {
            if(!self.forwardPressed && !self.reversePressed){
            self.tiltedTo = @"none";
                [self sendPosition:(uint8_t)[@"Q" characterAtIndex:0]];
            } else if(self.forwardPressed){
                [self sendPosition:(uint8_t)[@"W" characterAtIndex:0]];
            } else if(self.reversePressed){
                [self sendPosition:(uint8_t)[@"S" characterAtIndex:0]];
            }
        }
    
    
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectionChanged:) name:RWT_BLE_SERVICE_CHANGED_STATUS_NOTIFICATION object:nil];
    if([[DevicesTableViewController robotName] length]){
        self.connectedToLabel.text = [NSString stringWithFormat:@"Connected to %@",[DevicesTableViewController robotName]];
    } else {
        self.connectedToLabel.text = [NSString stringWithFormat:@"Not connected"];
    }
}
- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self name:RWT_BLE_SERVICE_CHANGED_STATUS_NOTIFICATION object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  [self stopTimerTXDelay];
}

#pragma mark - IBActions

- (IBAction)touchForward:(id)sender {
    self.forwardPressed = YES;
    self.buttonPressed = @"forward";
    if([self.tiltedTo isEqual:@"none"])
        [self sendPosition:(uint8_t)[@"W" characterAtIndex:0]];
    else if([self.tiltedTo isEqual:@"left"])
        [self sendPosition:(uint8_t)[@"T" characterAtIndex:0]];
    else if([self.tiltedTo isEqual:@"right"])
        [self sendPosition:(uint8_t)[@"Y" characterAtIndex:0]];
}
- (IBAction)touchUpForward:(id)sender{
    self.forwardPressed = NO;
    self.buttonPressed = @"none";
    [self sendPosition:81];
}
- (IBAction)touchReverse:(id)sender {
    self.reversePressed = YES;
    self.buttonPressed = @"reverse";
    if([self.tiltedTo isEqual:@"none"])
        [self sendPosition:(uint8_t)[@"S" characterAtIndex:0]];
    else if([self.tiltedTo isEqual:@"left"])
        [self sendPosition:(uint8_t)[@"G" characterAtIndex:0]];
    else if([self.tiltedTo isEqual:@"right"])
        [self sendPosition:(uint8_t)[@"J" characterAtIndex:0]];
    
}
- (IBAction)touchUpReverse:(id)sender {
    self.reversePressed = NO;
    self.buttonPressed = @"none";
    [self sendPosition:(uint8_t)[@"Q" characterAtIndex:0]];
}
- (IBAction)touchA:(id)sender {
    self.hitPressed = YES;
    [self sendPosition:(uint8_t)[@"H" characterAtIndex:0]];
}
- (IBAction)touchUpA:(id)sender {
    self.hitPressed = NO;
    self.buttonPressed = @"none";
    [self sendPosition:(uint8_t)[@"E" characterAtIndex:0]];
}


#pragma mark - Private

- (void)connectionChanged:(NSNotification *)notification {
  // Connection status changed. Indicate on GUI.
  self.isConnected = [(NSNumber *) (notification.userInfo)[@"isConnected"] boolValue];
  
  dispatch_async(dispatch_get_main_queue(), ^{
    // Set image based on connection status
    self.imgBluetoothStatus.image = self.isConnected ? [UIImage imageNamed:@"Bluetooth_Connected"]: [UIImage imageNamed:@"Bluetooth_Disconnected"];
      if(self.isConnected){
      if([[DevicesTableViewController robotName] length]){
          self.connectedToLabel.text = [NSString stringWithFormat:@"Connected to %@",[DevicesTableViewController robotName]];
      } else {
          self.connectedToLabel.text = [NSString stringWithFormat:@"Not connected"];
      }
      }
    
  });
}


- (void)sendPosition:(uint8_t)position {
    // Valid position range: 0 to 180
    
    if (!self.allowTX) { // 1
        return;
    }
    if(self.lastposition == position){
        return;
    }
    
    // Send position to BLE Shield (if service exists and is connected)
    if ([BTDiscovery sharedInstance].bleService) { // 4
        char c = position;
        NSLog(@"%c",c);
        [[BTDiscovery sharedInstance].bleService writePosition:position];
        self.lastposition = position;
        // Start delay timer
        self.allowTX = NO;
        if (!self.timerTXDelay) { // 5
            self.timerTXDelay = [NSTimer scheduledTimerWithTimeInterval:0.005 target:self selector:@selector(timerTXDelayElapsed) userInfo:nil repeats:NO];
        }
    }
    
}

- (void)timerTXDelayElapsed {
  self.allowTX = YES;
  [self stopTimerTXDelay];
  
}

- (void)stopTimerTXDelay {
  if (!self.timerTXDelay) {
    return;
  }
  self.timerTXDelay = nil;
}

@end
