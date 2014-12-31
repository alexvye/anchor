//
//  ShopperViewController.m
//  XStitcherUni
//
//  Created by Alex Vye on 12-03-29.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ShopperViewController.h"
#import "DataManager.h"
#import "FlossDB.h"
#import "CustomCell.h"
#import "UIViewController+ButtonMethods.h"
#import "XFlossAppDelegate.h"
#import "System.h"

static NSString *CustomCellIdentifier = @"CustomCell";
static NSString *CellIdentifier = @"Cell";

@implementation ShopperViewController

@synthesize managedObjectContext;
@synthesize fetchedResultsController = __fetchedResultsController;

float rowHeight;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    
    XFlossAppDelegate *appDelegate = (XFlossAppDelegate *)[[UIApplication sharedApplication] delegate];
    self.managedObjectContext = appDelegate.managedObjectContext;
    
    //
    // Set constants for different devices
    //
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        rowHeight = 44.0;
    } else {
        rowHeight = 80.0;
    }
    
    self.tableView.rowHeight = rowHeight;
    
    [super viewDidLoad];
    
    //
    // nav bar UIBarButtonSystemItemOrganize
    //
    [self setupRightMenuButton];
    
    //
    // tool bar
    //
    UIBarButtonItem *delete = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(turnOnEditing)];
    
    self.toolbarItems = [NSArray arrayWithObjects:delete, nil];
    self.navigationController.toolbarHidden = NO;
}

- (void)turnOnEditing {
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(turnOffEditing)];
    [self.tableView setEditing:YES animated:YES];
}

- (void)turnOffEditing {
    [self setupRightMenuButton];
    [self.tableView setEditing:NO animated:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    if(self.tableView != nil) {
        [self.tableView reloadData];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
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
		
    CustomCell *cell;

    if (cell == nil) {
        cell = [[CustomCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CustomCellIdentifier source:SHOPPING];
    }

    //
    // Configure the cell...
    NSManagedObject *managedObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
    FlossDB* floss = (FlossDB*) managedObject;
    cell.data = floss;
    
    [(UILabel *)[cell secondaryLabel] setText:floss.detailedLabel];
    [(UILabel *)[cell primaryLabel] setText:floss.primaryLabel];
    [[cell quantityTextField] setText:[NSString stringWithFormat:@"%d",floss.quantity.intValue]];
    [[cell flossImage] setImage:[UIImage imageNamed:floss.fileName]];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return true;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        //
        // not really deleting the floss, just set shopping quantity to 0
        //
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        FlossDB* floss = (FlossDB*)[self.fetchedResultsController objectAtIndexPath:indexPath];
        floss.shoppingQuantity = [NSNumber numberWithInt:0];
        
        // Save the context.
        NSError *error = nil;
        if (![context save:&error]) {
            
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }

        [self.tableView endUpdates];
        [self turnOffEditing];
        __fetchedResultsController = nil;   // force a re-query
        if(self.tableView != nil) {
            [self.tableView reloadData];
        }
    }
 
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}

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
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"id" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    //
    // filter
    //
    
    NSPredicate *fetchPredicate;

    fetchPredicate= [NSPredicate predicateWithFormat:@"shoppingQuantity > 0"];
    
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
