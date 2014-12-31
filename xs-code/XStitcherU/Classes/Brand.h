//
//  Brand.h
//  XStitcherU
//
//  Created by Alex Vye on 2/4/2014.
//
//

#import <Foundation/Foundation.h>

@interface Brand : NSObject {
    
}

@property (nonatomic, retain) NSString *description;
@property (nonatomic, retain) NSString *code;
@property (assign) BOOL isPaidFor;

-(Brand*) initWithCode: (NSString*)_code : (NSString*)_description : (BOOL) _paidFor;

@end
