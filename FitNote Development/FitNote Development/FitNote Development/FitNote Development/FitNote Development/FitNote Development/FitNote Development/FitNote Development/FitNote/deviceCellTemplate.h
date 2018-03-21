/*
 *  deviceCellTemplate.h
 *
 * Created by Ole Andreas Torvmark on 10/2/12.
 * Copyright (c) 2012 Texas Instruments Incorporated - http://www.ti.com/
 * ALL RIGHTS RESERVED
 */


/*BG This file defines the cell template Objects for the following:
 * 
 * deviceCellTemplate - sensorTag device
 *
 * temperatureCellTemplate - used to display IR, relative humidity,
 * IR temp, and barometric pressure
 * 
 * accelerometerCellTemplate - used to display accelerometer, IMU (gyro)
 * Magnetometer
 */
#import <UIKit/UIKit.h>

// iPhone 5 568 x 320, -20 pts status bar = 548 and 300
#define IPHONE_LANDSCAPE_WIDTH 548.0
#define IPHONE_PORTRAIT_WIDTH 300.0
#define IPAD_LANDSCAPE_WIDTH 934.0
#define IPAD_PORTRAIT_WIDTH 678.0
#define WIDTH_CHECKER (IPHONE_LANDSCAPE_WIDTH + 1.0)

@interface deviceCellTemplate : UITableViewCell {
    UILabel *deviceName;
    UILabel *deviceInfo;
    UIImageView *deviceIcon;
    int height;
}

@property (nonatomic,retain) UILabel *deviceName;
@property (nonatomic,retain) UILabel *deviceInfo;
@property (nonatomic,retain) UIImageView *deviceIcon;
@property int height;

@end


@interface serviceWithoutPeriodCellTemplate : UITableViewCell {
    UILabel *serviceName;
    UISwitch *serviceOnOffButton;
    int height;
}

@property (nonatomic,retain) UILabel *serviceName;
@property (nonatomic,retain) UISwitch *serviceOnOffButton;
@property int height;

@end

@interface serviceWithPeriodCellTemplate : UITableViewCell {
    UILabel *serviceName;
    UISwitch *serviceOnOffButton;
    UISlider *servicePeriodSlider;
    UILabel *servicePeriodMax;
    UILabel *servicePeriodMin;
    UILabel *servicePeriodCur;
    int height;
}

@property (nonatomic,retain) UILabel *serviceName;
@property (nonatomic,retain) UISwitch *serviceOnOffButton;
@property (nonatomic,retain) UISlider *servicePeriodSlider;
@property (nonatomic,retain) UILabel *servicePeriodMax;
@property (nonatomic,retain) UILabel *servicePeriodMin;
@property (nonatomic,retain) UILabel *servicePeriodCur;
@property int height;

-(IBAction)updateSliderValue:(id)sender;

@end



@interface temperatureCellTemplate : UITableViewCell {
    UILabel *temperatureLabel;
    UIImageView *temperatureIcon;
    UILabel *temperature;
    UIProgressView *temperatureGraph;
    int height;
    UIView *temperatureGraphHolder;
}

@property (nonatomic,retain) UILabel *temperatureLabel;
@property (nonatomic,retain) UIImageView *temperatureIcon;
@property (nonatomic,retain) UILabel *temperature;
@property (nonatomic,retain) UIProgressView *temperatureGraph;
@property (nonatomic,retain)UIView *temperatureGraphHolder;

@property int height;
@end

@interface accelerometerCellTemplate : UITableViewCell {
    UILabel *accLabel;
    UIImageView *accIcon;
    UILabel *accValueX;
    UILabel *accValueY;
    UILabel *accValueZ;
    UIProgressView *accGraphX;
    UIProgressView *accGraphY;
    UIProgressView *accGraphZ;
    UIView *accGraphHolder;
    UIButton *accCalibrateButton;
    int height;
    UILabel *repcountLabel;
    

    
}

@property (nonatomic,retain) UILabel *accLabel;
@property (nonatomic,retain) UIImageView *accIcon;
@property (nonatomic,retain) UILabel *accValueX;
@property (nonatomic,retain) UILabel *accValueY;
@property (nonatomic,retain) UILabel *accValueZ;
@property (nonatomic,retain) UIProgressView *accGraphX;
@property (nonatomic,retain) UIProgressView *accGraphY;
@property (nonatomic,retain) UIProgressView *accGraphZ;
@property (nonatomic,retain) UIView *accGraphHolder;
@property (nonatomic,retain) UIButton *accCalibrateButton;
@property int height;

//BG Customizations for FitNote
@property (nonatomic,retain) UILabel *repcountLabel;


@end


//BG Cell template for FitNote Sensor Information
@interface fitnoteCellTemplate : UITableViewCell {
    UILabel *fitnLabel;
    UIImageView *fitnIcon;
    UILabel *fitnState;
    UILabel *fitnOrientation;
    UIButton *fitnCalibrateButton;
    UILabel *fitnrepcountLabel;
    int height;
}

@property (nonatomic,retain) UILabel *fitnLabel;
@property (nonatomic,retain) UIImageView *fitnIcon;
@property (nonatomic,retain) UILabel *fitnState;
@property (nonatomic,retain) UILabel *fitnOrientation;
@property (nonatomic,retain) UIButton *fitnCalibrateButton;
@property (nonatomic,retain) UILabel *fitnrepcountLabel;
@property int height;

@end
