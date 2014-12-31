//
//  ProjectTableViewController.m
//  XFloss
//
//  Created by Alex Vye on 10-10-30.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ProjectTableViewController.h"
#import "ProjectAddViewController.h"
#import "DataManager.h"
#import "ProjectAddViewController.h"
#import "ProjectDB.h"
#import "UIViewController+ButtonMethods.h"
#import "XFlossAppDelegate.h"
#import "System.h"
#import "CustomCell.h"

@implementation ProjectTableViewController

@synthesize managedObjectContext;
@synthesize fetchedResultsController = __fetchedResultsController;
@synthesize project;

float rowHeight;

-(IBAction) addProject: (UIButton*) aButton {
    self.project = nil;
    [self performSegueWithIdentifier:@"addProject" sender:self];
}

-(IBAction) peekMenu: (UIButton*) aButton {
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    XFlossAppDelegate *appDelegate = (XFlossAppDelegate *)[[UIApplication sharedApplication] delegate];
    self.managedObjectContext = appDelegate.managedObjectContext;
    
    [super viewDidLoad];
    
    //
    // Set constants for different devices
    //
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        rowHeight = 44.0;
    } else {
        rowHeight = 80.0;
    }
    
    self.tableView.rowHeight = rowHeight;
    
    //
    // nav bar UIBarButtonSystemItemOrganize
    //
    [self setupRightMenuButton];
    
    //
    // tool bar
    //
    UIBarButtonItem *add = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addProject:)];
    UIBarButtonItem *delete = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(turnOnEditing)];

    self.toolbarItems = [NSArray arrayWithObjects:add,delete, nil];
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
    self.project = nil;
    __fetchedResultsController = nil;
    [self.tableView reloadData];
}

#pragma mark -
#pragma mark Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return rowHeight;
}

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
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    //
    // Configure the cell...
    //
    NSManagedObject *managedObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
    ProjectDB* tempProject = (ProjectDB*) managedObject;
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    [cell textLabel].text = tempProject.name;
        
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return true;
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
            
        // Save the context.
        NSError *error = nil;
        if (![self.managedObjectContext save:&error]) {

            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
        __fetchedResultsController = nil;
        [self.tableView endUpdates];
        [self.tableView reloadData];
    } else {
        [self performSegueWithIdentifier:@"addProject" sender:self];
    }
}
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:indexPath.section];
    int rows = (int)[sectionInfo numberOfObjects];
    
    if(indexPath.row > rows-1) {
        return UITableViewCellEditingStyleInsert;
    } else {
        return UITableViewCellEditingStyleDelete;
    }
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //
    // get a row count
    //
    NSManagedObject *managedObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
    self.project = (ProjectDB*) managedObject;
    [self performSegueWithIdentifier:@"addProject" sender:self];
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
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)dealloc {
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
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Project" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:5]; //default was 20
    
    // Edit the sort key as appropriate.
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    //
    // filter
    //
    
    NSPredicate *fetchPredicate;
    
    //fetchPredicate= [NSPredicate predicateWithFormat:@"shoppingQuantity <> 0"];
    
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    if ([[segue identifier] isEqualToString:@"addProject"]) {
        ProjectAddViewController *pAddControl = [segue destinationViewController];
        pAddControl.project = self.project;
    }
}
@end

