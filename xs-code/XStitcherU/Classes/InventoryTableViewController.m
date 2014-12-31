//
//  InventoryTableViewController.m
//  XFloss
//
//  Created by Alex Vye on 10-08-05.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "InventoryTableViewController.h"
#import "InventoryDetailTableViewController.h"
#import "DataManager.h"
#import "BrandDB.h"
#import "UIViewController+ButtonMethods.h"
#import "XFlossAppDelegate.h"

@implementation InventoryTableViewController

int group;

@synthesize managedObjectContext;
@synthesize fetchedResultsController = __fetchedResultsController;
@synthesize passedBrand;

#pragma mark -
#pragma mark View lifecycle

float fontSize;
float descriptionFontSize;
float rowHeight;
float titleFontSize;

- (void)viewDidLoad {
    //
    // default the brand
    //
    if(self.passedBrand == nil) {
        self.passedBrand = @"dmc";
    }
    
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
        fontSize = 18.0;
        rowHeight = 44.0;
        descriptionFontSize = 12.0;
        titleFontSize = 12.0;
    } else {
        fontSize = 27.0;
        rowHeight = 80.0;
        descriptionFontSize = 18.0; 
        titleFontSize = 15.0;
    }
    
    self.tableView.rowHeight = rowHeight;
    
    [self setupRightMenuButton];
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
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell;

    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    NSManagedObject *managedObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
    BrandDB* brand = (BrandDB*) managedObject;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    [[cell textLabel] setFont:[UIFont systemFontOfSize:fontSize]];
    [[cell textLabel] setText:brand.name];

    return cell;
}
 

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    group = (int)indexPath.row;
    [self performSegueWithIdentifier:@"flossDetail" sender:self];
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


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
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Brand" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:5]; //default was 20
    
    // Edit the sort key as appropriate.
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"group" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    //
    // filter
    //
    
    NSPredicate* fetchPredicate= [NSPredicate predicateWithFormat:@"brand == %@", self.passedBrand];

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

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    InventoryDetailTableViewController* detail = (InventoryDetailTableViewController*) segue.destinationViewController;
    detail.group = group;
    detail.passedBrand = self.passedBrand;
}

@end

