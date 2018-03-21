//
//  ExerciseSetCellTemplate.h
//  FitScribe
//
//  Created by Bobby Gintz on 1/22/14.
//  Copyright (c) 2014 Texas Instruments. All rights reserved.
//

#import <UIKit/UIKit.h>

// iPhone 5 568 x 320, -20 pts status bar = 548 and 300
#define IPHONE_LANDSCAPE_WIDTH 548.0
#define IPHONE_PORTRAIT_WIDTH 300.0
#define IPAD_LANDSCAPE_WIDTH 934.0
#define IPAD_PORTRAIT_WIDTH 678.0
#define WIDTH_CHECKER (IPHONE_LANDSCAPE_WIDTH + 1.0)

@interface ExerciseSetCellTemplate : UITableViewCell {
    UILabel *numberOfReps;
    UILabel *weight;
    
    int height;
}


@property (nonatomic,retain) UILabel *numberOfReps;
@property (nonatomic,retain) UILabel *weight;
@property int height;
@end
