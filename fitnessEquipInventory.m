//
//  fitnessEquipInventory.m
//  FitScribe
//
//  Created by Bobby Gintz on 1/9/14.
//  Copyright (c) 2014 Texas Instruments. All rights reserved.
//

#import "fitnessEquipInventory.h"

@implementation fitnessEquipInventory
@synthesize equipmentInventory;
- (id) init
{
    self = [super init];
    if (self){
        self.equipmentInventory = [[NSMutableArray alloc]init];
        
        gymEquipment *fitEquip =  [[gymEquipment alloc]init];
        fitEquip.sensorID  = BG_SENSOR_1;
        fitEquip.gymEquipImage= @"LifeFitness_Shoulder_Press.png";
        fitEquip.gymEquipMfr = @"LifeFitness";
        fitEquip.gymEquipName = @"Shoulder Press";
        [equipmentInventory addObject:fitEquip];
        
        
        gymEquipment *fitEquip2 =  [[gymEquipment alloc]init];
        fitEquip2.sensorID  = RP_SENSOR_1;
        fitEquip2.gymEquipImage= @"LifeFitness_Leg_Extension.png";
        fitEquip2.gymEquipMfr = @"LifeFitness";
        fitEquip2.gymEquipName = @"Leg Extension";
        [equipmentInventory addObject:fitEquip2];
        
        gymEquipment *fitEquip3 =  [[gymEquipment alloc]init];
        fitEquip3.sensorID  = RP_SENSOR_2;
        fitEquip3.gymEquipImage= @"LifeFitness_Rear_Deltoid.png";
        fitEquip3.gymEquipMfr = @"LifeFitness";
        fitEquip3.gymEquipName = @"Seated Row";
        [equipmentInventory addObject:fitEquip3];
        
        gymEquipment *fitEquip4 =  [[gymEquipment alloc]init];
        fitEquip4.sensorID  =  BG_SENSOR_WITH_16FW;
        fitEquip4.gymEquipImage= @"LifeFitness_Rear_Deltoid.png";
        fitEquip4.gymEquipMfr = @"LifeFitness";
        fitEquip4.gymEquipName = @"Seated Row";
        [equipmentInventory addObject:fitEquip4];
        
    }
    return self;
}



- (gymEquipment *) findEquipmentInInventory:(NSString *) lookupID;
{
    for (gymEquipment *searchEqupment in equipmentInventory){
        
        if ([searchEqupment.sensorID isEqualToString:lookupID])
            return searchEqupment;
    }
    return Nil;
}


@end
