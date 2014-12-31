//
//  InventoryDetailTableViewController.m
//  XFloss
//
//  Created by Alex Vye on 10-08-05.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//
#import "InventoryDetailTableViewController.h"
#import "DataManager.h"
#import "CustomCell.h"
#import "FlossDB.h"
#import "UIViewController+ButtonMethods.h"
#import "XFlossAppDelegate.h"
#import "System.h"

static NSString *CustomCellIdentifier = @"CustomCell";
static NSString *CellIdentifier = @"Cell";

@implementation InventoryDetailTableViewController

float rowHeight;

@synthesize managedObjectContext;
@synthesize fetchedResultsController = __fetchedResultsController;
@synthesize group;
@synthesize passedBrand;

#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];
    
    //
    // set title
    //
    self.title = self.passedBrand;
    
    //
    // get managedContext
    //
    XFlossAppDelegate *appDelegate = (XFlossAppDelegate *)[[UIApplication sharedApplication] delegate];
    self.managedObjectContext = appDelegate.managedObjectContext;
    
    //
    // Set constants for different devices
    //
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        rowHeight = 44.0;
    } else {
        rowHeight = 66.0;
    }
    self.tableView.rowHeight = rowHeight;
    
    //
    // nav bar UIBarButtonSystemItemOrganize
    //
    [self setupRightMenuButton];
}

- (void)viewWillAppear:(BOOL)animated {
	
	//
	// Because a project might have been added, reload data to show P
	//
	[self.tableView reloadData];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
		
    //
    // Data section
    //
		
    CustomCell *cell = (CustomCell*) [tableView dequeueReusableCellWithIdentifier:CustomCellIdentifier];
        
    if (cell == nil) {
        cell = [[CustomCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CustomCellIdentifier source:INVENTORY];
    }

	//
    // Configure the cell...
	//
    
    NSManagedObject *managedObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
    FlossDB* floss = (FlossDB*) managedObject;
    cell.data = floss;

    [[cell primaryLabel] setText:floss.primaryLabel];
    if([floss.detailedLabel isEqual:@"NODESC"]) {
        [[cell secondaryLabel] setText:@""];
    } else {
        [[cell secondaryLabel] setText:floss.detailedLabel];
    }
    [[cell flossImage] setImage:[UIImage imageNamed:floss.fileName]];

    [[cell quantityTextField] setText:[NSString stringWithFormat:@"%d",floss.quantity.intValue]];
    return cell;
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

//
// clean up memory
//
- (void)dealloc {

}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (__fetchedResultsController != nil) {
        return __fetchedResultsController;
    }
    
    // Set up the fetched results controller.
    // Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Floss" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:5]; //default was 20
    
    // Edit the sort key as appropriate.
    
    NSSortDescriptor *sortDescriptor;
    
    
    //
    // anchor and dmc sort by id, the rest by label
    //
    if([passedBrand isEqual:@"dmc"] || [passedBrand isEqual:@"anchor"]) {
        sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"sort" ascending:YES];
    } else {
        sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"detailedLabel" ascending:YES];
    }
    
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    //
    // filter
    //
    
    NSPredicate *fetchPredicate;

    fetchPredicate= [NSPredicate predicateWithFormat:@"brand == %@ AND group == %d", self.passedBrand, group];
    
    [fetchRequest setPredicate:fetchPredicate];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
	    /*
	     Replace this implementation with code to handle the error appropriately.
         
	     abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
	     */
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return __fetchedResultsController;
}

@end

