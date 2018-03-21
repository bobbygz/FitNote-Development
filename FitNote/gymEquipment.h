//
//  gymEquipment.h
//  FitScribe
//
//  Created by Bobby Gintz on 1/7/14.
//  Copyright (c) 2014 Texas Instruments. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface gymEquipment : NSObject
@property NSString *sensorID;
@property NSString *gymEquipName;
@property NSString *gymEquipImage;
@property NSString *gymEquipMfr;



#define BG_SENSOR_1 @"DDC918F5-92B2-AA3C-DB24-81AAF623C6D0"         // Updated the UUID of old sensor tag based on what SW was reporting
#define RP_SENSOR_1 @"575C0FED-3494-A779-0D1E-45FE24439D7E"
#define RP_SENSOR_2 @"6CE6B061-D766-B62E-6B5E-C002E22AF119"
#define BG_SENSOR_WITH_16FW @"D150B658-7EB8-2E06-2672-846264727DED" // Updated sensor with 1.6 Firmware


@end
