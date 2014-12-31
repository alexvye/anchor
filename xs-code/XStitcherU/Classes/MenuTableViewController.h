//
//  MenuTableViewController.h
//  XStitcherU
//
//  Created by Alex Vye on 2013-10-14.
//
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, MMDrawerSection){
    MMDrawerSectionViewSelection,
    MMDrawerSectionDrawerWidth,
    MMDrawerSectionShadowToggle,
    MMDrawerSectionOpenDrawerGestures,
    MMDrawerSectionCloseDrawerGestures,
    MMDrawerSectionCenterHiddenInteraction,
    MMDrawerSectionStretchDrawer,
};

typedef NS_ENUM(NSInteger, XSMenuOption){
    XSBrand,
    XSInventory,
    XSShopping,
    XSMatcher,
    XSProject,
};

@interface MenuTableViewController : UIViewController <UITableViewDataSource,UITableViewDelegate> {
    
}

@property (nonatomic, strong) UITableView * tableView;
@property (nonatomic,strong) NSArray * drawerWidths;
@property (nonatomic, retain) NSMutableArray* menuOptions;

@end
