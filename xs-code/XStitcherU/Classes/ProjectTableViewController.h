//
//  ProjectTableViewController.h
//  XFloss
//
//  Created by Alex Vye on 10-10-30.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "ProjectDB.h"

@interface ProjectTableViewController : UITableViewController <NSFetchedResultsControllerDelegate> {
}

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) ProjectDB* project;

-(IBAction) addProject: (UIButton*) aButton;

@end
