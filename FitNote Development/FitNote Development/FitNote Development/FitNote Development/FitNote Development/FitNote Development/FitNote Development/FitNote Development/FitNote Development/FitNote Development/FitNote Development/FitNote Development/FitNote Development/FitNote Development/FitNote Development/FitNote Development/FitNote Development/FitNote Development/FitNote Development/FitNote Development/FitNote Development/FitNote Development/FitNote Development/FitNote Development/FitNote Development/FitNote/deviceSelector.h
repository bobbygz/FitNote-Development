/*
 *  deviceSelector.h
 *
 * Created by Ole Andreas Torvmark on 10/2/12.
 * Copyright (c) 2012 Texas Instruments Incorporated - http://www.ti.com/
 * ALL RIGHTS RESERVED
 */

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "BLEDevice.h"
#import "SensorTagApplicationViewController.h"
#import "fitnessEquipInventory.h"
#import <AVFoundation/AVFoundation.h>


@interface deviceSelector : UITableViewController <CBCentralManagerDelegate,CBPeripheralDelegate>

@property (strong,nonatomic) CBCentralManager *m;
@property (strong,nonatomic) NSMutableArray *nDevices;
@property (strong,nonatomic) NSMutableArray *sensorTags;
@property (strong, nonatomic) fitnessEquipInventory *equipment;


-(NSMutableDictionary *) makeSensorTagConfiguration;

@end

