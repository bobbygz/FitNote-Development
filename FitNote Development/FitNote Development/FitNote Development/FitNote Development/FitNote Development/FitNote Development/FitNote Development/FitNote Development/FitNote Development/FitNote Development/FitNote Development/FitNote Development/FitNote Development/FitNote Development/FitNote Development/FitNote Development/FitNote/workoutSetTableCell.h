//
//  workoutSetTableCell.h
//  FitNote
//
//  Created by Bobby Gintz on 2/10/14.
//  Copyright (c) 2014 Texas Instruments. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface workoutSetTableCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *setNumber;
@property (strong, nonatomic) IBOutlet UILabel *reps;
@property (strong, nonatomic) IBOutlet UILabel *weight;
@property (strong, nonatomic) IBOutlet UILabel *restTime;
@property (strong, nonatomic) IBOutlet UILabel *medals;
@property (strong, nonatomic) IBOutlet UIView *workoutTableCellView;

@end
