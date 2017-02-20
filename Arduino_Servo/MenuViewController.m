//
//  MenuViewController.m
//  Arduino_Servo
//
//  Created by Carlos Yasunari on 15/02/15.
//  Copyright (c) 2015 Razeware LLC. All rights reserved.
//

#import "MenuViewController.h"
#import "DevicesTableViewController.h"
#import "BTDiscovery.h"
#import "BTService.h"

@interface MenuViewController ()
@property (weak, nonatomic) IBOutlet UIButton *connectedButton;
@property int CBState;

@end

@implementation MenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    if(self.robotName.length > 0)
        {
            [self.connectedButton setTitle:[NSString stringWithFormat:@"Connected to: %@",self.robotName] forState:UIControlStateNormal];
        }
    else
        {
            [self.connectedButton setTitle:@"Not connected" forState:UIControlStateNormal];
        }
    [BTDiscovery sharedInstance];
}

- (IBAction)scanButton:(id)sender {
    if([self checkIfBluetoothisOn]){
        [self performSegueWithIdentifier:@"Go to Devices TVC" sender:self];
    }
}
- (IBAction)nameButton:(id)sender {
    if([self checkIfBluetoothisOn]){
        if([BTDiscovery sharedInstance])
        [self performSegueWithIdentifier:@"Go to Change Name" sender:self];
    }
}
-(BOOL)checkIfBluetoothisOn{
    if([BTDiscovery sharedInstance].centralManager.state == CBCentralManagerStatePoweredOn){
        return YES;
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Please turn bluetooth on" message:@"" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return NO;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
}
- (IBAction)returnToMainMenu:(UIStoryboardSegue *)segue {
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
