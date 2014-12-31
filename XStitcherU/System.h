//
//  System.h
//  XStitcherU
//
//  Created by Alex Vye on 2014-08-27.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface System : NSManagedObject

@property (nonatomic, retain) NSString * last_device;
@property (nonatomic, retain) NSDate * last_update;
@property (nonatomic, retain) NSNumber * updated;
@property (nonatomic, retain) NSNumber * version;

@end
