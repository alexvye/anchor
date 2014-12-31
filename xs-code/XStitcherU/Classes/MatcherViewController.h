//
//  MatcherViewController.h
//  XFloss
//
//  Created by Alex Vye on 10-08-21.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface MatcherViewController : UITableViewController <UISearchBarDelegate,UISearchDisplayDelegate,NSFetchedResultsControllerDelegate>{
	IBOutlet UISearchBar *searchBar;
	IBOutlet UISearchDisplayController *sdc;
    NSMutableArray *sortFloss;
}

@property(retain,nonatomic) IBOutlet UISearchBar *searchBar;
@property(retain,nonatomic) IBOutlet UISearchDisplayController *sdc;
@property(retain,nonatomic) IBOutlet NSMutableArray *sortFloss;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property BOOL searchIsActive;
@property int source;

- (IBAction) toggleEnabledForSwitch: (id) sender;

@end
