//
//  MatcherViewController.m
//  XFloss
//
//  Created by Alex Vye on 10-08-21.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MatcherViewController.h"
#import "DataManager.h"
#import "CustomCell.h"
#import <CoreData/CoreData.h>
#import "FlossDB.h"
#import "UIViewController+ButtonMethods.h"
#import "XFlossAppDelegate.h"

static NSString *CustomCellIdentifier = @"CustomCell";
static NSString *CellIdentifier = @"Cell";

@implementation MatcherViewController

@synthesize searchBar;
@synthesize sdc;
@synthesize sortFloss;
@synthesize managedObjectContext;
@synthesize fetchedResultsController = __fetchedResultsController;
@synthesize searchIsActive;
@synthesize source;

float fontSize;
float descriptionFontSize;
float rowHeight;
float titleFontSize;
float searchBarHeight;

#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
    
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
        searchBarHeight = 44.0;
    } else {
        fontSize = 27.0;
        rowHeight = 66.0; 
        descriptionFontSize = 18.0; 
        titleFontSize = 15.0;
        searchBarHeight = 88.0;
    }
    self.tableView.rowHeight = rowHeight;
	
    //
	// Add search bar
	//
	self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f,44.0f)];
	self.searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
	self.searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
	self.searchBar.keyboardType = UIKeyboardTypeAlphabet;
    self.searchBar.delegate = self;
	self.tableView.tableHeaderView = self.searchBar;
	
	//
	// create search display controller
	//
    
	self.sdc = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
	self.sdc.searchResultsDelegate = self;
	self.sdc.searchResultsDataSource = self;
    self.sdc.delegate = self;
    
    //
    // nav bar UIBarButtonSystemItemOrganize
    //
    [self setupRightMenuButton];
}

- (IBAction) toggleEnabledForSwitch: (id) sender {
    __fetchedResultsController = nil;
    [self.tableView reloadData];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return rowHeight;
}


- (NSInteger)tableView:(UITableView *)_tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CustomCell *cell = (CustomCell*) [tableView dequeueReusableCellWithIdentifier:CustomCellIdentifier];
    
    if (cell == nil) {
        cell = [[CustomCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CustomCellIdentifier source:MATCHER];
    }
    
	//
    // Configure the cell...
	//
    
    NSManagedObject *managedObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
    FlossDB* floss = (FlossDB*) managedObject;
    cell.data = floss;
    [cell drawAnchor:floss.id];
    
    [[cell primaryLabel] setText:floss.primaryLabel];
    [[cell secondaryLabel] setText:floss.detailedLabel];
    [[cell flossImage] setImage:[UIImage imageNamed:floss.fileName]];
    
    [[cell quantityTextField] setText:[NSString stringWithFormat:@"%d",floss.quantity.intValue]];
    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {  
}
*/

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
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"sort" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    //
    // filter
    // re-using some code for matcher/mystash. if the source is mystash, filter where
    // quantiry > 0. else get all
    //
    
    if(self.source == MYSTASH) {
        NSPredicate *fetchPredicate;
        fetchPredicate = [NSPredicate predicateWithFormat:@"quantity > 0"];

        [fetchRequest setPredicate:fetchPredicate];
    }
    
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

#pragma mark UISearch delegate methods
-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    [self filterContentForSearchText:[self.searchDisplayController.searchBar text] scope:nil];
    return YES;
}


- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller {
    [self setSearchIsActive:YES];
    return;
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
    NSFetchRequest *aRequest = [[self fetchedResultsController] fetchRequest];
    
    [aRequest setPredicate:nil];
    
    NSError *error = nil;
    if (![[self fetchedResultsController] performFetch:&error]) {
        // Handle error
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    [self setSearchIsActive:NO];
    return;
}


#pragma mark -
#pragma mark content filtering

-(void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
    NSFetchRequest *request = [[self fetchedResultsController] fetchRequest];
    
    NSPredicate *predicate;
    if(self.source == MYSTASH) {
        predicate = [NSPredicate predicateWithFormat:@"quantity > 0 and (id contains[cd] %@ or detailedLabel contains[cd] %@)",searchText,searchText];
    } else {
        predicate = [NSPredicate predicateWithFormat:@"id contains[cd] %@ or detailedLabel contains[cd] %@",searchText,searchText];
    }
    [request setPredicate:predicate];
    
    
    NSError *error = nil;
    if(![[self fetchedResultsController] performFetch:&error]) {
        NSLog(@"Unresolved error %@ %@",error,[error userInfo]);
        abort();
    }
    
}

@end

