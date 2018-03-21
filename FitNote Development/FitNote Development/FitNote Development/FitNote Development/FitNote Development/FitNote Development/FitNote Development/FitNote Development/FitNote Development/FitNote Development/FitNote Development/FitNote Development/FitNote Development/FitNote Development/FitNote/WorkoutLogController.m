//
//  WorkoutLogController.m
//  FitNote
//
//  Created by Bobby Gintz on 3/5/14.
//  Copyright (c) 2014 Texas Instruments. All rights reserved.
//

#import "WorkoutLogController.h"
#import "Activity.h"


@implementation WorkoutLogController


#pragma mark - View lifecycle

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    // Set up the edit and add buttons.
    //self.navigationItem.leftBarButtonItem = self.editButtonItem;
    
    NSError *error;
    if (![[self fetchedResultsController] performFetch:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
}


- (void)viewWillAppear {
    
    [self.tableView reloadData];
}


- (void)viewDidUnload {
    
    // Release any properties that are loaded in viewDidLoad or can be recreated lazily.
    self.fetchedResultsController = nil;
}

#pragma mark ManagedObjectContext
-(NSManagedObjectContext*) managedObjectContext {
    return[(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
}

#pragma mark - Table view data source methods

/*
 The data source methods are handled primarily by the fetch results controller
 */

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    
    // Each day the user worked out will be a section in the tableview so need to
    // Identify the number of days uniquely
    
    NSMutableArray *activityDates = [[NSMutableArray alloc]init];
    
    // To get date and time from an object
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    
    NSDateFormatter *timeFormat = [[NSDateFormatter alloc] init];
    [timeFormat setDateFormat:@"HH:mm:ss"];
    
    NSDate *now = [[NSDate alloc] init];
    
    NSString *theDate = [dateFormat stringFromDate:now];
    NSString *theTime = [timeFormat stringFromDate:now];
    
    NSLog(@"\n"
          "theDate: |%@| \n"
          "theTime: |%@| \n"
          , theDate, theTime);

    
    // enumerate through the fetched results and build an array of
    for (Activity *object in self.fetchedResultsController.fetchedObjects){
    NSDate *tempDate = object.startTime;
    NSString *dateOfActivity = [dateFormat stringFromDate:tempDate];
        if (![activityDates containsObject:dateOfActivity ]){
            NSString *newDate = [[NSString alloc] init];
            newDate = dateOfActivity;
            [activityDates addObject:newDate];
        }

        
        
     
     
    }

    //[activityDates addObjectsFromArray:self.fetchedResultsController.fetchedObjects];
    
    
    
    return [activityDates count];
    //return [[self.fetchedResultsController sections] count];
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}


// Customize the appearance of table view cells.
- (void)configureCell:(TrainingLogCellTemplate *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    
    Activity *activity= [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSDate *date = activity.startTime;
    [dateFormatter setDateFormat:@"yyyy-MM-dd 'at' HH:mm"];
    NSString *formattedDateString = [dateFormatter stringFromDate:date];
    
    cell.trainingLogCellTitle.text = formattedDateString;
    

}

- (TrainingLogCellTemplate *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Log";
    TrainingLogCellTemplate *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell.
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    // Display the authors' names as section headings.
    return [[[self.fetchedResultsController sections] objectAtIndex:section] name];
}


//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
//    
//    if (editingStyle == UITableViewCellEditingStyleDelete) {
//        
//        // Delete the managed object.
//        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
//        [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
//        
//        NSError *error;
//        if (![context save:&error]) {
//            /*
//             Replace this implementation with code to handle the error appropriately.
//             
//             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//             */
//            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
//            abort();
//        }
//    }
//}


#pragma mark - Table view editing

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // The table view should not be re-orderable.
    return NO;
}


//- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
//    
//    [super setEditing:editing animated:animated];
//    
//    if (editing) {
//        self.rightBarButtonItem = self.navigationItem.rightBarButtonItem;
//        self.navigationItem.rightBarButtonItem = nil;
//    }
//    else {
//        self.navigationItem.rightBarButtonItem = self.rightBarButtonItem;
//        self.rightBarButtonItem = nil;
//    }
//}


#pragma mark - Fetched results controller

/*
 Returns the fetched results controller. Creates and configures the controller if necessary.
 */
- (NSFetchedResultsController *)fetchedResultsController {
    
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    // Create and configure a fetch request with the Book entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Activity" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Create the sort descriptors array.
    NSSortDescriptor *startDescriptor = [[NSSortDescriptor alloc] initWithKey:@"startTime" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc]initWithObjects:startDescriptor, nil];
    //NSSortDescriptor *machineDescriptor = [[NSSortDescriptor alloc] initWithKey:@"machineID" ascending:YES];
    //NSArray *sortDescriptors = @[startDescriptor, machineDescriptor];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Create and initialize the fetch results controller.
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"startTime" cacheName:nil];
    _fetchedResultsController.delegate = self;
    
    return _fetchedResultsController;
}


/*
 NSFetchedResultsController delegate methods to respond to additions, removals and so on.
 */
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    [self.tableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = self.tableView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    
    // The fetch controller has sent all current change notifications, so tell the table view to process all updates.
    [self.tableView endUpdates];
}


#pragma mark - Segue management

//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    
//    if ([[segue identifier] isEqualToString:@"AddBook"]) {
//        
//        /*
//         The destination view controller for this segue is an AddViewController to manage addition of the book.
//         This block creates a new managed object context as a child of the root view controller's context. It then creates a new book using the child context. This means that changes made to the book remain discrete from the application's managed object context until the book's context is saved.
//         The root view controller sets itself as the delegate of the add controller so that it can be informed when the user has completed the add operation -- either saving or canceling (see addViewController:didFinishWithSave:).
//         IMPORTANT: It's not necessary to use a second context for this. You could just use the existing context, which would simplify some of the code -- you wouldn't need to perform two saves, for example. This implementation, though, illustrates a pattern that may sometimes be useful (where you want to maintain a separate set of edits).
//         */
//        
//        UINavigationController *navController = (UINavigationController *)[segue destinationViewController];
//        AddViewController *addViewController = (AddViewController *)[navController topViewController];
//        addViewController.delegate = self;
//        
//        // Create a new managed object context for the new book; set its parent to the fetched results controller's context.
//        NSManagedObjectContext *addingContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
//        [addingContext setParentContext:[self.fetchedResultsController managedObjectContext]];
//        
//        Book *newBook = (Book *)[NSEntityDescription insertNewObjectForEntityForName:@"Book" inManagedObjectContext:addingContext];
//        addViewController.book = newBook;
//        addViewController.managedObjectContext = addingContext;
//    }
//    
//    if ([[segue identifier] isEqualToString:@"ShowSelectedBook"]) {
//        
//        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
//        Book *selectedBook = (Book *)[[self fetchedResultsController] objectAtIndexPath:indexPath];
//        
//        // Pass the selected book to the new view controller.
//        DetailViewController *detailViewController = (DetailViewController *)[segue destinationViewController];
//        detailViewController.book = selectedBook;
//    }
//}


#pragma mark - Add controller delegate

/*
 Add controller's delegate method; informs the delegate that the add operation has completed, and indicates whether the user saved the new book.
 */
//- (void)addViewController:(AddViewController *)controller didFinishWithSave:(BOOL)save {
//    
//    if (save) {
//        /*
//         The new book is associated with the add controller's managed object context.
//         This means that any edits that are made don't affect the application's main managed object context -- it's a way of keeping disjoint edits in a separate scratchpad. Saving changes to that context, though, only push changes to the fetched results controller's context. To save the changes to the persistent store, you have to save the fetch results controller's context as well.
//         */
//        NSError *error;
//        NSManagedObjectContext *addingManagedObjectContext = [controller managedObjectContext];
//        if (![addingManagedObjectContext save:&error]) {
//            /*
//             Replace this implementation with code to handle the error appropriately.
//             
//             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//             */
//            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
//            abort();
//        }
//        
//        if (![[self.fetchedResultsController managedObjectContext] save:&error]) {
//            /*
//             Replace this implementation with code to handle the error appropriately.
//             
//             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//             */
//            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
//            abort();
//        }
//    }
//    
//    // Dismiss the modal view to return to the main list
//    [self dismissViewControllerAnimated:YES completion:nil];
//}


@end
