//
//  exerciseSet.m
//  FitScribe
//
//  Created by Bobby Gintz on 1/27/14.
//  Copyright (c) 2014 Texas Instruments. All rights reserved.
//

#import "exerciseSet.h"

@implementation exerciseSet

- (id)init
{
    self = [super init];
    if (self) {
        self.equipmentName = nil;
        self.numberOfRepsCompleted = 0;
        self.weight = 0;
        self.stopwatchTime = 0;
        self.restInterval = 0;
    
    }
    return self;
}
@end
