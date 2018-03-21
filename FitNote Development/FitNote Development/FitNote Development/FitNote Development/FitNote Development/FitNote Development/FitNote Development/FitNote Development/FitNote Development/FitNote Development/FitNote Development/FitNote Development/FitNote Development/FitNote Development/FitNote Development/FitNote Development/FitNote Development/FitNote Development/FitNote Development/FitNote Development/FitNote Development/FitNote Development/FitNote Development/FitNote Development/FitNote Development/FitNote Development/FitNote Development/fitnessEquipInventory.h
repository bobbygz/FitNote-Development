//
//  fitnessEquipInventory.h
//  FitScribe
//
//  Created by Bobby Gintz on 1/9/14.
//  Copyright (c) 2014 Texas Instruments. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "gymEquipment.h"

@interface fitnessEquipInventory : NSObject
@property NSMutableArray *equipmentInventory;
- (gymEquipment *) findEquipmentInInventory:(NSString *) lookupID;

@end
