/*
 *  deviceSelector.m
 *
 * Created by Ole Andreas Torvmark on 10/2/12.
 * Copyright (c) 2012 Texas Instruments Incorporated - http://www.ti.com/
 * ALL RIGHTS RESERVED
 */

#import "deviceSelector.h"
#import "StrengthMachineActivityViewController.h"


//The following is a Category declaration.  Used to add methods to an
//existing class. It does not indicate inheritance from a subclass.
//The category name appears inside the brackets.
//This does nothing here
@interface deviceSelector ()

@end

@implementation deviceSelector
@synthesize m,nDevices,sensorTags;







- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    // Custom initialization
    
    self.m = [[CBCentralManager alloc]initWithDelegate:self queue:nil];
    self.nDevices = [[NSMutableArray alloc]init];
    self.sensorTags = [[NSMutableArray alloc]init];
    self.title = @"Select A Machine";
    self.equipment = [[fitnessEquipInventory alloc]init];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    self.m.delegate = self;
    [self.m scanForPeripheralsWithServices:nil options:nil];
    
   // if (!self.m) self.m = [[CBCentralManager alloc]initWithDelegate:self queue:nil];
  //  else self.m.delegate = self;

  //  if (!self.nDevices) self.nDevices = [[NSMutableArray alloc]init];
 //   if (!self.sensorTags) self.sensorTags = [[NSMutableArray alloc]init];
    
 //   if (!self.equipment) self.equipment = [[fitnessEquipInventory alloc]init];
 //   self.title = @"Equipment Found";
      //   self.m.delegate = self;
    
    // extend the background image under the navigation bar and make it translucent
   
    UINavigationBar *vc;
    vc = (UINavigationBar*) [self.navigationController navigationBar];
    [vc setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    vc.translucent = YES;

    
    //Set background color to transparent, create a background subview and send it to the bottom (changed this for NFC demo
    //self.view.backgroundColor = [UIColor clearColor];
    //UIImageView *backgroundImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"Ft_Sanders_Background.png"]];
    //[self.navigationController.view addSubview:backgroundImageView];
    //[self.navigationController.view sendSubviewToBack: backgroundImageView];

    //UIImageView *backgroundImageView = [[UIImageView alloc]init];
    //[backgroundImageView sizeToFit];  // could have eliminated this wit
    //backgroundImageView.image = [UIImage imageNamed:@"Ft_Sanders_Background.png"];
    

    

    // Note:  had thr following which required call to sizeToFit to initialze the rect before it would display
    //UIImageView *backgroundImageView = [[UIImageView alloc]init];
    //[backgroundImageView sizeToFit];  // could have eliminated this wit
    //backgroundImageView.image = [UIImage imageNamed:@"Ft_Sanders_Background.png"];

    
}





#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return sensorTags.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:[NSString stringWithFormat:@"%d_Cell",indexPath.row]];
    deviceCellTemplate *cell = [[deviceCellTemplate alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[NSString stringWithFormat:@"%d_Cell",indexPath.row]];
    CBPeripheral *p = [self.sensorTags objectAtIndex:indexPath.row];
    
    // Use UUID to look up machine from inventory
    gymEquipment *machineFound = [self.equipment findEquipmentInInventory:[NSString stringWithFormat:@"%@",p.identifier]];
    

    cell.deviceName.text = [NSString stringWithFormat:@"%@",machineFound.gymEquipName];
    //cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",CFUUIDCreateString(nil, p.UUID)];
    cell.deviceIcon.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@",machineFound.gymEquipImage]];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}



-(NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//    if (section == 0) {
//        if (self.sensorTags.count > 1 )return [NSString stringWithFormat:@""];
//        else return [NSString stringWithFormat:@"Searching for Equipment"];
//    }
    
    return @"";
}

-(float) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 120;
}

#pragma mark - Table view delegate
/* A Sensortag was selected from the table.  We need to create a SensorTagApplicaitionViewController and make it the active viewcontroller
*/

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    CBPeripheral *p = [self.sensorTags objectAtIndex:indexPath.row];
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    BLEDevice *d = [[BLEDevice alloc]init];
    
    d.p = p;
    d.manager = self.m;
    d.setupData = [self makeSensorTagConfiguration];
    d.machine = [self.equipment findEquipmentInInventory:[NSString stringWithFormat:@"%@",p.identifier]];
    
    
     StrengthMachineActivityViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"strengthWorkout"];
     [self.navigationController pushViewController:controller animated:YES];
     controller.d = d;
     Speak *speaker = [[Speak alloc]init];
     [speaker speakText:d.machine.gymEquipName];
    
 
 }


    /* Instantiate the STAVC */
    // BG NEED TO FIX THIS BECAUSE TVC WAS CONVERTED TO A VC
   // SensorTagApplicationViewController *vC = [[SensorTagApplicationViewController alloc]init];
    //vC.d = d;
    
    /* Find the nearest ancestor navigation controller and push the new
     * SensorTagApplicationViewController on the stack to make
     * it the active view controller
    */
    //[self.navigationController pushViewController:vC animated:YES];
    
    /* - (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath    *)indexPath {
        UIViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"drivingDetails"];
        controller.title = [[dao libraryItemAtIndex:indexPath.row] valueForKey:@"name"];
        [self.navigationController pushViewController:controller animated:YES];
     */

   



- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([[segue identifier] isEqualToString:@"FitNoteMain"]){
       

        
    }
}


#pragma mark - CBCentralManager delegate

-(void)centralManagerDidUpdateState:(CBCentralManager *)central {
    if (central.state != CBCentralManagerStatePoweredOn) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"BLE not supported !" message:[NSString stringWithFormat:@"CoreBluetooth return state: %d",central.state] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
    else {
        [central scanForPeripheralsWithServices:nil options:nil];
    }
}




-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    
    NSLog(@"Found a BLE Device : %@",peripheral);
    
    peripheral.delegate = self;
    if ([peripheral.name isEqualToString:@"TI BLE Sensor Tag"]){
        NSLog(@"Found a SensorTag : %@",peripheral);
        [central connectPeripheral:peripheral options:nil];
    }
    [self.nDevices addObject:peripheral];
    
}

-(void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    [peripheral discoverServices:nil];
}

#pragma  mark - CBPeripheral delegate

-(void) peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    BOOL replace = NO;
    BOOL found = NO;
    NSLog(@"Services scanned !");
    [self.m cancelPeripheralConnection:peripheral];
    for (CBService *s in peripheral.services) {
//        NSLog(@"Service found : %@",s.UUID);
        if ([s.UUID isEqual:[CBUUID UUIDWithString:@"F000AA00-0451-4000-B000-000000000000"]])  {
           NSLog(@"This is a SensorTag !");
            found = YES;
        }
    }
    if (found) {
        // Match if we have this device from before
        for (int ii=0; ii < self.sensorTags.count; ii++) {
            CBPeripheral *p = [self.sensorTags objectAtIndex:ii];
            if ([p isEqual:peripheral]) {
                    [self.sensorTags replaceObjectAtIndex:ii withObject:peripheral];
                    replace = YES;
                }
            }
        if (!replace) {
            [self.sensorTags addObject:peripheral];
            [self.tableView reloadData];
        }
    }
}

-(void) peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    NSLog(@"didUpdateNotificationStateForCharacteristic %@ error = %@",characteristic,error);
}

-(void) peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    NSLog(@"didWriteValueForCharacteristic %@ error = %@",characteristic,error);
}


#pragma mark - SensorTag configuration

-(NSMutableDictionary *) makeSensorTagConfiguration {
    NSMutableDictionary *d = [[NSMutableDictionary alloc] init];
    // First we set ambient temperature
    [d setValue:@"0" forKey:@"Ambient temperature active"];
    // Then we set IR temperature
    [d setValue:@"0" forKey:@"IR temperature active"];
    // Append the UUID to make it easy for app
    [d setValue:@"F000AA00-0451-4000-B000-000000000000"  forKey:@"IR temperature service UUID"];
    [d setValue:@"F000AA01-0451-4000-B000-000000000000" forKey:@"IR temperature data UUID"];
    [d setValue:@"F000AA02-0451-4000-B000-000000000000"  forKey:@"IR temperature config UUID"];
    // Then we setup the accelerometer
    [d setValue:@"1" forKey:@"Accelerometer active"];
    //BG Change accelerometer to 100 msec update from 500
    [d setValue:@"100" forKey:@"Accelerometer period"];
    [d setValue:@"F000AA10-0451-4000-B000-000000000000"  forKey:@"Accelerometer service UUID"];
    [d setValue:@"F000AA11-0451-4000-B000-000000000000"  forKey:@"Accelerometer data UUID"];
    [d setValue:@"F000AA12-0451-4000-B000-000000000000"  forKey:@"Accelerometer config UUID"];
    [d setValue:@"F000AA13-0451-4000-B000-000000000000"  forKey:@"Accelerometer period UUID"];
    //Accelerometer is active so do FitNote
    [d setValue:@"1" forKey:@"FitNote active"];
    
    //Then we setup the rH sensor
    [d setValue:@"0" forKey:@"Humidity active"];
    [d setValue:@"F000AA20-0451-4000-B000-000000000000"   forKey:@"Humidity service UUID"];
    [d setValue:@"F000AA21-0451-4000-B000-000000000000" forKey:@"Humidity data UUID"];
    [d setValue:@"F000AA22-0451-4000-B000-000000000000" forKey:@"Humidity config UUID"];
    
    //Then we setup the magnetometer
    [d setValue:@"0" forKey:@"Magnetometer active"];
    [d setValue:@"500" forKey:@"Magnetometer period"];
    [d setValue:@"F000AA30-0451-4000-B000-000000000000" forKey:@"Magnetometer service UUID"];
    [d setValue:@"F000AA31-0451-4000-B000-000000000000" forKey:@"Magnetometer data UUID"];
    [d setValue:@"F000AA32-0451-4000-B000-000000000000" forKey:@"Magnetometer config UUID"];
    [d setValue:@"F000AA33-0451-4000-B000-000000000000" forKey:@"Magnetometer period UUID"];
    
    //Then we setup the barometric sensor
    [d setValue:@"0" forKey:@"Barometer active"];
    [d setValue:@"F000AA40-0451-4000-B000-000000000000" forKey:@"Barometer service UUID"];
    [d setValue:@"F000AA41-0451-4000-B000-000000000000" forKey:@"Barometer data UUID"];
    [d setValue:@"F000AA42-0451-4000-B000-000000000000" forKey:@"Barometer config UUID"];
    [d setValue:@"F000AA43-0451-4000-B000-000000000000" forKey:@"Barometer calibration UUID"];
    
    [d setValue:@"1" forKey:@"Gyroscope active"];
    [d setValue:@"F000AA50-0451-4000-B000-000000000000" forKey:@"Gyroscope service UUID"];
    [d setValue:@"F000AA51-0451-4000-B000-000000000000" forKey:@"Gyroscope data UUID"];
    [d setValue:@"F000AA52-0451-4000-B000-000000000000" forKey:@"Gyroscope config UUID"];

  //  NSLog(@"%@",d);
    
    return d;
}

@end
