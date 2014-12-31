//
//  ProjectAddViewController.m
//  XFloss
//
//  Created by Alex Vye on 10-10-30.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ProjectAddViewController.h"
#import "DataManager.h"
#import "ProjectDB.h"
#import "FlossDB.h"
#import "CustomCell.h"
#import "XFlossAppDelegate.h"
#import "ProjectFlossDB.h"

@implementation ProjectAddViewController

@synthesize descriptionTextView;
@synthesize nameTextField;
@synthesize saveButton;
@synthesize tableView;
@synthesize project;
@synthesize projectFloss;

float rowHeight;

-(BOOL) textFieldShouldReturn:(UITextField*) textField {
    [textField resignFirstResponder]; 
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range 
 replacementText:(NSString *)text
{
    // Any new character added is passed in as the "text" parameter
    if ([text isEqualToString:@"\n"]) {
        // Be sure to test for equality using the "isEqualToString" message
        [textView resignFirstResponder];
		
        // Return FALSE so that the final '\n' character doesn't get added
        return FALSE;
    }
    // For any other character return TRUE so that the text gets added to the view
    return TRUE;
}

- (void)turnOnEditing {
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(turnOffEditing)];
    [self.tableView setEditing:YES animated:YES];
}

- (void)turnOffEditing {
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(turnOnEditing)];
    [self.tableView setEditing:NO animated:YES];
}

-(IBAction) saveProject: (UIButton*) aButton {
	//
	// save project then pop the view controller
	//
    // for add case, self.project will be nil
    //
    XFlossAppDelegate *appDelegate = (XFlossAppDelegate *)[[UIApplication sharedApplication] delegate];
    if(self.project == nil) {
        self.project = (ProjectDB*) [NSEntityDescription insertNewObjectForEntityForName:@"Project" inManagedObjectContext:appDelegate.managedObjectContext];
    }
    
    project.name = [self.nameTextField text];
    project.desc = [self.descriptionTextView text];
    
    //
    // Save
    //
    NSError *error;
    if(![appDelegate.managedObjectContext save:&error]) {
        NSLog(@"Error %@", [error localizedDescription]);
    }

    //
    // pop back to project list screen
    //
	[self.navigationController popViewControllerAnimated:false];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    //
    // sort the project floss
    //
    self.projectFloss = [[self.project.projectFlossRel.objectEnumerator allObjects] sortedArrayUsingComparator:^(ProjectFlossDB *a, ProjectFlossDB *b) {
        return [a.id compare:b.id
                     options:NSNumericSearch];
        }];

    //
    // save button
    //
    UIImage *grayBackground = [[UIImage imageNamed:@"Btn-Blue.png"] stretchableImageWithLeftCapWidth:4 topCapHeight:3];
    [self setupButton:self.saveButton title:@" Save" backgroundImage:grayBackground];
    
    //
    // setup data
    //
    //
    // Set constants for different devices
    //
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        rowHeight = 44.0;
    } else {
        rowHeight = 80.0;
    }
    
    self.tableView.rowHeight = rowHeight;
    // coming as an edit, project not nil
    //
    
    if(self.project != nil) {
        [self.nameTextField setText:project.name];
        [self.descriptionTextView setText:project.desc];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self turnOffEditing];
    if(self.tableView != nil) {
        [self.tableView reloadData];
    }
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)dealloc {
}

- (void)setupButton:(UIButton *)button title:(NSString *)title backgroundImage:(UIImage *)image {
    
    UIFont *customFont = [UIFont fontWithName:@"NeutraText-BoldAlt" size:15];
    
    button.titleLabel.textAlignment = NSTextAlignmentLeft;
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitle:title forState:UIControlStateHighlighted];
    [button.titleLabel setFont:customFont];
    
    [button setBackgroundImage:image forState:UIControlStateNormal];
    
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:button.bounds];
    button.layer.masksToBounds = NO;
    button.layer.shadowColor = [UIColor blackColor].CGColor;
    button.layer.shadowOffset = CGSizeMake(4.0f, 5.0f);
    button.layer.shadowOpacity = 0.4f;
    button.layer.shadowPath = shadowPath.CGPath;
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[[self.project.projectFlossRel objectEnumerator] allObjects] count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CustomCellIdentifier = @"Cell";
    
    ProjectFlossDB* floss = [self.projectFloss objectAtIndex:indexPath.row];

    CustomCell *cell = (CustomCell*) [self.tableView dequeueReusableCellWithIdentifier:CustomCellIdentifier];
    
    if (cell == nil) {
        cell = [[CustomCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CustomCellIdentifier source:PROJECT];
    }

	//
    // Configure the cell...
	//

    cell.data = floss;
    
    [[cell primaryLabel] setText:floss.primaryLabel];
    [[cell secondaryLabel] setText:floss.detailedLabel];
    [[cell flossImage] setImage:[UIImage imageNamed:floss.fileName]];
    
    [[cell quantityTextField] setText:[NSString stringWithFormat:@"%d",floss.quantity.intValue]];

    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return true;
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	XFlossAppDelegate *appDelegate = (XFlossAppDelegate *)[[UIApplication sharedApplication] delegate];
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        NSManagedObjectContext *context = appDelegate.managedObjectContext;
        [context deleteObject:[[self.project.projectFlossRel.objectEnumerator allObjects] objectAtIndex:indexPath.row]];
        
        // Save the context.
        NSError *error = nil;
        if (![context save:&error]) {
            
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
        [self.tableView endUpdates];
        [self.tableView reloadData];
    }
}
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}

@end
