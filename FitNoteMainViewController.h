//
//  FitNoteMainViewController.h
//  FitScribe
//
//  Created by Bobby Gintz on 2/4/14.
//  Copyright (c) 2014 Texas Instruments. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FitNoteMainViewController : UIViewController <NSFetchedResultsControllerDelegate>

- (IBAction)handleStartButton:(UIButton *)sender;
- (IBAction)handleWorkoutButtom:(UIButton *)sender;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end
