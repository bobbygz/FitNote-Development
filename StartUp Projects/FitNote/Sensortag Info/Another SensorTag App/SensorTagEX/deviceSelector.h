//
//  deviceSelector.h
//  TI BLE SensorTag Example
//
//  Created by Ole Andreas Torvmark on 11/15/12.
//  Copyright (c) 2012 Texas Instruments. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "BLEDevice.h"
#import "SensorTagApplicationViewController.h"

@interface deviceSelector : UITableViewController <CBCentralManagerDelegate,CBPeripheralDelegate>

@property (strong,nonatomic) CBCentralManager *m;
@property (strong,nonatomic) NSMutableArray *nDevices;
@property (strong,nonatomic) NSMutableArray *sensorTags;


-(NSMutableDictionary *) makeSensorTagConfiguration;

@end

