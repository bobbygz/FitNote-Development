/*
*  Sensors.h
*
* Created by Ole Andreas Torvmark on 10/2/12.
* Copyright (c) 2012 Texas Instruments Incorporated - http://www.ti.com/
* ALL RIGHTS RESERVED
*/



#import <Foundation/Foundation.h>
#import "exerciseSet.h"
#import "ExerciseSetCellTemplate.h"
#import "Speak.h"


@interface  sensorC953A: NSObject

///Calibration values unsigned
@property UInt16 c1,c2,c3,c4;
///Calibration values signed
@property int16_t c5,c6,c7,c8;

-(id) initWithCalibrationData:(NSData *)data;

-(int) calcPressure:(NSData *)data;



@end



@interface sensorIMU3000: NSObject

@property float lastX,lastY,lastZ;
@property float calX,calY,calZ;

#define IMU3000_RANGE 500.0

-(id) init;

-(void) calibrate;
-(float) calcXValue:(NSData *)data;
-(float) calcYValue:(NSData *)data;
-(float) calcZValue:(NSData *)data;
+(float) getRange;

@end

@interface sensorKXTJ9 : NSObject
//BG Fixed range was 4G should be 2G (debugger showed 1G = 64 counts)
//BG Bug in code. Sensor has 64 counts per G in 8 bit mode at 2G resolution

#define KXTJ9_RANGE 2


+(float) calcXValue:(NSData *)data;
+(float) calcYValue:(NSData *)data;
+(float) calcZValue:(NSData *)data;
+(float) getRange;

@end

/*  Prior revision before adding back in the counting algorithm
@interface sensorFitnote : NSObject
#define VELOCITY_DEBOUNCE_THRESHOLD 3

//tuning parameters for filtering data
#define sampleNoiseThreshold 0.2  // Ignore changes less than +/- .2G
#define sampleWindow 3  //Sample peior of 100 msec is 10Hz frequency look for 3 samples
@property NSMutableArray *accelSamples;
@property NSString *fitnoteState;
@property NSMutableArray *sensorValueArray;
@property float velocityOffset;
@property int repCount;
@property int velocityDebounceCount;

-(void) updateFitnoteState;
-(id) initWithPointerToArrayOfSensorTagValues: (NSMutableArray *) v;

@end
*/
@interface sensorMAG3110 : NSObject

@property float lastX,lastY,lastZ;
@property float calX,calY,calZ;

#define MAG3110_RANGE 2000.0

-(id) init;
-(void) calibrate;
-(float) calcXValue:(NSData *)data;
-(float) calcYValue:(NSData *)data;
-(float) calcZValue:(NSData *)data;
+(float) getRange;

@end

@interface sensorTMP006 : NSObject
+(float) calcTAmb:(NSData *)data;
+(float) calcTAmb:(NSData *)data offset:(int)offset;
+(float) calcTObj:(NSData *)data;
@end

@interface sensorSHT21 : NSObject

+(float) calcPress:(NSData *)data;
+(float) calcTemp:(NSData *)data;

@end



@interface sensorTagValues : NSObject

@property float tAmb;
@property float tIR;
@property float press;
@property float humidity;
@property float accX;
@property float accY;
@property float accZ;
@property float gyroX;
@property float gyroY;
@property float gyroZ;
@property float magX;
@property float magY;
@property float magZ;
@property NSString *timeStamp;
@property double timeInMillseconds;
@property NSString *accelEventFlag;
@property NSString *gyroEventFlag;
// accelerometer axis after passing through x point moving average
@property float accelXLPF;
@property float accelYLPF;
@property float accelZLPF;
@property float filteredAcceleration;
@property float velocityXLPF;
@property float velocityYLPF;
@property float velocityZLPF;

// calculated velocity for each axis
@property float velocityVector;
@property float calculatedAcceleration;
@property float velocityX;
@property float velocityY;
@property float velocityZ;
@property NSString *directionOfVelocityVector;
@property  int  valueOfVelocityDirection;

@property NSString *debouncedDirection;
@end


@interface sensorFitnote : NSObject
#define VELOCITY_DEBOUNCE_THRESHOLD 3

//tuning parameters for filtering data
#define sampleNoiseThreshold 0.2  // Ignore changes less than +/- .2G
#define sampleWindow 3  //Sample peior of 100 msec is 10Hz frequency look for 3 samples

@property NSString *fitnoteState;
@property float velocityOffset;
enum RepCounterState{
    NOTREADY,
    ADJUSTWEIGHT,
    READY,
    LIFTING,
    LOWERING
};
typedef enum RepCounterState RepCounterState;
@property RepCounterState RepState;
@property int repCount;
@property int velocityDebounceCount;
@property int repTimer;
@property int setTimer;
@property exerciseSet *currentExerciseSet;
@property Speak *speaker;
@property BOOL gyrosActive;
@property int gyrosInactiveDebounceCount;





-(void) updateFitnoteStateFromValues: (sensorTagValues *) values;


@end

