//
//  DevicesTableViewController.h
//  Arduino_Servo
//
//  Created by Carlos Yasunari on 14/02/15.
//  Copyright (c) 2015 Razeware LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DevicesTableViewController : UITableViewController

@property (nonatomic, retain) NSArray *namesArray;

+(NSString *)robotName;
+(void)setRobotName:(NSString *)robotName;
- (IBAction)unWindToMainMenu:(id)sender;
@end
