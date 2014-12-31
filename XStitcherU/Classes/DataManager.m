//
//  DataManager.m
//  XFloss
//
//  Created by Alex Vye on 10-08-05.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "DataManager.h"
#import <CoreData/CoreData.h>
#import "FlossDB.h"
#import "XFlossAppDelegate.h"
#import "System.h"
#import "BrandDB.h"

NSMutableArray *groups;
NSMutableArray *floss;
NSMutableArray *shoppingList;
NSMutableDictionary *flossQuantity;

NSPersistentStoreCoordinator* persistentStoreCoordinator;

@implementation DataManager

static DataManager* _instance = nil;

+(DataManager*)instance

{
    @synchronized (_instance)
    {
        if ( !_instance || _instance == NULL )
        {
            // allocate the shared instance, because it hasn't been done yet
            _instance = [[DataManager alloc] init];
        }
        
        return _instance;
    }
}

////////////////////////////////
// save and load routines
////////////////////////////////

+(void)loadData {
	
	BOOL data20Found = false;
	
	//
	// 2.0 data store
	//
	if([[NSFileManager defaultManager] fileExistsAtPath:[DataManager archivePathQuantity]]) {
		
		flossQuantity = [NSKeyedUnarchiver unarchiveObjectWithFile:[DataManager archivePathQuantity]];
	} 
	if(flossQuantity == nil ) {
		flossQuantity = [[NSMutableDictionary alloc] initWithCapacity:30];
	} else {
		data20Found = true;
	}
	
	if([[NSFileManager defaultManager] fileExistsAtPath:[DataManager archivePathShoppingList]]) {
		shoppingList = [NSKeyedUnarchiver unarchiveObjectWithFile:[DataManager archivePathShoppingList]];

	} 
	
	if(shoppingList == nil) {
		shoppingList = [[NSMutableArray alloc] init];
	}

	//
	// Initialize the projects
	// vye
    NSMutableArray* projects;
    
	if([[NSFileManager defaultManager] fileExistsAtPath:[DataManager archivePathProjects]]) {
		projects = [NSKeyedUnarchiver unarchiveObjectWithFile:[DataManager archivePathProjects]];
		
	} 
	
	if(projects == nil) {
		projects = [[NSMutableArray alloc] init];
	}
}

-(void)loadSpecialtyProducts {
    [self loadDataForBrand:@"anchor" :@"anchor" :@"anchor-cat"];
    [self loadDataForBrand:@"gast" :@"gast" :@"gast-cat"];
    [self loadDataForBrand:@"wdw" :@"wdw" :@"wdw-cat"];
}

-(void)loadDataForBrand :(NSString*)brandName :(NSString*)csvFilename :(NSString*)catFilename {
    
    XFlossAppDelegate *appDelegate = (XFlossAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSManagedObjectContext *context = appDelegate.managedObjectContext;
    NSError *error = nil;
    
    //
    // Load the threads
    //
    NSString *filePath = [[NSBundle bundleForClass:[self class]] pathForResource:csvFilename ofType:@"csv"];
    NSStringEncoding encoding = NSASCIIStringEncoding;
    
    if(filePath) {
        NSString *drugData = [NSString stringWithContentsOfFile:filePath encoding:encoding error:&error];
        NSScanner *scanner = [NSScanner scannerWithString:drugData];
        NSScanner *lineScanner;
        NSString *line;
        NSCharacterSet *commaSet = [NSCharacterSet characterSetWithCharactersInString:@","];
        
        //
        // The parsed data
        //
        NSString *brand;
        NSString *flossID;
        NSString *description;
        NSString *group;
        
        int i = 0;
        while(![scanner isAtEnd]) {
            //
            // get next line
            //
            [scanner scanUpToCharactersFromSet:[NSCharacterSet newlineCharacterSet] intoString:&line];
            lineScanner = [NSScanner scannerWithString:line];
            
            //
            // parse the line
            //
            [lineScanner scanUpToCharactersFromSet:commaSet  intoString:&brand];
            [lineScanner scanString:@"," intoString:NULL];
            [lineScanner scanUpToCharactersFromSet:commaSet  intoString:&flossID];
            [lineScanner scanString:@"," intoString:NULL];
            [lineScanner scanUpToCharactersFromSet:commaSet  intoString:&description];
            [lineScanner scanString:@"," intoString:NULL];
            [lineScanner scanUpToCharactersFromSet:[NSCharacterSet newlineCharacterSet]  intoString:&group];
            
            //
            // store the data into DB
            //
            FlossDB *floss = [NSEntityDescription
                              insertNewObjectForEntityForName:@"Floss" inManagedObjectContext:context];
            [floss setBrand:brand];
            [floss setPrimaryLabel:flossID];
            [floss setId:flossID];
            [floss setDetailedLabel:description];
            
            NSString *fileName = [self fileNameForBrand:brand:flossID];
            
            [floss setFileName:fileName];
            [floss setGroup:[NSNumber numberWithInt:[group intValue]]];
            [floss setQuantity:[NSNumber numberWithInt:0]];
            [floss setShoppingQuantity:[NSNumber numberWithInt:0]];
            [floss setSort:[self sortOrderForBrand:brandName :flossID]];
            
            if(![context save:&error]) {
                NSLog(@"Error - Could not save: %@",[error localizedDescription]);
            }
            
            //
            // Update count
            //
            i++;
        }
        NSLog(@"%d floss records loaded for brand %@",i, brandName);
    }
    
    //
    // Now load the categories
    //
    filePath = [[NSBundle bundleForClass:[self class]] pathForResource:catFilename ofType:@"csv"];
    
    if(filePath) {
        NSString *drugData = [NSString stringWithContentsOfFile:filePath encoding:encoding error:&error];
        NSScanner *scanner = [NSScanner scannerWithString:drugData];
        NSScanner *lineScanner;
        NSString *line;
        NSCharacterSet *commaSet = [NSCharacterSet characterSetWithCharactersInString:@","];
        
        //
        // The parsed data
        //
        NSString *brand;
        NSString *group;
        NSString* name;
        
        int i = 0;
        while(![scanner isAtEnd]) {
            //
            // get next line
            //
            [scanner scanUpToCharactersFromSet:[NSCharacterSet newlineCharacterSet] intoString:&line];
            lineScanner = [NSScanner scannerWithString:line];
            
            //
            // parse the line
            //
            [lineScanner scanUpToCharactersFromSet:commaSet  intoString:&brand];
            [lineScanner scanString:@"," intoString:NULL];
            [lineScanner scanUpToCharactersFromSet:commaSet  intoString:&group];
            [lineScanner scanString:@"," intoString:NULL];
            [lineScanner scanUpToCharactersFromSet:[NSCharacterSet newlineCharacterSet]  intoString:&name];
            
            //
            // store the data into DB
            //
            BrandDB *branddb = [NSEntityDescription
                                insertNewObjectForEntityForName:@"Brand" inManagedObjectContext:context];
            [branddb setBrand:brand];
            [branddb setName:name];
            [branddb setGroup:[NSNumber numberWithInt:[group intValue]]];
            
            if(![context save:&error]) {
                NSLog(@"Error - Could not save: %@",[error localizedDescription]);
            }
            
            //
            // Update count
            //
            i++;
            
        }
        NSLog(@"%d category records loaded for brand %@",i, brandName);
    }
}

-(NSString*)fileNameForBrand:(NSString*) brand : (NSString*)flossID {
    
    NSString* fileName = @"filename";
    
    if([brand isEqual:@"anchor"]) {
        fileName = [NSString stringWithFormat:@"%@.png",flossID];
    } else if([brand isEqual:@"gast"]) {
        fileName = [NSString stringWithFormat:@"%@.jpg",flossID];
    } else if ([brand isEqual:@"wdw"]) {
        fileName = [NSString stringWithFormat:@"%@.png",flossID];
    }
    
    return fileName;
}

//
// the floss ids either are a straight number (dmc), or a number with a brand letter prepending, i.e. g12345 for gast,
// a12345 for anchor, w12345 for wdw
//
-(NSNumber*)sortOrderForBrand :(NSString*) brand :(NSString*) flossID {
    NSNumber* sortOrder = [NSNumber numberWithInt:0];
    char firstChar = [flossID characterAtIndex:0];
    if(firstChar == 'a' || firstChar == 'w' || firstChar == 'g') {
        sortOrder = [NSNumber numberWithInt:[flossID substringFromIndex:1].intValue];
    } else {
        sortOrder = [NSNumber numberWithInt:flossID.intValue];
    }
    
    return sortOrder;
}

+(NSString *)archivePathShoppingList {
	NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) objectAtIndex:0];
	return [docDir stringByAppendingPathComponent:@"shop.txt"];
}

+(NSString *)archivePathProjects {
	NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) objectAtIndex:0];
	return [docDir stringByAppendingPathComponent:@"projects.txt"];
}

+(NSString *)archivePathQuantity {
	NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) objectAtIndex:0];
	return [docDir stringByAppendingPathComponent:@"quantityFinal.txt"];
}


////////////////////////////////
// cell routines
////////////////////////////////

-(void)saveShopping:(id)floss {
    //
    // increment
    //
    FlossDB* saveFloss = (FlossDB*)floss;
    saveFloss.shoppingQuantity = [NSNumber numberWithInt:saveFloss.shoppingQuantity.intValue+1];
    
    //
    // Save
    //
    XFlossAppDelegate *appDelegate = (XFlossAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSError *error;
    if(![appDelegate.managedObjectContext save:&error]) {
        NSLog(@"Error %@", [error localizedDescription]);
    }
}

-(void)saveQuantity:(id)floss {
    //
    // Save
    //
    XFlossAppDelegate *appDelegate = (XFlossAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSError *error;
    if(![appDelegate.managedObjectContext save:&error]) {
        NSLog(@"Error %@", [error localizedDescription]);
    }
}

- (BOOL) anyProjects {
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    XFlossAppDelegate *appDelegate = (XFlossAppDelegate *)[[UIApplication sharedApplication] delegate];
    [request setEntity: [NSEntityDescription entityForName: @"Project" inManagedObjectContext: appDelegate.managedObjectContext]];
    
    NSError *error = nil;
    NSUInteger count = [appDelegate.managedObjectContext countForFetchRequest: request error: &error];
    
    if(count == 0) {
        return FALSE;
    } else {
        return TRUE;
    }
}

-(NSArray*)loadProjects {
    XFlossAppDelegate *appDelegate = (XFlossAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *moc = appDelegate.managedObjectContext;
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:@"Project" inManagedObjectContext:moc];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
                                        initWithKey:@"name" ascending:YES];
    [request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    NSError *error = nil;
    NSArray* projects = [moc executeFetchRequest:request error:&error];
    
    return projects;
}

//
// clean up memory
//
- (void)dealloc {
}
			  
@end
