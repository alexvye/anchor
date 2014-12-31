//
//  ProjectFlossDB.h
//  XStitcherU
//
//  Created by Alex Vye on 2014-08-27.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ProjectDB;

@interface ProjectFlossDB : NSManagedObject

@property (nonatomic, retain) NSString * brand;
@property (nonatomic, retain) NSString * detailedLabel;
@property (nonatomic, retain) NSString * fileName;
@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSString * primaryLabel;
@property (nonatomic, retain) NSString * project;
@property (nonatomic, retain) NSNumber * quantity;
@property (nonatomic, retain) ProjectDB *projectRel;

@end
