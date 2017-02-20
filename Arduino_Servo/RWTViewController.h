//
//  RWTViewController.h
//  Arduino_Servo
//
//  Created by Owen Lacy Brown on 5/21/14.
//  Copyright (c) 2014 Razeware LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>

@interface RWTViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *imgBluetoothStatus;
@property (weak, nonatomic) IBOutlet UISlider *positionSlider;
@property (strong, nonatomic) CMMotionManager *motionManager;

@end
