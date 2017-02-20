//
//  DevicesTableViewController.m
//  Arduino_Servo
//
//  Created by Carlos Yasunari on 14/02/15.
//  Copyright (c) 2015 Razeware LLC. All rights reserved.
//

#import "DevicesTableViewController.h"
#import "BTDiscovery.h"
#import "BTService.h"
#import "MenuViewController.h"

@interface DevicesTableViewController ()

@end

@implementation DevicesTableViewController

static NSString *robotName = @"";


-(NSArray *)namesArray{
    if(!_namesArray){
        _namesArray = [[NSArray alloc] init];
    }
    NSLog(@"Created names array!");
    return _namesArray;
}

+(NSString *)robotName{
    return robotName;
}
+(void)setRobotName:(NSString *)robName{
    robotName = robName;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.namesArray = [[NSArray alloc] init];
    self.namesArray = [[BTDiscovery sharedInstance] namesArray];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(discoveredPeripheralNotification:)
                                                 name:@"DiscoveredNotification"
                                               object:nil];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *robName = [self.namesArray objectAtIndex:indexPath.row];
    robotName = robName;
    if([[BTDiscovery sharedInstance] connectToPeripheralWithName:robName]){
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"Success!"
                          message:[NSString stringWithFormat:@"Successfully connected to %@",robName]
                          delegate:self cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
        [alert show];
        [self performSegueWithIdentifier:@"unwindToMainMenu" sender:self];
    }
}
- (void)awakeFromNib{
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.namesArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.textLabel.text = [self.namesArray objectAtIndex:indexPath.row];
    }
    // Configure the cell...
    return cell;
}
- (IBAction)unWindToMainMenu:(id)sender {
        [self performSegueWithIdentifier:@"unwindToMainMenu" sender:self];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.destinationViewController isKindOfClass:[MenuViewController class]]){
        if([segue.identifier isEqualToString:@"unwindToMainMenu"]){
        MenuViewController *mvc = segue.destinationViewController;
        mvc.robotName = [DevicesTableViewController robotName];
        }
    }
}
-(void)discoveredPeripheralNotification:(NSNotification *)notification{
    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    
}
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
