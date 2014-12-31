//
//  ProjectAddViewController.h
//  XFloss
//
//  Created by Alex Vye on 10-10-30.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "ProjectDB.h"

@interface ProjectAddViewController : UIViewController <UITextFieldDelegate,UITextViewDelegate, UITableViewDataSource, UITableViewDataSource> {
    IBOutlet UIButton*  saveButton;
	IBOutlet UITextField *nameTextField;
	IBOutlet UITextView  *descriptionTextView;
    IBOutlet UITableView *tableView;
}

-(IBAction) saveProject: (UIButton*) aButton;

@property (retain,nonatomic) IBOutlet UITextField *nameTextField;
@property (retain,nonatomic) IBOutlet UITextView  *descriptionTextView;
@property (nonatomic,retain) IBOutlet UIButton*  saveButton;
@property (nonatomic,retain) IBOutlet UITableView *tableView;
@property (nonatomic,retain) ProjectDB* project;
@property (nonatomic,retain) NSArray* projectFloss;

- (void)setupButton:(UIButton *)button title:(NSString *)title backgroundImage:(UIImage *)image;

@end
