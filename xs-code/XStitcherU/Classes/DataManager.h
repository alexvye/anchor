//
//  DataManager.h
//  XFloss
//
//  Created by Alex Vye on 10-08-05.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

extern int group;

@interface DataManager : NSObject {
}

@property (strong, nonatomic) NSDictionary *anchorDMC;

+(NSString *)archivePathShoppingList;
+(NSString *)archivePathQuantity;
+(NSString *)archivePathProjects;
+(DataManager*)instance;
-(void)saveShopping:(id)floss;
-(void)saveQuantity:(id)floss;
-(BOOL)anyProjects;
-(NSArray*)loadProjects;
-(void)loadAnchor;
-(void)loadDataForBrand :(NSString*)brandName :(NSString*)csvFilename :(NSString*)catFilename;
-(void)loadSpecialtyProducts;
@end
