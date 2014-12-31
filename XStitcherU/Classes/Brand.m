//
//  Brand.m
//  XStitcherU
//
//  Created by Alex Vye on 2/4/2014.
//
//

#import "Brand.h"

@implementation Brand

@synthesize isPaidFor, description, code;

-(Brand*) initWithCode: (NSString*)_code : (NSString*)_description : (BOOL) _paidFor {
	self.code = _code;
	self.description = _description;
	self.isPaidFor = _paidFor;
	return self;
}

@end
