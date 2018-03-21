//
//  exerciseSet.h
//  FitScribe
//
//  Created by Bobby Gintz on 1/27/14.
//  Copyright (c) 2014 Texas Instruments. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface exerciseSet : NSObject
@property NSString *equipmentName;
@property NSUInteger numberOfRepsCompleted;
@property NSDate  *startTime;
@property NSDate *stopTime;
@property NSUInteger weight;
@property int restInterval;
@property int stopwatchTime;
@end
