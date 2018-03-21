//
//  Activity.h
//  FitNote
//
//  Created by Bobby Gintz on 3/3/14.
//  Copyright (c) 2014 Texas Instruments. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Activity : NSManagedObject

@property (nonatomic, retain) NSDate * finishtime;
@property (nonatomic, retain) NSNumber * repetitions;
@property (nonatomic, retain) NSDate * startTime;
@property (nonatomic, retain) NSNumber * weight;
@property (nonatomic, retain) NSString * machineName;
@property (nonatomic, retain) NSString * machineImage;
@property (nonatomic, retain) NSString * machineManufacturer;
@property (nonatomic, retain) NSString * machineID;

@end
