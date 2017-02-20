//
//  NameChangeViewController.m
//  Arduino_Servo
//
//  Created by Carlos Yasunari on 15/02/15.
//  Copyright (c) 2015 Razeware LLC. All rights reserved.
//

#import "NameChangeViewController.h"
#import "BTService.h"
#import "BTDiscovery.h"

@interface NameChangeViewController ()
@property (weak, nonatomic) IBOutlet UITextField *nameLabel;
@property (nonatomic) BOOL allowTX;
@property (strong, nonatomic) NSTimer *timerTXDelay;



@end

@implementation NameChangeViewController

- (IBAction)changeName:(id)sender {
    if ([BTDiscovery sharedInstance].bleService) { // 4
        NSString *name = [NSString stringWithFormat:@"AT+NAME%@",self.nameLabel.text];
        if([[BTDiscovery sharedInstance].bleService setNewName:name]){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success" message:[NSString stringWithFormat:@"Successfully changed name to %@! Please reset your Manabot to see the new name",self.nameLabel.text] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            [self performSegueWithIdentifier:@"Return to Main Menu" sender:sender];
        }
        // Start delay timer
        self.allowTX = NO;
        if (!self.timerTXDelay) { // 5
            self.timerTXDelay = [NSTimer scheduledTimerWithTimeInterval:0.005 target:self selector:@selector(timerTXDelayElapsed) userInfo:nil repeats:NO];
        }
    }
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [[event allTouches] anyObject];
    if ([_nameLabel isFirstResponder] && [touch view] != _nameLabel) {
        [_nameLabel resignFirstResponder];
    }
    [super touchesBegan:touches withEvent:event];
}

- (void)timerTXDelayElapsed {
    self.allowTX = YES;
    [self stopTimerTXDelay];
    
}

- (void)stopTimerTXDelay {
    if (!self.timerTXDelay) {
        return;
    }
    
    [self.timerTXDelay invalidate];
    self.timerTXDelay = nil;
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
