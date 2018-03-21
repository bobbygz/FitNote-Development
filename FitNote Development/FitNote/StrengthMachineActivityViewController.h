//
//  StrengthMachineActivityViewController.h
//  FitNote
//
//  Created by Bobby Gintz on 2/8/14.
//  Copyright (c) 2014 Texas Instruments. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BLEDevice.h"
#import "BLEUtility.h"
#import "deviceCellTemplate.h"
#import "Sensors.h"
#import <MessageUI/MessageUI.h>
#import <math.h>
#import "ExerciseSetCellTemplate.h"
#import "workoutSetTableCell.h"
#import "exerciseSet.h"
#import "AppDelegate.h"

// Good values 5, 5, .07   3, 5, .09
#define MIN_ALPHA_FADE 0.2f
#define ALPHA_FADE_STEP 0.05f
#define LOG_SAMPLES_TO_KEEP 500 //Last 50 seconds of data are logged at 10Hz
#define ACCEL_SMOOTHING_VALUE 3 //for moving average;
#define JITTER_COUNTS 4
#define MOTION_THRESHOLD 0.1

@interface StrengthMachineActivityViewController : UIViewController  <CBCentralManagerDelegate,CBPeripheralDelegate,MFMailComposeViewControllerDelegate, UITableViewDelegate, UITableViewDataSource>

// From original Sensortag app
@property (strong,nonatomic) NSMutableArray *sensorsEnabled;
@property (strong,nonatomic) NSMutableArray *exerciseActivities;
@property (strong,nonatomic) NSMutableArray *exerciseActivitiesCells;
@property (strong,nonatomic) sensorFitnote *fnSensor;
@property (strong,nonatomic) sensorMAG3110 *magSensor;
@property (strong,nonatomic) sensorC953A *baroSensor;
@property (strong,nonatomic) sensorIMU3000 *gyroSensor;
@property (strong,nonatomic) sensorTagValues *currentVal;
@property (strong,nonatomic) NSMutableArray *vals;
@property (strong,nonatomic) NSTimer *timer;
//@property (strong,nonatomic) SensorTagTableView *tv;
@property float logInterval;
@property (strong,nonatomic) BLEDevice *d;

// New from storyboard file
@property (strong, nonatomic) IBOutlet UIImageView *machineImage;
@property (strong, nonatomic) IBOutlet UILabel *weightSelectedLabel;
@property (strong, nonatomic) IBOutlet UILabel *repCounterLabel;
@property (strong, nonatomic) IBOutlet UIImageView *repCounterIcon;
@property (strong, nonatomic) IBOutlet UILabel *restTimerLabel;
@property (strong, nonatomic) IBOutlet UIImageView *restTimerIcon;
@property (strong, nonatomic) IBOutlet UITableView *workoutSetTable;
@property (strong, nonatomic) IBOutlet UISlider *weightSelectSlider;

// For Core data
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;


- (void) configureSensorTag;
- (void) deconfigureSensorTag;
//-(float)calculateMovingAverageFor:(int)samplePeriods onParemeter: (NSString *) parameter;
- (void) filterAccelerationData;
- (void) calculateVelocity;
- (void) processExerciseActivityTimer:(NSTimer *)timer;
- (void) endOfRestInterval:(NSTimer *) timer;


- (IBAction)handleWeightSelectSlider:(UISlider *)sender;

- (IBAction) handleCalibrateMag;
- (IBAction) handleCalibrateGyro;
- (IBAction) handleCalibrateFitnote;

@end
