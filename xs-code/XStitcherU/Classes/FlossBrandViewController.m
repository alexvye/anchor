//
//  FlossBrandViewController.m
//  XStitcherU
//
//  Created by Alex Vye on 2013-09-14.
//
//

#import "FlossBrandViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "UIViewController+ButtonMethods.h"
#import "Globals.h"
#import "InventoryTableViewController.h"
#import "MatcherViewController.h"
#import "CustomCell.h"

@implementation FlossBrandViewController

@synthesize inventoryButton, matcherButton, projectButton, shoppingButton, specialtyButton, storeButton;
@synthesize myStashButton, helpButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self setupRightMenuButton];
    
    UIImage *grayBackground = [[UIImage imageNamed:@"Btn-Blue.png"] stretchableImageWithLeftCapWidth:4 topCapHeight:3];
    
    [self setupButton:self.inventoryButton title:@" Inventory" backgroundImage:grayBackground];
    [self setupButton:self.shoppingButton title:@" Shopping" backgroundImage:grayBackground];
    [self setupButton:self.projectButton title:@" Projects" backgroundImage:grayBackground];
    [self setupButton:self.matcherButton title:@" Matcher" backgroundImage:grayBackground];
    [self setupButton:self.storeButton title:@" Store" backgroundImage:grayBackground];
    [self setupButton:self.specialtyButton title:@" Specialty" backgroundImage:grayBackground];
    [self setupButton:self.myStashButton title:@" My stash" backgroundImage:grayBackground];
    [self setupButton:self.helpButton title:@" Help" backgroundImage:grayBackground];
    //
    // hide the store button until we download the prod ids
    //
    self.storeButton.hidden = true;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.toolbarHidden = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showShop:(NSNotification *)note {
    self.storeButton.hidden = false;
}

- (void)setupButton:(UIButton *)button title:(NSString *)title backgroundImage:(UIImage *)image {
    
    UIFont *customFont = [UIFont fontWithName:@"NeutraText-BoldAlt" size:buttonFontSize];
    
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

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"InventorySeque"]) {
        InventoryTableViewController* inventory = (InventoryTableViewController*) segue.destinationViewController;
        inventory.passedBrand = @"dmc";
    } else if([segue.identifier isEqualToString:@"MatcherSeque"]) {
        MatcherViewController* matcher = (MatcherViewController*) segue.destinationViewController;
        matcher.source = MATCHER;
    } else if([segue.identifier isEqualToString:@"MyStashSeque"]) {
        MatcherViewController* matcher = (MatcherViewController*) segue.destinationViewController;
        matcher.source = MYSTASH;
    }
}

@end
