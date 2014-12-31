//
//  InventoryTableViewController.h
//  XFloss
//
//  Created by Alex Vye on 10-08-05.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>


@interface InventoryTableViewController : UITableViewController <NSFetchedResultsControllerDelegate> {

}

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (assign, nonatomic) NSString* passedBrand;

@end
