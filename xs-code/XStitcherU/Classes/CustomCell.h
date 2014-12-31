//
//  CustomCell.h
//  XFloss
//
//  Created by Alex Vye on 10-08-20.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//
extern int const INVENTORY;
extern int const SHOPPING;
extern int const MATCHER;
extern int const PROJECT;
extern int const MYSTASH;

#import <UIKit/UIKit.h>

@interface CustomCell : UITableViewCell <UITextFieldDelegate,UIActionSheetDelegate>{
	IBOutlet UIImageView *flossImage;
	IBOutlet UIButton *shoppingButton;
	IBOutlet UIButton *projectButton;
    IBOutlet UIButton *anchorButton;
	IBOutlet UILabel  *primaryLabel;
	IBOutlet UILabel  *secondaryLabel;
    IBOutlet UITextField  *quantityTextField;
}

@property (nonatomic,retain)IBOutlet UIImageView *flossImage;
@property (nonatomic,retain)IBOutlet UIButton *shoppingButton;
@property (nonatomic,retain)IBOutlet UIButton *projectButton;
@property (nonatomic,retain)IBOutlet UIButton *anchorButton;
@property (nonatomic,retain)IBOutlet UILabel  *primaryLabel;
@property (nonatomic,retain)IBOutlet UILabel  *secondaryLabel;
@property (nonatomic,retain)IBOutlet UITextField  *quantityTextField;
@property (nonatomic,retain) id data;
@property (nonatomic) int source;

-(void)drawAnchor:(NSString*)dmc;
-(IBAction) convertAnchor: (UIButton*) aButton;
-(IBAction) addToShoppingList: (UIButton*) aButton;
-(IBAction) addToProject: (UIButton*) aButton;
-(void)popupActionSheet;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier source:(int)_source;
-(id) getRealFlossFromProject:(NSString*) flossID;

@end
