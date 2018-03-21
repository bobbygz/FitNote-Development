/*
 *  SensorTagApplicationViewController.h
 *
 * Created by Ole Andreas Torvmark on 10/2/12.
 * Copyright (c) 2012 Texas Instruments Incorporated - http://www.ti.com/
 * ALL RIGHTS RESERVED
 */

#import <UIKit/UIKit.h>
#import "BLEDevice.h"
#import "BLEUtility.h"
#import "deviceCellTemplate.h"
#import "Sensors.h"
#import <MessageUI/MessageUI.h>
#import <math.h>
#import "ExerciseSetCellTemplate.h"
#import "exerciseSet.h"

// Good values 5, 5, .07   3, 5, .09
#define MIN_ALPHA_FADE 0.2f
#define ALPHA_FADE_STEP 0.05f
#define LOG_SAMPLES_TO_KEEP 500 //Last 50 seconds of data are logged at 10Hz
#define ACCEL_SMOOTHING_VALUE 3 //for moving average;
#define JITTER_COUNTS 4
#define MOTION_THRESHOLD 0.1
/*BG This subclasses UITableViewController with a
 * SensorTagApplicationVieController that adopts the protocols CBCentralManagerDelegate, CBPeripheralDelegate
 * and MFMailComposeViewControllerDelegate
*/
@class SensorTagTableView; // Forward declares it
@interface SensorTagApplicationViewController : UIViewController <CBCentralManagerDelegate,CBPeripheralDelegate,MFMailComposeViewControllerDelegate, UITableViewDelegate, UITableViewDataSource>


@property (strong,nonatomic) NSMutableArray *sensorsEnabled;
@property (strong,nonatomic) NSMutableArray *exerciseActivities;
@property (strong,nonatomic) sensorFitnote *fnSensor;

@property (strong,nonatomic) sensorMAG3110 *magSensor;
@property (strong,nonatomic) sensorC953A *baroSensor;
@property (strong,nonatomic) sensorIMU3000 *gyroSensor;

@property (strong,nonatomic) sensorTagValues *currentVal;

@property (strong,nonatomic) NSMutableArray *vals;
@property (strong,nonatomic) NSTimer *logTimer;
@property (strong,nonatomic) SensorTagTableView *tv;
@property float logInterval;
@property (strong,nonatomic) BLEDevice *d;


- (void) configureSensorTag;
- (void) deconfigureSensorTag;

//BG Added these
//-(float)calculateMovingAverageFor:(int)samplePeriods onParemeter: (NSString *) parameter;
- (void) filterAccelerationData;
- (void) calculateVelocity;


- (IBAction) handleCalibrateMag;
- (IBAction) handleCalibrateGyro;
- (IBAction) handleCalibrateFitnote;


//-(void) logValues:(NSTimer *)timer;
- (void) logValues;

-(IBAction)sendMail:(id)sender;

@end


@interface SensorTagTableView : UITableView 
@property (strong, nonatomic) SensorTagApplicationViewController *containingViewController;
@property (strong,nonatomic) fitnoteCellTemplate *fitnote;
@property (strong,nonatomic) NSMutableArray *exerciseActivitiesCells;
@property (strong,nonatomic) accelerometerCellTemplate *acc;
@property (strong,nonatomic) temperatureCellTemplate *rH;
@property (strong,nonatomic) accelerometerCellTemplate *mag;
@property (strong,nonatomic) temperatureCellTemplate *baro;
@property (strong,nonatomic) accelerometerCellTemplate *gyro;
@property (strong,nonatomic) temperatureCellTemplate *ambientTemp;
@property (strong,nonatomic) temperatureCellTemplate *irTemp;

- (void)initializeSensorTagCells;
- (void) updateFintoteSensorCellView;
- (void) alphaFader:(NSTimer *)timer;
@end
