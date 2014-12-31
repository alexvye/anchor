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

+(DataManager*)instance;
-(void)saveShopping:(id)floss;
-(void)saveQuantity:(id)floss;
-(BOOL)anyProjects;
-(NSArray*)loadProjects;
-(void)loadDataForBrand :(NSString*)brandName :(NSString*)csvFilename :(NSString*)catFilename;
-(void)loadSpecialtyProducts;
@end
