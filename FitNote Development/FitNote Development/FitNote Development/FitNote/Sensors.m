/*
 *  Sensors.h
 *
 * Created by Ole Andreas Torvmark on 10/2/12.
 * Copyright (c) 2012 Texas Instruments Incorporated - http://www.ti.com/
 * ALL RIGHTS RESERVED
 */

#import "Sensors.h"

//BG IR Temp sensor
@implementation sensorC953A
@synthesize c1,c2,c3,c4,c5,c6,c7,c8;


-(id) initWithCalibrationData:(NSData *)data {
    self = [[sensorC953A alloc] init];
    if (self) {
        unsigned char scratchVal[16];
        [data getBytes:&scratchVal length:16];
        self.c1 = ((scratchVal[0] & 0xff) | ((scratchVal[1] << 8) & 0xff00));
        self.c2 = ((scratchVal[2] & 0xff) | ((scratchVal[3] << 8) & 0xff00));
        self.c3 = ((scratchVal[4] & 0xff) | ((scratchVal[5] << 8) & 0xff00));
        self.c4 = ((scratchVal[6] & 0xff) | ((scratchVal[7] << 8) & 0xff00));
        self.c5 = ((scratchVal[8] & 0xff) | ((scratchVal[9] << 8) & 0xff00));
        self.c6 = ((scratchVal[10] & 0xff) | ((scratchVal[11] << 8) & 0xff00));
        self.c7 = ((scratchVal[12] & 0xff) | ((scratchVal[13] << 8) & 0xff00));
        self.c8 = ((scratchVal[14] & 0xff) | ((scratchVal[15] << 8) & 0xff00));
    }
    return self;
}
-(int) calcPressure:(NSData *)data {
    if (data.length < 4) return -0.0f;
    char scratchVal[4];
    [data getBytes:&scratchVal length:4];
    int16_t temp;
    uint16_t pressure;

    temp = (scratchVal[0] & 0xff) | ((scratchVal[1] << 8) & 0xff00);
    pressure = (scratchVal[2] & 0xff) | ((scratchVal[3] << 8) & 0xff00);
    
    long long tempTemp = (long long)temp;
    // Temperature calculation
    //BG turn off logging of Barometric Temp
    //long temperature = ((((long)self.c1 * (long)tempTemp)/(long)1024) + (long)((self.c2) / (long)4 - (long)16384));
    //NSLog(@"Calculation of Barometer Temperature : temperature = %ld(%lx)",temperature,temperature);
   
    
    long long S = self.c3 + ((self.c4 * (long long)tempTemp)/((long long)1 << 17)) + ((self.c5 * ((long long)tempTemp * (long long)tempTemp))/(long long)((long long)1 << 34));
    long long O = (self.c6 * ((long long)1 << 14)) + (((self.c7 * (long long)tempTemp)/((long long)1 << 3))) + ((self.c8 * ((long long)tempTemp * (long long)tempTemp))/(long long)((long long)1 << 19));
    long long Pa = (((S * (long long)pressure) + O) / (long long)((long long)1 << 14));
    
    
    return (int)((int)Pa/(int)100);
    
}

@end

//BG Gyroscope
@implementation sensorIMU3000

@synthesize lastX,lastY,lastZ;
@synthesize calX,calY,calZ;

-(id) init {
    self = [super init];
    if (self) {
        self.calX = 0.0f;
        self.calY = 0.0f;
        self.calZ = 0.0f;
    }
    return self;
}

-(void) calibrate {
    self.calX = self.lastX;
    self.calY = self.lastY;
    self.calZ = self.lastZ;
    
}

-(float) calcXValue:(NSData *)data {
    //Orientation of sensor on board means we need to swap X (multiplying with -1)
    char scratchVal[6];
    [data getBytes:&scratchVal length:6];
    int16_t rawX = (scratchVal[0] & 0xff) | ((scratchVal[1] << 8) & 0xff00);
    self.lastX = (((float)rawX * 1.0) / ( 65536 / IMU3000_RANGE )) * -1;
    return (self.lastX - self.calX);
}
-(float) calcYValue:(NSData *)data {
    //Orientation of sensor on board means we need to swap Y (multiplying with -1)
    char scratchVal[6];
    [data getBytes:&scratchVal length:6];
    int16_t rawY = ((scratchVal[2] & 0xff) | ((scratchVal[3] << 8) & 0xff00));
    self.lastY = (((float)rawY * 1.0) / ( 65536 / IMU3000_RANGE )) * -1;
    return (self.lastY - self.calY);
}
-(float) calcZValue:(NSData *)data {
    char scratchVal[6];
    [data getBytes:&scratchVal length:6];
    int16_t rawZ = (scratchVal[4] & 0xff) | ((scratchVal[5] << 8) & 0xff00);
    self.lastZ = ((float)rawZ * 1.0) / ( 65536 / IMU3000_RANGE );
    return (self.lastZ - self.calZ);
}
+(float) getRange {
    return IMU3000_RANGE;
}

@end


//BG Accelerometer returns X, Y, and Z as single byte 2's Complement numbers
//BG char is signed by default so no need to worry about using it wih float
//BG 1G = 64 counts, had to fix bug in code dividing by 256
@implementation sensorKXTJ9
+(float) calcXValue:(NSData *)data {
    char scratchVal[data.length];
    [data getBytes:&scratchVal length:3];
    return ((scratchVal[0] * 1.0) /(128 / KXTJ9_RANGE));
}
+(float) calcYValue:(NSData *)data {
    //Orientation of sensor on board means we need to swap Y (multiplying with -1)
    char scratchVal[data.length];
    [data getBytes:&scratchVal length:3];
    return ((scratchVal[1] * 1.0) /(128 / KXTJ9_RANGE)* -1);
}
+(float) calcZValue:(NSData *)data {
    char scratchVal[data.length];
    [data getBytes:&scratchVal length:3];
    return ((scratchVal[2] * 1.0) / (128 / KXTJ9_RANGE));
}
+(float) getRange {
    return KXTJ9_RANGE;
}

@end

//BG sensor Fusion to do all of the heavy lifting from the sensorTag data

@implementation sensorFitnote
@synthesize RepState, repCount,velocityDebounceCount, setTimer,
repTimer, currentExerciseSet;
@synthesize velocityOffset;
@synthesize speaker;
@synthesize gyrosActive;
@synthesize gyrosInactiveDebounceCount;

-(id) init {
    self = [super init];
    if (self) {
        self.fitnoteState = @"?";
        self.velocityOffset = 0;
        self.RepState = READY;
        self.repTimer = 0;
        self.setTimer = 0;
        self.velocityDebounceCount =0;
        self.velocityOffset = 0.0;
        repCount = 0;
        self.currentExerciseSet = [[exerciseSet alloc ] init];
        self.currentExerciseSet.numberOfRepsCompleted= 0;
        // temporary initialization for weight for pin twist testing
        //self.currentExerciseSet.weight = 100;
        speaker = [[Speak alloc]init];
        
        
    }
    return self;
}

-(void) updateFitnoteStateFromValues:(sensorTagValues *) sensorValues{
    const int minimumMotionCounts = 1; //ignore motion that is less than this * 100 msec in duration
    const int minimumPauseCounts = 10; //ignore pauses less than this
    const int minimumRepTime = 10;  // don't count reps shorter than this
    const int endOfSetTimeout = 20; // 2 seconds  delay after end of rep to record set
    
   
    // Process gyro events (1 Hz) only if not in the middle of counting reps
    if ([sensorValues.gyroEventFlag  isEqualToString: @"YES"] && ((self.repTimer == 0 && self.RepState == READY) || (self.RepState == NOTREADY)|| (self.RepState == ADJUSTWEIGHT)) && (self.setTimer ==0)){
        // First check if any gyros are active
        switch (sensorValues
                .valueOfVelocityDirection){
            case 2:{ //Clockwise rotation
                self.RepState = ADJUSTWEIGHT;
                self.currentExerciseSet.weight += 5;
                [speaker speakNumber:self.currentExerciseSet.weight];
                break;
            }
            case -2:{ //Counterclockwise rotation
                self.RepState = ADJUSTWEIGHT;
                self.currentExerciseSet.weight -=5;
                [speaker speakNumber:self.currentExerciseSet.weight];
                break;
            }
            case -10:{ //Random movement
                self.RepState = NOTREADY;
                self.repCount = 0;
                break;
            }
            case -0:{ //gyros went quiet reset if for 3 seconds
                if (self.RepState != READY){
                    if (velocityDebounceCount >=30){
                        // no gyro activity for 3 seconds
                        // reset Repcounting state machine
                        self.RepState = READY;
                        //self.repTimer = 0;
                        repCount = 0;
                        [speaker speakText:@"Ready to Start"];
                    }
                    else {
                        //self.RepState = NOTREADY;
                    }
                    break;
                }
            }
        }
    }
    
    // Process accelerometer events every 100 msec
    if ([sensorValues.accelEventFlag  isEqual: @"YES"]){
        if ((RepState !=ADJUSTWEIGHT) && (RepState != NOTREADY)){
            if (RepState != READY) ++self.repTimer; // 1 each 100 msec
        
        
        // Check to see if direction has met debounce critria
        if (self.velocityDebounceCount >= minimumMotionCounts){
            switch (self.RepState) {
                case READY:{
                    switch (sensorValues.valueOfVelocityDirection){
                        case 1:{ //UP
                            // possible beginning of a repetition
                            self.RepState = LIFTING;
                            self.repTimer = self.velocityDebounceCount; //record ticks since start of upward movement detected
                            self.setTimer = 0;
                            NSLog(@"Start of Rep");
                            break;
                        }
                        case 0:{ //PAUSED
                            // Check to see if false pause and instead was stopped and still is
                            if (self.velocityDebounceCount > minimumPauseCounts){
                                self.repTimer = 0;
                                ++ self.setTimer;
                                if (self.setTimer == endOfSetTimeout && self.repCount >0) {
                                    NSLog(@"End of Set");
                                    [speaker speakText:@"End of Set"];
                                    
                                    currentExerciseSet.numberOfRepsCompleted = self.repCount;
                                    currentExerciseSet.stopTime = [NSDate date];
                                    //self.currentExerciseSet.weight
                                    self.repCount = 0;
                                    self.setTimer = 0;
                                    self.RepState = ADJUSTWEIGHT;
                                    //BG HACK
                                    self.velocityDebounceCount = 0;
                                }
                                
                            }
                            break;
                        }
                        case -1:{ //DOWN This covers long pauses at top of rep.
                            self.RepState = LOWERING;
                            self.setTimer = 0;
                            break;
                        }
                    }
                    break;
                }
                case LIFTING:{
                    NSLog(@"LOFTING STATE with Direction = %d", sensorValues.valueOfVelocityDirection);
                    switch (sensorValues.valueOfVelocityDirection){
                            
                        case 1:{ //UP
                            // Still lifting up in repetition
                            break;
                        }
                        case 0:{ //PAUSED
                            // My happen at top of rep.  state doesnt change unless paused here more than debounce value
                            
                            // debounce for noise hit
                            if (self.velocityDebounceCount > minimumPauseCounts){
                                self.RepState = READY;
                                self.repTimer = 0;
                            }
                            break;
                        }
                        case -1:{ //DOWN
                            NSLog(@"Got to lift / lower ");
                            
                            self.RepState=LOWERING;
                            break;
                        }
                    }
                    break;
                }
                case LOWERING:{
                    switch (sensorValues.valueOfVelocityDirection){
                        case 1:{ //UP
                            // Went from down to up.  Can happen at end of rep at start of new one or simply momentum of sensor
                            if (self.repTimer >= minimumRepTime)  {
                                ++ self.repCount;
                                if (self.repCount == 1){
                                    // Start of set
                                    currentExerciseSet.startTime = [NSDate date];                                }
                                    
                                [speaker speakNumber:self.repCount];
                                self.RepState = LIFTING;
                                self.repTimer=velocityDebounceCount;
                            }
                            break;
                        }
                        case 0:{ //PAUSED
                            // End of the rep?
                            // May happen at bottom of rep.  state doesnt change unless paused here more than debounce value
                            if (self.velocityDebounceCount > minimumPauseCounts){
                                self.RepState = READY;
                                self.repTimer = 0;
                                NSLog(@"To Ready from LOWERING");
                                if (self.repTimer >= minimumRepTime) {
                                    ++ self.repCount;
                                    if (self.repCount == 1){
                                        // Start of set
                                        currentExerciseSet.startTime = [NSDate date];
                                    }

                                    [speaker speakNumber:self.repCount];
                                    self.setTimer = 0;
                                }
                            }
                            break;
                        }
                        case -1:{ //DOWN
                            NSLog(@"DOWN IN LOWERING");
                            break;
                        }
                    }
                    break;
                }
            }
        }
    }
    }
    return;
}

@end




//BG Magnetometer
@implementation sensorMAG3110

@synthesize lastX,lastY,lastZ;
@synthesize calX,calY,calZ;

-(id) init {
    self = [super init];
    if (self) {
        self.calX = 0.0f;
        self.calY = 0.0f;
        self.calZ = 0.0f;
    }
    return self;
}

-(void) calibrate {
    self.calX = self.lastX;
    self.calY = self.lastY;
    self.calZ = self.lastZ;
 
}

-(float) calcXValue:(NSData *)data {
    //Orientation of sensor on board means we need to swap X (multiplying with -1)
    char scratchVal[6];
    [data getBytes:&scratchVal length:6];
    int16_t rawX = (scratchVal[0] & 0xff) | ((scratchVal[1] << 8) & 0xff00);
    self.lastX = (((float)rawX * 1.0) / ( 65536 / MAG3110_RANGE )) * -1;
    return (self.lastX - self.calX);
}
-(float) calcYValue:(NSData *)data {
    //Orientation of sensor on board means we need to swap Y (multiplying with -1)
    char scratchVal[6];
    [data getBytes:&scratchVal length:6];
    int16_t rawY = ((scratchVal[2] & 0xff) | ((scratchVal[3] << 8) & 0xff00));
    self.lastY = (((float)rawY * 1.0) / ( 65536 / MAG3110_RANGE )) * -1;
    return (self.lastY - self.calY);
}
-(float) calcZValue:(NSData *)data {
    char scratchVal[6];
    [data getBytes:&scratchVal length:6];
    int16_t rawZ = (scratchVal[4] & 0xff) | ((scratchVal[5] << 8) & 0xff00);
    self.lastZ =  ((float)rawZ * 1.0) / ( 65536 / MAG3110_RANGE );
    return (self.lastZ - self.calZ);
}
+(float) getRange {
    return 60.0;
}
@end

//BG Ambient Temp Sensor
@implementation sensorTMP006

+(float) calcTAmb:(NSData *)data {
    char scratchVal[data.length];
    int16_t ambTemp;
    [data getBytes:&scratchVal length:data.length];
    ambTemp = ((scratchVal[2] & 0xff)| ((scratchVal[3] << 8) & 0xff00));
    
    return (float)((float)ambTemp / (float)128);
}

+(float) calcTAmb:(NSData *)data offset:(int)offset {
    char scratchVal[data.length];
    int16_t ambTemp;
    [data getBytes:&scratchVal length:data.length];
    ambTemp = ((scratchVal[offset] & 0xff)| ((scratchVal[offset + 1] << 8) & 0xff00));
    
    return (float)((float)ambTemp / (float)128);
}


+(float) calcTObj:(NSData *)data {
    char scratchVal[data.length];
    int16_t objTemp;
    int16_t ambTemp;
    [data getBytes:&scratchVal length:data.length];
    objTemp = (scratchVal[0] & 0xff)| ((scratchVal[1] << 8) & 0xff00);
    ambTemp = ((scratchVal[2] & 0xff)| ((scratchVal[3] << 8) & 0xff00));
    
    float temp = (float)((float)ambTemp / (float)128);
    long double Vobj2 = (double)objTemp * .00000015625;
    long double Tdie2 = (double)temp + 273.15;
    long double S0 = 6.4*pow(10,-14);
    long double a1 = 1.75*pow(10,-3);
    long double a2 = -1.678*pow(10,-5);
    long double b0 = -2.94*pow(10,-5);
    long double b1 = -5.7*pow(10,-7);
    long double b2 = 4.63*pow(10,-9);
    long double c2 = 13.4f;
    long double Tref = 298.15;
    long double S = S0*(1+a1*(Tdie2 - Tref)+a2*pow((Tdie2 - Tref),2));
    long double Vos = b0 + b1*(Tdie2 - Tref) + b2*pow((Tdie2 - Tref),2);
    long double fObj = (Vobj2 - Vos) + c2*pow((Vobj2 - Vos),2);
    long double Tobj = pow(pow(Tdie2,4) + (fObj/S),.25);
    Tobj = (Tobj - 273.15);
    return (float)Tobj;
}

@end

//BG Relative Humidity
@implementation sensorSHT21

+(float) calcPress:(NSData *)data {
    char scratchVal[data.length];
    [data getBytes:&scratchVal length:data.length];
    UInt16 hum;
    float rHVal;
    hum = (scratchVal[2] & 0xff) | ((scratchVal[3] << 8) & 0xff00);
    rHVal = -6.0f + 125.0f * (float)((float)hum/(float)65535);
    return rHVal;
}
+(float) calcTemp:(NSData *)data {
    char scratchVal[data.length];
    [data getBytes:&scratchVal length:data.length];
    UInt16 temp;
    temp = (scratchVal[0] & 0xff) | ((scratchVal[1] << 8) & 0xff00);
    return (float)temp;
}


@end


@implementation sensorTagValues

@end
