//
//  Project.m
//  XFloss
//
//  Created by Alex Vye on 10-10-30.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Project.h"


@implementation Project

@synthesize name;
@synthesize description;
@synthesize floss;

-(Project*) initWithName: (NSString*)_name : (NSString*)_description {
	self.name = _name;
	self.description = _description;
	self.floss = [[NSMutableArray alloc] init];
	return self;
}

-(NSMutableArray*) getFloss {
	return floss;
}

- (BOOL)isEqual:(id)anObject {
    return [self.name isEqual:anObject];
}

- (NSUInteger)hash {
	return [self.name hash];
}

-(void)encodeWithCoder:(NSCoder *)encoder{
	[encoder encodeObject:self.name forKey:kName];
	[encoder encodeObject:self.description forKey:kDescription];
	[encoder encodeObject:self.floss forKey:kFloss];
}

-(id)initWithCoder:(NSCoder *)decoder{
	if(self = [super init]) {
		self.name = [decoder decodeObjectForKey:kName];
		self.description = [decoder decodeObjectForKey:kDescription];
		self.floss = [decoder decodeObjectForKey:kFloss];
	}
	return self;
}

-(NSComparisonResult)compare:(NSString *)aString {
	return [name compare:aString];
}

@end
