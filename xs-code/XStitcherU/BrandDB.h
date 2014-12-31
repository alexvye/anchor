//
//  BrandDB.h
//  XStitcherU
//
//  Created by Alex Vye on 2014-08-27.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class FlossDB;

@interface BrandDB : NSManagedObject

@property (nonatomic, retain) NSString * brand;
@property (nonatomic, retain) NSNumber * group;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * order;
@property (nonatomic, retain) FlossDB *flossRel;

@end
