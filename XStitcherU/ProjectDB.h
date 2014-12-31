//
//  ProjectDB.h
//  XStitcherU
//
//  Created by Alex Vye on 2014-08-27.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ProjectFlossDB;

@interface ProjectDB : NSManagedObject

@property (nonatomic, retain) NSString * desc;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *projectFlossRel;
@end

@interface ProjectDB (CoreDataGeneratedAccessors)

- (void)addProjectFlossRelObject:(ProjectFlossDB *)value;
- (void)removeProjectFlossRelObject:(ProjectFlossDB *)value;
- (void)addProjectFlossRel:(NSSet *)values;
- (void)removeProjectFlossRel:(NSSet *)values;

@end
