//
//  FlossBrandViewController.h
//  XStitcherU
//
//  Created by Alex Vye on 2013-09-14.
//
//

#import <UIKit/UIKit.h>

@interface FlossBrandViewController : UIViewController {
	IBOutlet UIButton*  inventoryButton;
    IBOutlet UIButton*  shoppingButton;
    IBOutlet UIButton*  projectButton;
    IBOutlet UIButton*  matcherButton;
    IBOutlet UIButton*  specialtyButton;
    IBOutlet UIButton*  storeButton;
}

@property (nonatomic,retain) IBOutlet UIButton*  inventoryButton;
@property (nonatomic,retain) IBOutlet UIButton*  shoppingButton;
@property (nonatomic,retain) IBOutlet UIButton*  projectButton;
@property (nonatomic,retain) IBOutlet UIButton*  matcherButton;
@property (nonatomic,retain) IBOutlet UIButton*  specialtyButton;
@property (nonatomic,retain) IBOutlet UIButton*  storeButton;
@property (nonatomic,retain) IBOutlet UIButton*  myStashButton;
@property (nonatomic,retain) IBOutlet UIButton*  helpButton;

- (void)setupButton:(UIButton *)button title:(NSString *)title backgroundImage:(UIImage *)image;
 - (void)showShop:(NSNotification *)note;

@end
