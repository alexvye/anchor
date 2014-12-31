//
//  CustomCell.m
//  XFloss
//
//  Created by Alex Vye on 10-08-20.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CustomCell.h"
#import "DataManager.h"
#import "ProjectDB.h"
#import "ProjectFlossDB.h"
#import "FlossDB.h"
#import "XFlossAppDelegate.h"

@implementation CustomCell

@synthesize flossImage;
@synthesize shoppingButton;
@synthesize projectButton;
@synthesize anchorButton;
@synthesize primaryLabel;
@synthesize secondaryLabel;
@synthesize quantityTextField;
@synthesize data;
@synthesize source;

float primaryFont;
float secondaryFont;

int const INVENTORY = 1;
int const SHOPPING  = 2;
int const MATCHER   = 3;
int const PROJECT   = 4;
int const MYSTASH   = 5;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier source:(int)_source {

    self.source = _source;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        primaryFont = 12.0;
        secondaryFont = 10.0;
    } else {
        primaryFont = 24.0;
        secondaryFont = 20.0;
    }
    
    
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        // Initialization code
		
		//
		// labels
		//
		primaryLabel = [[UILabel alloc]init];
		primaryLabel.font = [UIFont fontWithName:@"Helvetica" size:primaryFont];
		secondaryLabel = [[UILabel alloc]init];
		secondaryLabel.font = [UIFont fontWithName:@"Helvetica" size:secondaryFont];
		
		//
		// images
		//
		flossImage = [[UIImageView alloc]init];
		
		//
		// buttons
		//
        
        if(self.source != SHOPPING) {
            shoppingButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            [shoppingButton setImage:[UIImage imageNamed:@"shopping.png"] forState:UIControlStateNormal];
            [shoppingButton addTarget:self
                           action:@selector(addToShoppingList:)
                 forControlEvents:UIControlEventTouchUpInside];
            [self.contentView addSubview:shoppingButton];
        }
        

		
		//
		// Only show project button if we have defined a project
		//
		if([DataManager instance].anyProjects && self.source != PROJECT) {

			projectButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
			[projectButton setImage:[UIImage imageNamed:@"887-notepad.png"] forState:UIControlStateNormal];
			[projectButton addTarget:self
                              action:@selector(addToProject:)
                    forControlEvents: UIControlEventTouchUpInside];
			[self.contentView addSubview:projectButton];
		}
        
        //
        // Quantity text field
        //
        if(self.source == MATCHER) {
            anchorButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            [anchorButton setImage:[UIImage imageNamed:@"836-anchor.png"] forState:UIControlStateNormal];
            [anchorButton addTarget:self
                             action:@selector(convertAnchor:)
                   forControlEvents:UIControlEventTouchUpInside];
    
        } else {
            
            quantityTextField = [[UITextField alloc] init];
            [quantityTextField setKeyboardType:UIKeyboardTypeNumbersAndPunctuation];
            [quantityTextField setReturnKeyType:UIReturnKeyDone];
            quantityTextField.delegate = self;
            quantityTextField.textAlignment = NSTextAlignmentCenter;
            quantityTextField.clearsOnBeginEditing = YES;
            quantityTextField.borderStyle = UITextBorderStyleBezel;
            [self.contentView addSubview:quantityTextField];
        }
        
		//
		// fields everyoone gets
		//
	    [self.contentView addSubview:primaryLabel];
		[self.contentView addSubview:secondaryLabel];
		[self.contentView addSubview:flossImage];
		
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(IBAction) addToProject: (UIButton*) aButton {
	[self popupActionSheet];
}

-(IBAction) convertAnchor: (UIButton*) aButton {
    
    FlossDB* floss = (FlossDB*)self.data;
    NSString* anchor = [[DataManager instance].anchorDMC valueForKey:floss.id];
	NSString *message = [NSString stringWithFormat:@"Anchor %@ is a match for DMC %@",
						 anchor, floss.id];
    
    [[DataManager instance] saveShopping:self.data];
	
	//
	// alert the user
	//
	UIAlertView *alertDialog;
	alertDialog = [[UIAlertView alloc]
				   initWithTitle:@"Anchor"
				   message:message
				   delegate:nil
				   cancelButtonTitle:@"Ok"
				   otherButtonTitles:nil];
	[alertDialog show];
}

-(void)popupActionSheet {
	
	//
	// If there are no projects, tell the user
	//
    NSArray* projects = [DataManager instance].loadProjects;
	NSString *message;
	if([projects count]<1) {
		message = @"No projects are defined.";
	} else {
		message = @"Cancel";
	}
	
    UIActionSheet *popupQuery = [[UIActionSheet alloc]
								 initWithTitle:@"Please select the project to add floss to"
								 delegate:self
								 cancelButtonTitle:nil
								 destructiveButtonTitle:nil
								 otherButtonTitles:nil];
    
	
	for(ProjectDB *project in projects) {
		[popupQuery addButtonWithTitle:project.name];
	}
	
	[popupQuery addButtonWithTitle:message];
    popupQuery.cancelButtonIndex = [projects count];
	
    popupQuery.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [popupQuery showInView:[self contentView]];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    //
    // Create new project floss db
    //
    XFlossAppDelegate *appDelegate = (XFlossAppDelegate *)[[UIApplication sharedApplication] delegate];
    ProjectFlossDB* projectFloss  = (ProjectFlossDB*) [NSEntityDescription insertNewObjectForEntityForName:@"ProjectFloss" inManagedObjectContext:appDelegate.managedObjectContext];
    
    
    //
    // copy floss db to project floss db
    //
    FlossDB* floss = (FlossDB*) self.data;
    projectFloss.id = floss.id;
    projectFloss.detailedLabel = floss.detailedLabel;
    projectFloss.primaryLabel = floss.primaryLabel;
    projectFloss.fileName = floss.fileName;
    projectFloss.quantity = [NSNumber numberWithInt:1];
    projectFloss.brand = floss.brand;

    //
    // save it
    //
    
     NSArray* projects = [DataManager instance].loadProjects;
	if(buttonIndex < [projects count]) {
		ProjectDB *project = [projects objectAtIndex:buttonIndex];
        [project addProjectFlossRelObject:projectFloss];
	}

    NSError *error;
    if(![appDelegate.managedObjectContext save:&error]) {
        NSLog(@"Error %@", [error localizedDescription]);
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"XSave" object:projectFloss];
}

-(IBAction) addToShoppingList: (UIButton*) aButton {

	NSString *message = [NSString stringWithFormat:@"Added %@ to shopping list.", 
						 [(UILabel *)[self secondaryLabel] text]];
    
    if(self.source == PROJECT) {
        ProjectFlossDB* projectFloss = (ProjectFlossDB*) self.data;
        self.data = [self getRealFlossFromProject:projectFloss.id];
    }
    
    [[DataManager instance] saveShopping:self.data];
	
	//
	// alert the user
	//
	UIAlertView *alertDialog;
	alertDialog = [[UIAlertView alloc]
				   initWithTitle:@"Shopping List Update"
				   message:message
				   delegate:nil
				   cancelButtonTitle:@"Ok"
				   otherButtonTitles:nil];
	[alertDialog show];
}

-(id) getRealFlossFromProject:(NSString*) flossID {
    
    XFlossAppDelegate *appDelegate = (XFlossAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"Floss" inManagedObjectContext:appDelegate.managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDesc];
    
    NSPredicate *fetchPredicate;
    fetchPredicate= [NSPredicate predicateWithFormat:@"id == %@", flossID];
    
    [request setPredicate:fetchPredicate];
    
    NSError *error;
    NSArray* result = [appDelegate.managedObjectContext executeFetchRequest:request error:&error];
    
    if(result.count > 0) {
        return [result objectAtIndex:0];
    } else {
        return nil;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
	[quantityTextField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    //
    // convert the string to a number. nil if invalid, becomes 0
    //
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    NSNumber *quantity = [formatter numberFromString:[(UITextField *)[self quantityTextField] text]  ];
    if(quantity == nil) {
        quantity = [NSNumber numberWithInt:0];
    }

    //
    // save it
    //
    FlossDB* floss = (FlossDB*)self.data;
    floss.quantity = quantity;
    
    [[DataManager instance] saveQuantity:floss];
}

- (void)layoutSubviews {
    [super layoutSubviews];
	CGRect contentRect = self.contentView.bounds;
	CGFloat boundsX = contentRect.origin.x;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {	
	//
	// images
	//
        flossImage.frame = CGRectMake(boundsX+1.0,2.0,40.0,40.0);
	
	//
	// labels
	//
        primaryLabel.frame = CGRectMake(boundsX+44.0,0.0,38.0,20.0);
        secondaryLabel.frame = CGRectMake(boundsX+49.0,16.0,97.0,20.0);
	
	//
	// buttons and textbox. Because project buttons and shopping buttons
    // don't always appear, need to dynamically set frames
	//
        CGRect frame1 = CGRectMake(boundsX+154.0,8.0,44.0,29.0);
        CGRect frame2 = CGRectMake(boundsX+207.0,8.0,44.0,29.0);
        CGRect frame3 = CGRectMake(boundsX+259.0,8.0,44.0,29.0);
        
        if(self.source == PROJECT || self.source == SHOPPING) {
            if(self.source == PROJECT) {
                shoppingButton.frame = frame1;
            } else {
                projectButton.frame = frame1;
            }
            quantityTextField.frame = frame2;
            
        } else if(self.source == MATCHER){
            projectButton.frame = frame1;
            shoppingButton.frame  = frame2;
            anchorButton.frame = frame3;
            
        } else {
            projectButton.frame = frame1;
            shoppingButton.frame  = frame2;
            quantityTextField.frame = frame3;
        }
    
} else { //IPad
    //
    // images
    //
    flossImage.frame = CGRectMake(boundsX+10.0,5.0,150.0,56);
    
    //
    // labels
    //
    primaryLabel.frame = CGRectMake(boundsX+170,5.0,100.0,25.0);
    secondaryLabel.frame = CGRectMake(boundsX+180.0,36.0,210,25.0);
    
    //
	// buttons and textbox. Because project buttons and shopping buttons
    // don't always appear, need to dynamically set frames
	//
    CGRect frame1 = CGRectMake(boundsX+420.0,10.0,60.0,46.0);
    CGRect frame2 = CGRectMake(boundsX+500,5.0,88.0,46.0);
    CGRect frame3 = CGRectMake(boundsX+600,5.0,70.0,46.0);
    
    if(self.source == PROJECT || self.source == SHOPPING) {
        if(self.source == PROJECT) {
            shoppingButton.frame = frame1;
        } else {
            projectButton.frame = frame1;
        }
        quantityTextField.frame = frame2;
        
    } else if(self.source == MATCHER){
        projectButton.frame = frame1;
        shoppingButton.frame  = frame2;
        anchorButton.frame = frame3;
        
    } else {
        projectButton.frame = frame1;
        shoppingButton.frame  = frame2;
        quantityTextField.frame = frame3;
    }
}
	

}

- (void)drawAnchor:(NSString*)dmc {
    NSString* anchor = [[DataManager instance].anchorDMC valueForKey:dmc];

    //
    // Not all dmc have an anchor map
    //
    if(anchor!=NULL) {
        [self.contentView addSubview:anchorButton];
    } else {
        [self.anchorButton removeFromSuperview];
    }
}

- (void)dealloc {
}


@end
