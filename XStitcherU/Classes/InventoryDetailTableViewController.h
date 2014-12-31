//
//  InventoryDetailTableViewController.h
//  XFloss
//
//  Created by Alex Vye on 10-08-05.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>


@interface InventoryDetailTableViewController : UITableViewController <NSFetchedResultsControllerDelegate> {
}

@property (assign, nonatomic) int group;
@property (strong, nonatomic) NSString* passedBrand;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@end
