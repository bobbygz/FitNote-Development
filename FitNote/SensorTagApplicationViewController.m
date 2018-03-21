/*
 *  SensorTagApplicationViewController.m
 *
 * Created by Ole Andreas Torvmark on 10/2/12.
 * Copyright (c) 2012 Texas Instruments Incorporated - http://www.ti.com/
 * ALL RIGHTS RESERVED
 */

#import "SensorTagApplicationViewController.h"
#import "deviceCellTemplate.h"

@interface SensorTagApplicationViewController ()

@end

@implementation SensorTagApplicationViewController

@synthesize d;
@synthesize sensorsEnabled;
@synthesize exerciseActivities;
@synthesize fnSensor;
@synthesize tv;


// BG*** Need to change this so that it doesnt reallocate when the view reappears
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated{
    
   }

-(void)viewWillDisappear:(BOOL)animated {
    [self deconfigureSensorTag];
    
}

-(void)viewDidDisappear:(BOOL)animated {
    self.sensorsEnabled = nil;
    self.d.manager.delegate = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;

    
    UIBarButtonItem *mailer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(sendMail:)];
    
    [self.navigationItem setRightBarButtonItem:mailer];
    
    
    //Set background color to transparent, create a background subview and send it to the bottom
    self.view.backgroundColor = [UIColor clearColor];
    UIImageView *backgroundImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"Ft_Sanders_Background.png"]];
    //UIImageView *backgroundImageView = [[UIImageView alloc]init];
    //[backgroundImageView sizeToFit];  // could have eliminated this wit
    //backgroundImageView.image = [UIImage imageNamed:@"Ft_Sanders_Background.png"];
    [self.navigationController.view addSubview:backgroundImageView];
    [self.navigationController.view sendSubviewToBack: backgroundImageView];
    
    if (!self.magSensor) self.magSensor = [[sensorMAG3110 alloc] init];
    if (!self.gyroSensor) self.gyroSensor = [[sensorIMU3000 alloc] init];
    if (!self.fnSensor) self.fnSensor = [[sensorFitnote alloc] init];
    if (!self.sensorsEnabled)
    {
        self.sensorsEnabled = [[NSMutableArray alloc] init];
        [self configureSensorTag];
    }
    if (!self.exerciseActivities) self.exerciseActivities = [[NSMutableArray alloc]init];
    
    
    
    // Make self the delegate for the manager if not yet connected
    if (self.d.p.state != CBPeripheralStateConnected) {
        self.d.manager.delegate = self;
        [self.d.manager connectPeripheral:self.d.p options:nil];
    }
    // Otherwise make self the delegate for the peripheral
    else {
        self.d.p.delegate = self;
        [self configureSensorTag];
        
        self.title = @"Workout Progress";
    }
    if (!tv){
        tv = [[SensorTagTableView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame] style:UITableViewStylePlain];
        tv.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        tv.backgroundColor = [UIColor clearColor];
        [tv initializeSensorTagCells];
        tv.containingViewController = self;
        tv.delegate = self;
        tv.dataSource = self;
        [tv reloadData];
        [self.view addSubview:tv];
        
    }

    
    // Objects to hold current SensorTag values and samples
    if (!self.currentVal) self.currentVal = [[sensorTagValues alloc]init];
    if (!self.vals) self.vals = [[NSMutableArray alloc]init];
    
    
    // Provide access to ViewController properties for the TableView
    //    CGRect tableFrame;
    //    tableFrame = CGRectMake(0, 64, 320, 320-64);
    //    if (!tv) {
    //        tv = [[SensorTagTableView alloc]initWithFrame:tableFrame style:UITableViewStyleGrouped];
    //        tv.dataSource = self;
    //        tv.delegate = self;
    //        tv.containingViewController = self;
    //        [tv reloadData];
    //        [self.view addSubview:tv];
    //    }

    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


-(void) configureSensorTag {
    // Configure sensortag, turning on Sensors and setting update period for sensors etc ...
    
    if (([self sensorEnabled:@"Ambient temperature active"]) || ([self sensorEnabled:@"IR temperature active"])) {
        // Enable Temperature sensor
        CBUUID *sUUID = [CBUUID UUIDWithString:[self.d.setupData valueForKey:@"IR temperature service UUID"]];
        CBUUID *cUUID = [CBUUID UUIDWithString:[self.d.setupData valueForKey:@"IR temperature config UUID"]];
        uint8_t data = 0x01;
        [BLEUtility writeCharacteristic:self.d.p sCBUUID:sUUID cCBUUID:cUUID data:[NSData dataWithBytes:&data length:1]];
        cUUID = [CBUUID UUIDWithString:[self.d.setupData valueForKey:@"IR temperature data UUID"]];
        [BLEUtility setNotificationForCharacteristic:self.d.p sCBUUID:sUUID cCBUUID:cUUID enable:YES];
        
        if ([self sensorEnabled:@"Ambient temperature active"]) [self.sensorsEnabled addObject:@"Ambient temperature"];
        if ([self sensorEnabled:@"IR temperature active"]) [self.sensorsEnabled addObject:@"IR temperature"];
        
    }
    
    if ([self sensorEnabled:@"Accelerometer active"]) {
        CBUUID *sUUID = [CBUUID UUIDWithString:[self.d.setupData valueForKey:@"Accelerometer service UUID"]];
        CBUUID *cUUID = [CBUUID UUIDWithString:[self.d.setupData valueForKey:@"Accelerometer config UUID"]];
        CBUUID *pUUID = [CBUUID UUIDWithString:[self.d.setupData valueForKey:@"Accelerometer period UUID"]];
        NSInteger period = [[self.d.setupData valueForKey:@"Accelerometer period"] integerValue];
        uint8_t periodData = (uint8_t)(period / 10);
//        NSLog(@"%d",periodData);
        [BLEUtility writeCharacteristic:self.d.p sCBUUID:sUUID cCBUUID:pUUID data:[NSData dataWithBytes:&periodData length:1]];
        uint8_t data = 0x01;
        [BLEUtility writeCharacteristic:self.d.p sCBUUID:sUUID cCBUUID:cUUID data:[NSData dataWithBytes:&data length:1]];
        cUUID = [CBUUID UUIDWithString:[self.d.setupData valueForKey:@"Accelerometer data UUID"]];
        [BLEUtility setNotificationForCharacteristic:self.d.p sCBUUID:sUUID cCBUUID:cUUID enable:YES];
        [self.sensorsEnabled addObject:@"Accelerometer"];
        
        
    }
    
     if ([self sensorEnabled:@"FitNote active"]) {
         //BG Add FitNote to the sensorsEnabled dictionary
         [self.sensorsEnabled addObject:@"Fitnote"];
    }
    
    if ([self sensorEnabled:@"Humidity active"]) {
        CBUUID *sUUID = [CBUUID UUIDWithString:[self.d.setupData valueForKey:@"Humidity service UUID"]];
        CBUUID *cUUID = [CBUUID UUIDWithString:[self.d.setupData valueForKey:@"Humidity config UUID"]];
        uint8_t data = 0x01;
        [BLEUtility writeCharacteristic:self.d.p sCBUUID:sUUID cCBUUID:cUUID data:[NSData dataWithBytes:&data length:1]];
        cUUID = [CBUUID UUIDWithString:[self.d.setupData valueForKey:@"Humidity data UUID"]];
        [BLEUtility setNotificationForCharacteristic:self.d.p sCBUUID:sUUID cCBUUID:cUUID enable:YES];
        [self.sensorsEnabled addObject:@"Humidity"];
    }
    
    if ([self sensorEnabled:@"Barometer active"]) {
        CBUUID *sUUID = [CBUUID UUIDWithString:[self.d.setupData valueForKey:@"Barometer service UUID"]];
        CBUUID *cUUID = [CBUUID UUIDWithString:[self.d.setupData valueForKey:@"Barometer config UUID"]];
        //Issue calibration to the device 
        uint8_t data = 0x02;
        [BLEUtility writeCharacteristic:self.d.p sCBUUID:sUUID cCBUUID:cUUID data:[NSData dataWithBytes:&data length:1]];
        cUUID =  [CBUUID UUIDWithString:[self.d.setupData valueForKey:@"Barometer data UUID"]];
        [BLEUtility setNotificationForCharacteristic:self.d.p sCBUUID:sUUID cCBUUID:cUUID enable:YES];
        
        cUUID =  [CBUUID UUIDWithString:[self.d.setupData valueForKey:@"Barometer calibration UUID"]];
        [BLEUtility readCharacteristic:self.d.p sCBUUID:sUUID cCBUUID:cUUID];
        [self.sensorsEnabled addObject:@"Barometer"];
    }
    if ([self sensorEnabled:@"Gyroscope active"]) {
        CBUUID *sUUID =  [CBUUID UUIDWithString:[self.d.setupData valueForKey:@"Gyroscope service UUID"]];
        CBUUID *cUUID =  [CBUUID UUIDWithString:[self.d.setupData valueForKey:@"Gyroscope config UUID"]];
        uint8_t data = 0x07;
        [BLEUtility writeCharacteristic:self.d.p sCBUUID:sUUID cCBUUID:cUUID data:[NSData dataWithBytes:&data length:1]];
        cUUID =  [CBUUID UUIDWithString:[self.d.setupData valueForKey:@"Gyroscope data UUID"]];
        [BLEUtility setNotificationForCharacteristic:self.d.p sCBUUID:sUUID cCBUUID:cUUID enable:YES];
        [self.sensorsEnabled addObject:@"Gyroscope"];
    }
    
    if ([self sensorEnabled:@"Magnetometer active"]) {
        CBUUID *sUUID = [CBUUID UUIDWithString:[self.d.setupData valueForKey:@"Magnetometer service UUID"]];
        CBUUID *cUUID = [CBUUID UUIDWithString:[self.d.setupData valueForKey:@"Magnetometer config UUID"]];
        CBUUID *pUUID = [CBUUID UUIDWithString:[self.d.setupData valueForKey:@"Magnetometer period UUID"]];
        NSInteger period = [[self.d.setupData valueForKey:@"Magnetometer period"] integerValue];
        uint8_t periodData = (uint8_t)(period / 10);
        NSLog(@"%d",periodData);
        [BLEUtility writeCharacteristic:self.d.p sCBUUID:sUUID cCBUUID:pUUID data:[NSData dataWithBytes:&periodData length:1]];
        uint8_t data = 0x01;
        [BLEUtility writeCharacteristic:self.d.p sCBUUID:sUUID cCBUUID:cUUID data:[NSData dataWithBytes:&data length:1]];
        cUUID = [CBUUID UUIDWithString:[self.d.setupData valueForKey:@"Magnetometer data UUID"]];
        [BLEUtility setNotificationForCharacteristic:self.d.p sCBUUID:sUUID cCBUUID:cUUID enable:YES];
        [self.sensorsEnabled addObject:@"Magnetometer"];
    }
    
}

//BG Called when navigation controller back button is pressed
-(void) deconfigureSensorTag {
    if (([self sensorEnabled:@"Ambient temperature active"]) || ([self sensorEnabled:@"IR temperature active"])) {
        // Enable Temperature sensor
        CBUUID *sUUID =  [CBUUID UUIDWithString:[self.d.setupData valueForKey:@"IR temperature service UUID"]];
        CBUUID *cUUID =  [CBUUID UUIDWithString:[self.d.setupData valueForKey:@"IR temperature config UUID"]];
        unsigned char data = 0x00;
        [BLEUtility writeCharacteristic:self.d.p sCBUUID:sUUID cCBUUID:cUUID data:[NSData dataWithBytes:&data length:1]];
        cUUID =  [CBUUID UUIDWithString:[self.d.setupData valueForKey:@"IR temperature data UUID"]];
        [BLEUtility setNotificationForCharacteristic:self.d.p sCBUUID:sUUID cCBUUID:cUUID enable:NO];
    }
    if ([self sensorEnabled:@"Accelerometer active"]) {
        CBUUID *sUUID =  [CBUUID UUIDWithString:[self.d.setupData valueForKey:@"Accelerometer service UUID"]];
        CBUUID *cUUID =  [CBUUID UUIDWithString:[self.d.setupData valueForKey:@"Accelerometer config UUID"]];
        uint8_t data = 0x00;
        [BLEUtility writeCharacteristic:self.d.p sCBUUID:sUUID cCBUUID:cUUID data:[NSData dataWithBytes:&data length:1]];
        cUUID =  [CBUUID UUIDWithString:[self.d.setupData valueForKey:@"Accelerometer data UUID"]];
        [BLEUtility setNotificationForCharacteristic:self.d.p sCBUUID:sUUID cCBUUID:cUUID enable:NO];
    }
    if ([self sensorEnabled:@"Humidity active"]) {
        CBUUID *sUUID =  [CBUUID UUIDWithString:[self.d.setupData valueForKey:@"Humidity service UUID"]];
        CBUUID *cUUID =  [CBUUID UUIDWithString:[self.d.setupData valueForKey:@"Humidity config UUID"]];
        uint8_t data = 0x00;
        [BLEUtility writeCharacteristic:self.d.p sCBUUID:sUUID cCBUUID:cUUID data:[NSData dataWithBytes:&data length:1]];
        cUUID =  [CBUUID UUIDWithString:[self.d.setupData valueForKey:@"Humidity data UUID"]];
        [BLEUtility setNotificationForCharacteristic:self.d.p sCBUUID:sUUID cCBUUID:cUUID enable:NO];
    }
    if ([self sensorEnabled:@"Magnetometer active"]) {
        CBUUID *sUUID =  [CBUUID UUIDWithString:[self.d.setupData valueForKey:@"Magnetometer service UUID"]];
        CBUUID *cUUID =  [CBUUID UUIDWithString:[self.d.setupData valueForKey:@"Magnetometer config UUID"]];
        uint8_t data = 0x00;
        [BLEUtility writeCharacteristic:self.d.p sCBUUID:sUUID cCBUUID:cUUID data:[NSData dataWithBytes:&data length:1]];
        cUUID =  [CBUUID UUIDWithString:[self.d.setupData valueForKey:@"Magnetometer data UUID"]];
        [BLEUtility setNotificationForCharacteristic:self.d.p sCBUUID:sUUID cCBUUID:cUUID enable:NO];
    }
    if ([self sensorEnabled:@"Gyroscope active"]) {
        CBUUID *sUUID =  [CBUUID UUIDWithString:[self.d.setupData valueForKey:@"Gyroscope service UUID"]];
        CBUUID *cUUID =  [CBUUID UUIDWithString:[self.d.setupData valueForKey:@"Gyroscope config UUID"]];
        uint8_t data = 0x00;
        [BLEUtility writeCharacteristic:self.d.p sCBUUID:sUUID cCBUUID:cUUID data:[NSData dataWithBytes:&data length:1]];
        cUUID =  [CBUUID UUIDWithString:[self.d.setupData valueForKey:@"Gyroscope data UUID"]];
        [BLEUtility setNotificationForCharacteristic:self.d.p sCBUUID:sUUID cCBUUID:cUUID enable:NO];
    }
    if ([self sensorEnabled:@"Barometer active"]) {
        CBUUID *sUUID = [CBUUID UUIDWithString:[self.d.setupData valueForKey:@"Barometer service UUID"]];
        CBUUID *cUUID = [CBUUID UUIDWithString:[self.d.setupData valueForKey:@"Barometer config UUID"]];
        //Disable sensor
        uint8_t data = 0x00;
        [BLEUtility writeCharacteristic:self.d.p sCBUUID:sUUID cCBUUID:cUUID data:[NSData dataWithBytes:&data length:1]];
        cUUID =  [CBUUID UUIDWithString:[self.d.setupData valueForKey:@"Barometer data UUID"]];
        [BLEUtility setNotificationForCharacteristic:self.d.p sCBUUID:sUUID cCBUUID:cUUID enable:NO];
        
    }
}

-(bool)sensorEnabled:(NSString *)Sensor {
    NSString *val = [self.d.setupData valueForKey:Sensor];
    if (val) {
        if ([val isEqualToString:@"1"]) return TRUE;
    }
    return FALSE;
}

-(int)sensorPeriod:(NSString *)Sensor {
    NSString *val = [self.d.setupData valueForKey:Sensor];
    return [val integerValue];
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        NSString *cellType = [self.sensorsEnabled objectAtIndex:indexPath.row];
        
        if ([cellType isEqualToString:@"Ambient temperature"]) return tv.ambientTemp.height;
        if ([cellType isEqualToString:@"IR temperature"]) return tv.irTemp.height;
        //if ([cellType isEqualToString:@"Accelerometer"]) return tv.acc.height;
        if ([cellType isEqualToString:@"Accelerometer"]) return 0;  /*  don't display the accelerometer cell */
        if ([cellType isEqualToString:@"Humidity"]) return tv.rH.height;
        if ([cellType isEqualToString:@"Magnetometer"]) return tv.mag.height;
        if ([cellType isEqualToString:@"Barometer"]) return tv.baro.height;
        if ([cellType isEqualToString:@"Gyroscope"]) return 0;
        if ([cellType isEqualToString:@"Fitnote"]) return tv.fitnote.height;
        return 50;
        
        
    }
    else if (indexPath.section==1)
        return 100;
    else return 50;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    // Return the number of rows in the section.
    if (section ==0)
        return 2;
    
    else if (section == 1)
        return tv.exerciseActivitiesCells.count;
    else return 0;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *) tableView
{
    // Return the number of sections.
    return 2;
}

//BG Initialize table section title only for the first section
-(NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"Recording Workout";
    }
    return @"";
}

//BG Ths provides the cell object for display
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.section == 0){
        NSString *cellType = [self.sensorsEnabled objectAtIndex:indexPath.row];
        
        if ([cellType isEqualToString:@"Ambient temperature"]) {
            
            return tv.ambientTemp;
        }
        else if ([cellType isEqualToString:@"IR temperature"]) {
            return tv.irTemp;
        }
        else if ([cellType isEqualToString:@"Accelerometer"]) {
            return tv.acc;
        }
        else if ([cellType isEqualToString:@"Humidity"]) {
            return tv.rH;
        }
        else if ([cellType isEqualToString:@"Barometer"]) {
            return tv.baro;
        }
        else if ([cellType isEqualToString:@"Gyroscope"]) {
            return tv.gyro;
        }
        else if ([cellType isEqualToString:@"Magnetometer"]) {
            return tv.mag;
        }
        
        else if ([cellType isEqualToString:@"Fitnote"]) {
            return tv.fitnote;
        }
    }
    else if (indexPath.section ==1 ) {
        // NSString *cellType = @"ExerciseSet";
        
        ExerciseSetCellTemplate *cellData = [tv.exerciseActivitiesCells objectAtIndex:indexPath.row];
        
        return cellData;
        
    }
    
    
    // Something has gone wrong, because we should never get here, return empty cell
    return [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Unkown Cell"];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}


#pragma mark - CBCentralManager delegate function 

-(void) centralManagerDidUpdateState:(CBCentralManager *)central {
    
}

-(void) centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    peripheral.delegate = self;
    [peripheral discoverServices:nil];
}


#pragma mark - CBperipheral delegate functions

-(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
//    NSLog(@"..");
    if ([service.UUID isEqual:[CBUUID UUIDWithString:[self.d.setupData valueForKey:@"Gyroscope service UUID"]]]) {
      [self configureSensorTag];
    }
}

-(void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
//    NSLog(@".");
    for (CBService *s in peripheral.services) [peripheral discoverCharacteristics:nil forService:s];
}

-(void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    NSLog(@"didUpdateNotificationStateForCharacteristic %@, error = %@",characteristic.UUID, error);
}


//BG Peripheral Delegate callback when Characteristic is updated by Central Manager
//  Calculate and store the values in self.current.val.?? and update the appropriae cell view object
-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    //NSLog(@"didUpdateValueForCharacteristic = %@",characteristic.UUID);
    
    //[NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(alphaFader:) userInfo:nil repeats:YES];
    
        //self.fnSensor = [[sensorFitnote alloc] init];
    //self.fnSensor = [[sensorFitnote alloc] initWithPointerToArrayOfSensorTagValues:self.vals];
    
    
    //BG
    //self.logInterval = 1; //1 seconds
    
    //    self.logTimer = [NSTimer scheduledTimerWithTimeInterval:self.logInterval target:self selector:@selector(logValues:) userInfo:nil repeats:YES];

    
    //Get timestamp as a float for logging and calculations
    self.currentVal.timeInMillseconds = [[NSDate date] timeIntervalSince1970];
    self.currentVal.accelEventFlag = @"NO";
    self.currentVal.gyroEventFlag = @"NO";
    
    
    
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:[self.d.setupData valueForKey:@"IR temperature data UUID"]]]) {
        float tAmb = [sensorTMP006 calcTAmb:characteristic.value];
        float tObj = [sensorTMP006 calcTObj:characteristic.value];
        
   
        // OLD CODE TO UPDATE THE CELL VIEW
        tv.ambientTemp.temperature.text = [NSString stringWithFormat:@"%.1f°C",tAmb];
        tv.ambientTemp.temperature.textColor = [UIColor blackColor];
        tv.ambientTemp.temperatureGraph.progress = (tAmb / 100.0) + 0.5;
        tv.irTemp.temperature.text = [NSString stringWithFormat:@"%.1f°C",tObj];
        tv.irTemp.temperatureGraph.progress = (tObj / 1000.0) + 0.5;
        tv.irTemp.temperature.textColor = [UIColor blackColor];
     
        self.currentVal.tAmb = tAmb;
        self.currentVal.tIR = tObj;
        
     
 
    }
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:[self.d.setupData valueForKey:@"Accelerometer data UUID"]]]) {
        float x = [sensorKXTJ9 calcXValue:characteristic.value];
        float y = [sensorKXTJ9 calcYValue:characteristic.value];
        float z = [sensorKXTJ9 calcZValue:characteristic.value];
        
        // OLD CODE TO UPDATE THE CELL VIEW
        tv.acc.accValueX.text = [NSString stringWithFormat:@"X: % 0.2fG",x];
        tv.acc.accValueY.text = [NSString stringWithFormat:@"Y: % 0.2fG",y];
        tv.acc.accValueZ.text = [NSString stringWithFormat:@"Z: % 0.2fG",z];
        
        tv.acc.accValueX.textColor = [UIColor blackColor];
        tv.acc.accValueY.textColor = [UIColor blackColor];
        tv.acc.accValueZ.textColor = [UIColor blackColor];
        
        tv.acc.accGraphX.progress = ((x/2) / ([sensorKXTJ9 getRange])) + 0.5;
        tv.acc.accGraphY.progress = ((y/2) / ([sensorKXTJ9 getRange])) + 0.5;
        tv.acc.accGraphZ.progress = ((z/2) / ([sensorKXTJ9 getRange])) + 0.5;
  
        self.currentVal.accX = x;
        self.currentVal.accY = y;
        self.currentVal.accZ = z;
        //BG Set a flag to log that this was an accelerometer event
        self.currentVal.accelEventFlag = @"YES";
    }
    
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:[self.d.setupData valueForKey:@"Humidity data UUID"]]]) {
        float rHVal = [sensorSHT21 calcPress:characteristic.value];
        
        // OLD CODE TO UPDATE THE CELL VIEW
        
        tv.rH.temperature.text = [NSString stringWithFormat:@"%0.1f%%rH",rHVal];
        tv.rH.temperatureGraph.progress = (rHVal / 100);
        tv.rH.temperature.textColor = [UIColor blackColor];
        
        self.currentVal.humidity = rHVal;
        
    }
    
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:[self.d.setupData valueForKey:@"Magnetometer data UUID"]]]) {
        self.magSensor = [[sensorMAG3110 alloc] init];
        float x = [self.magSensor calcXValue:characteristic.value];
        float y = [self.magSensor calcYValue:characteristic.value];
        float z = [self.magSensor calcZValue:characteristic.value];
        
        // OLD CODE TO UPDATE THE CELL VIEW

        tv.mag.accValueX.text = [NSString stringWithFormat:@"X: % 0.1fuT",x];
        tv.mag.accValueY.text = [NSString stringWithFormat:@"Y: % 0.1fuT",y];
        tv.mag.accValueZ.text = [NSString stringWithFormat:@"Z: % 0.1fuT",z];
       
        tv.mag.accValueX.textColor = [UIColor blackColor];
        tv.mag.accValueY.textColor = [UIColor blackColor];
        tv.mag.accValueZ.textColor = [UIColor blackColor];
        
        tv.mag.accGraphX.progress = (x / [sensorMAG3110 getRange]) + 0.5;
        tv.mag.accGraphY.progress = (y / [sensorMAG3110 getRange]) + 0.5;
        tv.mag.accGraphZ.progress = (z / [sensorMAG3110 getRange]) + 0.5;
    
        self.currentVal.magX = x;
        self.currentVal.magY = y;
        self.currentVal.magZ = z;
        
    }
    
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:[self.d.setupData valueForKey:@"Barometer calibration UUID"]]]) {
        
        self.baroSensor = [[sensorC953A alloc] initWithCalibrationData:characteristic.value];
        
        CBUUID *sUUID = [CBUUID UUIDWithString:[self.d.setupData valueForKey:@"Barometer service UUID"]];
        CBUUID *cUUID = [CBUUID UUIDWithString:[self.d.setupData valueForKey:@"Barometer config UUID"]];
        //Issue normal operation to the device
        uint8_t data = 0x01;
        [BLEUtility writeCharacteristic:self.d.p sCBUUID:sUUID cCBUUID:cUUID data:[NSData dataWithBytes:&data length:1]];
        
    }
    
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:[self.d.setupData valueForKey:@"Barometer data UUID"]]]) {
        int pressure = [self.baroSensor calcPressure:characteristic.value];
  
        // OLD CODE TO UPDATE THE CELL VIEW
        tv.baro.temperature.text = [NSString stringWithFormat:@"%d mBar",pressure];
        tv.baro.temperatureGraph.progress = ((float)((float)pressure - (float)800) / (float)400);
        tv.baro.temperature.textColor = [UIColor blackColor];
        

        self.currentVal.press = pressure;
        
    }
    
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:[self.d.setupData valueForKey:@"Gyroscope data UUID"]]]) {
        float x = [self.gyroSensor calcXValue:characteristic.value];
        float y = [self.gyroSensor calcYValue:characteristic.value];
        float z = [self.gyroSensor calcZValue:characteristic.value];
    
        // OLD CODE TO UPDATE THE CELL VIEW
       
        tv.gyro.accValueX.text = [NSString stringWithFormat:@"X: % 0.1f°/S",x];
        tv.gyro.accValueY.text = [NSString stringWithFormat:@"Y: % 0.1f°/S",y];
        tv.gyro.accValueZ.text = [NSString stringWithFormat:@"Z: % 0.1f°/S",z];
        
        tv.gyro.accValueX.textColor = [UIColor blackColor];
        tv.gyro.accValueY.textColor = [UIColor blackColor];
        tv.gyro.accValueZ.textColor = [UIColor blackColor];
        
        tv.gyro.accGraphX.progress = (x / [sensorIMU3000 getRange]) + 0.5;
        tv.gyro.accGraphY.progress = (y / [sensorIMU3000 getRange]) + 0.5;
        tv.gyro.accGraphZ.progress = (z / [sensorIMU3000 getRange]) + 0.5;
        
        self.currentVal.gyroX = x;
        self.currentVal.gyroY = y;
        self.currentVal.gyroZ = z;
        self.currentVal.gyroEventFlag = @"YES";
        
    }
  
  
    // Save this group of sensor samples into the history of SAMPLES_TO_KEEP samples
    [self logValues];
    
    
    //LPF filter the acceleration data
    if ([self.vals count] >2){
        [self filterAccelerationData];
            }
    
    // calculate the velocity vector and run rep counting state machine
    if (self.vals.count >2){
        [self calculateVelocity];
        sensorTagValues *v =  [self.vals objectAtIndex:(self.vals.count-1)];
        [self.fnSensor updateFitnoteStateFromValues:v];
        self.fnSensor.fitnoteState = v.directionOfVelocityVector;
    }

    // Check if a set has been completed
    if (self.fnSensor.currentExerciseSet.numberOfRepsCompleted > 0)//yes
    {
        // Create an exerciseSet Object and add it to the array of sets
        exerciseSet *setHolder = [[exerciseSet alloc] init];
        setHolder.numberOfRepsCompleted =  self.fnSensor.currentExerciseSet.numberOfRepsCompleted;
        setHolder.weight =  self.fnSensor.currentExerciseSet.weight;
        setHolder.equipmentName = self.d.machine.gymEquipName;
        setHolder.stopwatchTime = self.fnSensor.currentExerciseSet.stopwatchTime;
         setHolder.restInterval = self.fnSensor.currentExerciseSet.restInterval;
        [exerciseActivities insertObject:setHolder atIndex:0];
        
        // Reset the repcounter so only create the cell this time around
        self.fnSensor.currentExerciseSet.numberOfRepsCompleted = 0;
        
        // Create a table view cell of the table view for displayng the set
        ExerciseSetCellTemplate *currentExerciseSetCell = [[ExerciseSetCellTemplate alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ExerciseSet"];
        
        // Update the cell subviews
        currentExerciseSetCell.numberOfReps.text = [NSString stringWithFormat:@"%lu Reps ",(unsigned long)setHolder.numberOfRepsCompleted];
        currentExerciseSetCell.weight.text = [NSString stringWithFormat:@"%lu Lbs ",(unsigned long)setHolder.weight];
        // Add it to the array
        [tv.exerciseActivitiesCells insertObject:currentExerciseSetCell atIndex:0];
     

        // Create an IndexPathArray and IndexPath add Insert the Cell into the table view
        NSIndexPath *newCellPath;
        newCellPath = [NSIndexPath indexPathForRow:0 inSection:1];
        NSMutableArray *newCellArray = [[NSMutableArray alloc]init];
        [newCellArray addObject:newCellPath];
        [tv insertRowsAtIndexPaths:newCellArray withRowAnimation:UITableViewRowAnimationBottom];
    

        
    }
    
  
    
    //BG Update the fitnote Cell View - change this to use the new GUI elements
    [self.tv updateFintoteSensorCellView];
    
    //BG Update the view
    [self.tv reloadData];
}

-(void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    NSLog(@"didWriteValueForCharacteristic %@ error = %@",characteristic.UUID,error);
}



- (IBAction) handleCalibrateMag {
    NSLog(@"Calibrate magnetometer pressed !");
    [self.magSensor calibrate];
}
- (IBAction) handleCalibrateGyro {
    NSLog(@"Calibrate gyroscope pressed ! ");
    [self.gyroSensor calibrate];
}

- (IBAction) handleCalibrateFitnote {
    NSLog(@"Calibrate Fitnote pressed ! ");
    //Determine offset from last 2 seconds of samples;
    sensorTagValues *v;
    float calValue = 0;
    const int calibrationWindow = 30;  //3 seconds of data)
    int i = self.vals.count;
    while (i > self.vals.count - calibrationWindow) {
        v = [self.vals objectAtIndex:i-1];
        calValue = calValue + (float) (sqrt(pow(v.accX,2) + pow(v.accY,2)+ pow(v.accZ,2)) -1.0);
        v.filteredAcceleration=0;
        i--;
    }
    self.fnSensor.velocityOffset =  calValue/(float)calibrationWindow;
    v= [self.vals objectAtIndex:(self.vals.count-1)];
    v.velocityVector = 0;
    v.directionOfVelocityVector = @"PAUSED";
    v.valueOfVelocityDirection = 0;
    self.fnSensor.fitnoteState = @"STOPPED";
    self.fnSensor.repTimer = 0;
    self.fnSensor.fitnoteState = @"STOPPED";
    self.fnSensor.velocityDebounceCount = 0;
    self.fnSensor.RepState = READY;
    self.fnSensor.repCount=0;

}



//-(void) logValues:(NSTimer *)timer {
//    NSString *date = [NSDateFormatter localizedStringFromDate:[NSDate date]
//                                                    dateStyle:NSDateFormatterShortStyle
//                                                    timeStyle:NSDateFormatterMediumStyle];
//
//BG Changed this to a non timed log function run each time that BLE Characteristics are updated
-(void) logValues {
NSString *date = [NSDateFormatter localizedStringFromDate:[NSDate date]
                                                    dateStyle:NSDateFormatterShortStyle
                                                   timeStyle:NSDateFormatterMediumStyle];
//BG Only save the accelerometer and gyro events for the time being
    if ([self.currentVal.accelEventFlag isEqual: @"YES"] || [self.currentVal.gyroEventFlag isEqual: @"YES"]){
        sensorTagValues *newVal = [[sensorTagValues alloc]init];
        sensorTagValues *lastVals = [[sensorTagValues alloc]init];
         if (self.vals.count > 0) lastVals = [self.vals objectAtIndex:(self.vals.count-1)];
        self.currentVal.timeStamp = date;
      
        newVal.tAmb = self.currentVal.tAmb;
        newVal.tIR = self.currentVal.tIR;
        
       
        // gyro events interleaved so duplicate last accel readings if not one here
        if (![self.currentVal.accelEventFlag  isEqualToString: @"YES"]){
            if (self.vals.count > 0){
                self.currentVal.accX = lastVals.accX;
                self.currentVal.accY = lastVals.accY;
                self.currentVal.accZ = lastVals.accZ;
            }
            
        }
        newVal.accX = self.currentVal.accX;
        newVal.accY = self.currentVal.accY;
        newVal.accZ = self.currentVal.accZ;
        
        self.currentVal.calculatedAcceleration = (sqrt(pow(self.currentVal.accX,2) + pow(self.currentVal.accY,2)+ pow(self.currentVal.accZ,2)) -1 -self.fnSensor.velocityOffset);
        
        if (fabsf(self.currentVal.calculatedAcceleration) <= ((float)(JITTER_COUNTS) / 128.0)){
            //set the velocity to 0
            self.currentVal.calculatedAcceleration= 0;
        }
        newVal.calculatedAcceleration = self.currentVal.calculatedAcceleration;
        
        
        // gyros only update every second so repeat prior values if no update this cycle
        if ([self.currentVal.gyroEventFlag  isEqualToString: @"YES"]){
            newVal.gyroX = self.currentVal.gyroX;
            newVal.gyroY = self.currentVal.gyroY;
            newVal.gyroZ = self.currentVal.gyroZ;
        }
        else{
            if (self.vals.count > 0){
                sensorTagValues *tmpValues = [[sensorTagValues alloc]init];
                tmpValues = [self.vals objectAtIndex:(self.vals.count-1)];
                newVal.gyroX = lastVals.gyroX;
                newVal.gyroY = lastVals.gyroY;
                newVal.gyroZ = lastVals.gyroZ;
            }
        }
    
        newVal.magX = self.currentVal.magX;
        newVal.magY = self.currentVal.magY;
        newVal.magZ = self.currentVal.magZ;
        newVal.press = self.currentVal.press;
        newVal.humidity = self.currentVal.humidity;
        newVal.timeStamp = date;
        newVal.timeInMillseconds = self.currentVal.timeInMillseconds;
        newVal.accelEventFlag = self.currentVal.accelEventFlag;
        newVal.gyroEventFlag = self.currentVal.gyroEventFlag;
        [self.vals addObject:newVal];
        
        //BG Remove first set of samples so only keep fixed number
        NSUInteger samplesToKeep = LOG_SAMPLES_TO_KEEP;
        if (self.vals.count > samplesToKeep) {
            [self.vals removeObjectAtIndex:0];
        }
        
    }
}
    

//Low Pass Filter Calculated and calibrated accelerometer data
-(void) filterAccelerationData {
    int nSamples = self.vals.count;  //samples recorded so far
    sensorTagValues *v;
    
    if  (self.vals.count >= ACCEL_SMOOTHING_VALUE){   //check for enough samples for moving average
        float scratch =0;
        int curIndex = nSamples-1;  //last sample in the array
        int i = ACCEL_SMOOTHING_VALUE;
        while (i > 0){
            v = [self.vals objectAtIndex:curIndex];
            scratch = scratch + v.calculatedAcceleration;
            curIndex--;
            i--;
        }
        v = [self.vals objectAtIndex:(self.vals.count-1)];
        v. filteredAcceleration = scratch / (float)ACCEL_SMOOTHING_VALUE;
    }
    
    
}
/*********  Changed Jan 10*****************
- (void) calculateVelocity{
    sensorTagValues *v;
    sensorTagValues *l;
    int nSamples = self.vals.count;
    //pointers to most recent 2 samples
    
    if (nSamples>=2){
    v=[self.vals objectAtIndex:nSamples-1];
    l = [self.vals objectAtIndex:nSamples-2];
    }
    
    
    // first filter out jitter
//    if (fabsf(v.calculatedAcceleration) <= ((float)(JITTER_COUNTS) / 128.0)){
//        //set the velocity to 0
//        v.velocityVector= 0;
//    }

    
    //then check for zero crossing
   if (((v.filteredAcceleration >= 0) && (l.filteredAcceleration <=0))|| ((v.filteredAcceleration <= 0) && (l.filteredAcceleration >=0))) {
        v.velocityVector = 0;
    }
   
    
    else{
    // Integrate acceleration for velocity
    v.velocityVector = l.velocityVector + (v.filteredAcceleration + (0.5 * (v.filteredAcceleration - l.filteredAcceleration)));
    }
 *********  Changed Jan 10*****************/

- (void) calculateVelocity{
    sensorTagValues *v;
    sensorTagValues *l;
    int nSamples = self.vals.count;
    const float gyroActiveThreshold = 150; //90 degrees per second
    const float gyroWeightAdjustThreshold = 45; //100 degrees per second
    //pointers to most recent 2 samples
    
    if (nSamples>=2){
        v=[self.vals objectAtIndex:nSamples-1];
        l = [self.vals objectAtIndex:nSamples-2];
        
        // Process 1 Hz gyro events to check for rotation around the pin's axis (weight adjustment) which induces acceleration changes.  Capture these and filter out rotation induced acceleration changes
        float gyroVector;
        if ([v.gyroEventFlag isEqualToString:@"YES"]){
            gyroVector = sqrt(pow(v.gyroX,2) + pow(v.gyroY,2) +pow(v.gyroZ,2));
            if (gyroVector > gyroActiveThreshold){
                float onAxisRotation = v.gyroX;
                if (fabs(onAxisRotation) > gyroWeightAdjustThreshold && (sqrt(pow(onAxisRotation, 2)) / gyroVector > 0.75 )){//
                    if (v.gyroX > 0){
                        v.directionOfVelocityVector = @"RIGHT";
                        v.valueOfVelocityDirection  = 2;
                    }
                    
                    else{
                        v.directionOfVelocityVector = @"LEFT";
                        v.valueOfVelocityDirection  = -2;
                    }
            
                }
                else{
                    v.directionOfVelocityVector = @"RANDOM";
                    v.valueOfVelocityDirection  = -10;
                }
            }
            else{ // gyros not above threshold
                v.directionOfVelocityVector = @"PAUSED";
                v.valueOfVelocityDirection  = 0;
            }
    
        }
            // process acceleration events when gyros not active which implies pin is stable in stack
        else if ([v.accelEventFlag  isEqualToString: @"YES"]){
        //else if ([v.accelEventFlag  isEqualToString: @"YES"] && ( [v.directionOfVelocityVector  isEqualToString: @"UP"] ||  [v.directionOfVelocityVector  isEqualToString: @"DOWN"]|| [v.directionOfVelocityVector  isEqualToString: @"PAUSED"] || (v.directionOfVelocityVector == nil))){ // note initial vector is uninitialized.  Need to fix this
            //if (v.directionOfVelocityVector == nil) NSLog(@"nil Velocity Direction");
            
            // check for zero crossing
            if (((v.filteredAcceleration > MOTION_THRESHOLD) && (![l.directionOfVelocityVector isEqualToString:@"UP"]))){
                v.directionOfVelocityVector = @"UP";
                v.valueOfVelocityDirection  = 1;
            }
            
            else if  (((v.filteredAcceleration < -MOTION_THRESHOLD) && (![l.directionOfVelocityVector isEqualToString:@"DOWN"]))) {
                v.directionOfVelocityVector = @"DOWN";
                v.valueOfVelocityDirection  = -1;
            }
            
            else if (v.calculatedAcceleration == 0 ) {
                v.directionOfVelocityVector = @"PAUSED";
                v.valueOfVelocityDirection  = 0;
                v.filteredAcceleration = 0;
            }
            else {
                v.directionOfVelocityVector = l.directionOfVelocityVector;
                v.valueOfVelocityDirection = l.valueOfVelocityDirection;
            }
            
        }
        else NSLog(@"error noe events but calcvelocity called");
    }
    


    // Debounce for changes in direction of velocity count up to a max of 100 to handle wrap.
    bool sameDirection;
    if (l.valueOfVelocityDirection == v.valueOfVelocityDirection) {
        sameDirection = TRUE;
    }

    else sameDirection = FALSE;

    
    if ((sameDirection) && (fnSensor.velocityDebounceCount <100)) ++fnSensor.velocityDebounceCount;
    else fnSensor.velocityDebounceCount = 0;
    
   
/*if (fnSensor.velocityDebounceCount >= VELOCITY_DEBOUNCE_THRESHOLD){
        if (v.velocityVector == 0) fnSensor.fitnoteState = @"Stopped";
        else if (v.velocityVector > 0) fnSensor.fitnoteState = @"Up";
        else fnSensor.fitnoteState = @"Down";
    } */
}




-(void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    NSLog(@"Finished with result : %u error : %@",result,error);
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)sendMail:(id)sender {
    NSLog(@"Mail button pressed");
    NSMutableString *sensorData = [[NSMutableString alloc] init];
    //[sensorData appendString:@"Timestamp,Ambient Temperature,IR Temperature,Accelerometer X-Axis,Accelerometer Y-Axis,Accelerometer Z-Axis,Barometric Pressure,Relative Humidity,Gyroscope X,Gyroscope Y,Gyroscope Z,Magnetometer X, Magnetometer Y, Magnetometer Z\n"];
    [sensorData appendString:@"Date,Timestamp,Timer,AccelEvent,Smooth,Jitter,Threshold,Calibration,Accelerometer X-Axis,Accelerometer Y-Axis,Accelerometer Z-Axis,AccelVector,LPFAccel,Direction Value,Direction,RepState,VelocityVector,Gyroscope X,Gyroscope Y,Gyroscope Z,Magnetometer X, Magnetometer Y, Magnetometer Z\n"];
    for (int ii=0; ii < self.vals.count; ii++) {
        sensorTagValues *s = [self.vals objectAtIndex:ii];
       // [sensorData appendFormat:@"%@,%0.3f,%0.1f,%0.1f,%0.3f,%0.3f,%0.3f,%0.0f,%0.1f,%0.1f,%0.1f,%0.1f,%0.1f,%0.1f,%0.1f\n",s.timeStamp,s.tAmb,s.tIR,s.accX,s.accY,s.accZ,s.press,s.humidity,s.gyroX,s.gyroY,s.gyroZ,s.magX,s.magY,s.magZ];
        [sensorData appendFormat:@"%@,%0.3f,%@,%d,%d,%f,%.5f,%0.5f,%0.5f,%0.5f,%0.5f,%0.5f,%0.5f,%d,%d,%@,%0.3f,%0.3f,%0.3f,%0.3f,%0.3f,%0.3f\n",s.timeStamp,s.timeInMillseconds,s.accelEventFlag,ACCEL_SMOOTHING_VALUE,JITTER_COUNTS,MOTION_THRESHOLD,self.fnSensor.velocityOffset,s.accX,s.accY,s.accZ,s.calculatedAcceleration,s.filteredAcceleration,s.velocityVector,s.valueOfVelocityDirection,self.fnSensor.RepState,s.directionOfVelocityVector,s.gyroX,s.gyroY,s.gyroZ,s.magX,s.magY,s.magZ];
    }
    
    MFMailComposeViewController *mFMCVC = [[MFMailComposeViewController alloc]init];
    if (mFMCVC) {
        if ([MFMailComposeViewController canSendMail]) {
            mFMCVC.mailComposeDelegate = self;
            [mFMCVC setSubject:@"Data from BLE Sensor"];
            [mFMCVC setMessageBody:@"Data from sensor" isHTML:NO];
            [self presentViewController:mFMCVC animated:YES completion:nil];
            
            [mFMCVC addAttachmentData:[sensorData dataUsingEncoding:NSUTF8StringEncoding] mimeType:@"text/csv" fileName:@"Log.csv"];
        }
        else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Mail error" message:@"Device has not been set up to send mail" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
        }
    }
}





@end





@implementation SensorTagTableView
@synthesize containingViewController;
@synthesize fitnote;
@synthesize ambientTemp;
@synthesize exerciseActivitiesCells;

- (void)initializeSensorTagCells
{
    
    self.exerciseActivitiesCells = [[NSMutableArray alloc]init];
    if (!self.acc) {
        self.acc = [[accelerometerCellTemplate alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Accelerometer"];
        self.acc.accLabel.text = @"Accelerometer";
        self.acc.accValueX.text = @"-";
        self.acc.accValueY.text = @"-";
        self.acc.accValueZ.text = @"-";
        self.acc.accCalibrateButton.hidden = NO;
        self.acc.repcountLabel.text= @"Reps";
        [self.acc layoutSubviews];
    }
            //BG create the cell to hold Fitnoe data from the fitnote cell tmplate
    if (!self.fitnote) {
        self.fitnote = [[fitnoteCellTemplate alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"FitNote"];
        self.fitnote.fitnLabel.text = @"Fitnote Sensor";
        self.fitnote.fitnOrientation.text = @"Up: ?";
        self.fitnote.fitnState.text = @"State: ?";
        self.fitnote.fitnrepcountLabel.text = @"0";
        [self.fitnote.fitnCalibrateButton addTarget:self action:@selector(handleCalibrateFitnote) forControlEvents:UIControlEventTouchUpInside];
        [self.fitnote layoutSubviews];
        
    }
    
    if (!self.ambientTemp){
        self.ambientTemp = [[temperatureCellTemplate alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Ambient temperature"];
        self.ambientTemp.temperatureIcon.image = [UIImage imageNamed:@"temperature.png"];
        self.ambientTemp.temperatureLabel.text = @"Ambient Temperature";
        self.ambientTemp.temperature.text = @"-.-°C";
    }
    if (!self.irTemp) {
        self.irTemp = [[temperatureCellTemplate alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"IR temperature"];
        self.irTemp.temperatureIcon.image = [UIImage imageNamed:@"objecttemperature.png"];
        self.irTemp.temperatureLabel.text = @"Object Temperature";
        self.irTemp.temperature.text = @"-.-°C";
    }
    
    if (!self.rH) {
        self.rH = [[temperatureCellTemplate alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Relative humidity"];
        self.rH.temperatureIcon.image = [UIImage imageNamed:@"relativehumidity.png"];
        self.rH.temperatureLabel.text = @"Relative humidity";
        self.rH.temperature.text = @"-%rH";
    }
    if (!self.mag) {
        self.mag = [[accelerometerCellTemplate alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Magnetometer"];
        self.mag.accLabel.text = @"Magnetometer";
        self.mag.accIcon.image = [UIImage imageNamed:@"magnetometer.png"];
        self.mag.accValueX.text = @"-";
        self.mag.accValueY.text = @"-";
        self.mag.accValueZ.text = @"-";
        [self.mag.accCalibrateButton addTarget:self action:@selector(handleCalibrateMag) forControlEvents:UIControlEventTouchUpInside];
        
    }
    if (!self.baro) {
        self.baro = [[temperatureCellTemplate alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Barometer"];
        self.baro.temperatureLabel.text = @"Barometer";
        self.baro.temperatureIcon.image = [UIImage imageNamed:@"barometer.png"];
        self.baro.temperature.text = @"1000mBar";
    }
    if (!self.gyro) {
        self.gyro = [[accelerometerCellTemplate alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Gyroscope"];
        self.gyro.accLabel.text = @"Gyroscope";
        self.gyro.accIcon.image = [UIImage imageNamed:@"gyroscope.png"];
        self.gyro.accValueX.text = @"-";
        self.gyro.accValueY.text = @"-";
        self.gyro.accValueZ.text = @"-";
        [self.gyro.accCalibrateButton addTarget:self action:@selector(handleCalibrateGyro) forControlEvents:UIControlEventTouchUpInside];
        
        
    }
    
    
        return;
    
}







// BG Not used in FitNote App
-(void) alphaFader:(NSTimer *)timer {
    
    CGFloat w,a;
    if (self.ambientTemp) {
        [self.ambientTemp.temperature.textColor getWhite:&w alpha:&a];
        if (a > MIN_ALPHA_FADE) a -= ALPHA_FADE_STEP;
        self.ambientTemp.temperature.textColor = [self.ambientTemp.temperature.textColor colorWithAlphaComponent:a];
    }
    if (self.irTemp) {
        [self.irTemp.temperature.textColor getWhite:&w alpha:&a];
        if (a > MIN_ALPHA_FADE) a -= ALPHA_FADE_STEP;
        self.irTemp.temperature.textColor = [self.irTemp.temperature.textColor colorWithAlphaComponent:a];
    }
    if (self.acc) {
        [self.acc.accValueX.textColor getWhite:&w alpha:&a];
        if (a > MIN_ALPHA_FADE) a -= ALPHA_FADE_STEP;
        self.acc.accValueX.textColor = [self.acc.accValueX.textColor colorWithAlphaComponent:a];
        
        [self.acc.accValueY.textColor getWhite:&w alpha:&a];
        if (a > MIN_ALPHA_FADE) a -= ALPHA_FADE_STEP;
        self.acc.accValueY.textColor = [self.acc.accValueY.textColor colorWithAlphaComponent:a];
        
        [self.acc.accValueZ.textColor getWhite:&w alpha:&a];
        if (a > MIN_ALPHA_FADE) a -= ALPHA_FADE_STEP;
        self.acc.accValueZ.textColor = [self.acc.accValueZ.textColor colorWithAlphaComponent:a];
    }
    if (self.rH) {
        [self.rH.temperature.textColor getWhite:&w alpha:&a];
        if (a > MIN_ALPHA_FADE) a -= ALPHA_FADE_STEP;
        self.rH.temperature.textColor = [self.rH.temperature.textColor colorWithAlphaComponent:a];
    }
    if (self.mag) {
        [self.mag.accValueX.textColor getWhite:&w alpha:&a];
        if (a > MIN_ALPHA_FADE) a -= ALPHA_FADE_STEP;
        self.mag.accValueX.textColor = [self.mag.accValueX.textColor colorWithAlphaComponent:a];
        
        [self.mag.accValueY.textColor getWhite:&w alpha:&a];
        if (a > MIN_ALPHA_FADE) a -= ALPHA_FADE_STEP;
        self.mag.accValueY.textColor = [self.mag.accValueY.textColor colorWithAlphaComponent:a];
        
        [self.mag.accValueZ.textColor getWhite:&w alpha:&a];
        if (a > MIN_ALPHA_FADE) a -= ALPHA_FADE_STEP;
        self.mag.accValueZ.textColor = [self.mag.accValueZ.textColor colorWithAlphaComponent:a];
    }
    if (self.baro) {
        [self.baro.temperature.textColor getWhite:&w alpha:&a];
        if (a > MIN_ALPHA_FADE) a -= ALPHA_FADE_STEP;
        self.baro.temperature.textColor = [self.baro.temperature.textColor colorWithAlphaComponent:a];
    }
    if (self.gyro) {
        [self.gyro.accValueX.textColor getWhite:&w alpha:&a];
        if (a > MIN_ALPHA_FADE) a -= ALPHA_FADE_STEP;
        self.gyro.accValueX.textColor = [self.gyro.accValueX.textColor colorWithAlphaComponent:a];
        
        [self.gyro.accValueY.textColor getWhite:&w alpha:&a];
        if (a > MIN_ALPHA_FADE) a -= ALPHA_FADE_STEP;
        self.gyro.accValueY.textColor = [self.gyro.accValueY.textColor colorWithAlphaComponent:a];
        
        [self.gyro.accValueZ.textColor getWhite:&w alpha:&a];
        if (a > MIN_ALPHA_FADE) a -= ALPHA_FADE_STEP;
        self.gyro.accValueZ.textColor = [self.gyro.accValueZ.textColor colorWithAlphaComponent:a];
    }
    
    
}
- (void) updateFintoteSensorCellView{

    self.fitnote.fitnrepcountLabel.text = [NSString stringWithFormat:@"Reps: %d",containingViewController.fnSensor.repCount];
    
    self.fitnote.fitnState.text = [NSString stringWithFormat:@"State: %@",containingViewController.fnSensor.fitnoteState];
    self.fitnote.fitnOrientation.text = [NSString stringWithFormat:@"RepState: %d",containingViewController.fnSensor.RepState];
    self.fitnote.fitnIcon.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@",containingViewController.d.machine.gymEquipImage]];
    self.fitnote.fitnLabel.text= [NSString stringWithFormat:@"%@",containingViewController.d.machine.gymEquipName];
    
    
}



@end
