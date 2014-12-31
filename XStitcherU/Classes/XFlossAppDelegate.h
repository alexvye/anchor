//
//  XFlossAppDelegate.h
//  XFloss
//
//  Created by Alex Vye on 10-08-05.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataManager.h"
#import <CoreData/CoreData.h>
#import "MMDrawerController.h"
#import "System.h"
#import "FlossBrandViewController.h"

@interface XFlossAppDelegate : NSObject <UIApplicationDelegate>  {
    UIWindow *window;
	IBOutlet UITabBarController *tabBarController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (strong, nonatomic) UINavigationController *centerNavController;
@property (strong, nonatomic) MMDrawerController* drawerController;
@property (strong, nonatomic) System* localSystem;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
@end

