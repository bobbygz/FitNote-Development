//
//  WorkoutLogController.h
//  FitNote
//
//  Created by Bobby Gintz on 3/5/14.
//  Copyright (c) 2014 Texas Instruments. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TrainingLogCellTemplate.h"
#import "AppDelegate.h"


@interface WorkoutLogController : UITableViewController <NSFetchedResultsControllerDelegate>
//@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@end
