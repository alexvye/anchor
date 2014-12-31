//
//  Project.h
//  XFloss
//
//  Created by Alex Vye on 10-10-30.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#define kName @"Name"
#define kDescription @"Description"
#define kFloss @"Floss"

#import <Foundation/Foundation.h>


@interface Project : NSObject {
	NSString *name;
	NSString *description;
	NSMutableArray *floss;
}

-(void)encodeWithCoder:(NSCoder *)encoder;
-(id)initWithCoder:(NSCoder *)decoder;
-(NSComparisonResult)compare:(NSString *)aString;

-(NSMutableArray*) getFloss;
-(Project*) initWithName:(NSString*)_name :(NSString*)_patternFileName;

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *description;
@property (nonatomic, retain) NSMutableArray *floss;

@end
