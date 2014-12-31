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

@synthesize anchorDMC;

+(DataManager*)instance

{
    @synchronized (_instance)
    {
        if ( !_instance || _instance == NULL )
        {
            // allocate the shared instance, because it hasn't been done yet
            _instance = [[DataManager alloc] init];
            [_instance loadAnchor];
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
// Anchor
//
-(void)loadAnchor {
    if(self.anchorDMC == nil) {
        self.anchorDMC = [[NSDictionary alloc] initWithObjectsAndKeys:
                     @"white",@"2",
                     @"ecru",@"387",
                     @"208",@"110",
                     @"209",@"109",
                     @"210",@"108",
                     @"211",@"342",
                     @"221",@"897",
                     @"223",@"895",
                     @"224",@"893",
                     @"225",@"1026",
                     @"300",@"352",
                     @"301",@"1049",
                     @"304",@"1006",
                     @"307",@"289",
                     @"309",@"42",
                     @"black",@"403",
                     @"311",@"148",
                     @"312",@"979",
                     @"315",@"1019",
                     @"316",@"1017",
                     @"317",@"400",
                     @"318",@"399",
                     @"319",@"218",
                     @"320",@"215",
                     @"321",@"9046",
                     @"322",@"978",
                     @"326",@"59",
                     @"327",@"100",
                     @"333",@"119",
                     @"334",@"977",
                     @"335",@"38",
                     @"336",@"150",
                     @"340",@"118",
                     @"341",@"117",
                     @"347",@"1025",
                     @"349",@"13",
                     @"350",@"11",
                     @"351",@"10",
                     @"352",@"9",
                     @"353",@"6",
                     @"355",@"1014",
                     @"356",@"5975",
                     @"367",@"217",
                     @"368",@"214",
                     @"369",@"1043",
                     @"370",@"855",
                     @"371",@"854",
                     @"372",@"853",
                     @"400",@"351",
                     @"402",@"1047",
                     @"407",@"914",
                     @"413",@"236",
                     @"414",@"235",
                     @"415",@"398",
                     @"420",@"374",
                     @"422",@"943",
                     @"433",@"358",
                     @"434",@"310",
                     @"435",@"1046",
                     @"436",@"1045",
                     @"437",@"362",
                     @"444",@"290",
                     @"445",@"288",
                     @"451",@"233",
                     @"452",@"232",
                     @"453",@"231",
                     @"469",@"267",
                     @"470",@"267",
                     @"471",@"266",
                     @"472",@"253",
                     @"498",@"1005",
                     @"500",@"683",
                     @"501",@"878",
                     @"502",@"877",
                     @"503",@"876",
                     @"504",@"1042",
                     @"517",@"162",
                     @"518",@"1039",
                     @"519",@"1038",
                     @"520",@"862",
                     @"522",@"860",
                     @"523",@"859",
                     @"524",@"858",
                     @"535",@"401",
                     @"543",@"933",
                     @"550",@"102",
                     @"552",@"99",
                     @"553",@"98",
                     @"554",@"96",
                     @"561",@"212",
                     @"562",@"210",
                     @"563",@"208",
                     @"564",@"206",
                     @"580",@"281",
                     @"581",@"280",
                     @"597",@"1064",
                     @"598",@"1062",
                     @"600",@"59",
                     @"601",@"57",
                     @"602",@"63",
                     @"603",@"62",
                     @"604",@"55",
                     @"605",@"1094",
                     @"606",@"334",
                     @"608",@"332",
                     @"610",@"889",
                     @"611",@"898",
                     @"612",@"832",
                     @"613",@"831",
                     @"632",@"936",
                     @"640",@"903",
                     @"642",@"392",
                     @"644",@"830",
                     @"645",@"273",
                     @"646",@"8581",
                     @"647",@"1040",
                     @"648",@"900",
                     @"666",@"46",
                     @"676",@"891",
                     @"677",@"886",
                     @"680",@"901",
                     @"699",@"923",
                     @"700",@"228",
                     @"701",@"227",
                     @"702",@"226",
                     @"703",@"238",
                     @"704",@"256",
                     @"712",@"926",
                     @"718",@"88",
                     @"720",@"326",
                     @"721",@"925",
                     @"722",@"323",
                     @"725",@"305",
                     @"726",@"295",
                     @"727",@"293",
                     @"729",@"890",
                     @"730",@"845",
                     @"731",@"924",
                     @"732",@"281",
                     @"733",@"280",
                     @"734",@"279",
                     @"738",@"361",
                     @"739",@"387",
                     @"740",@"316",
                     @"741",@"304",
                     @"742",@"303",
                     @"743",@"302",
                     @"744",@"301",
                     @"745",@"300",
                     @"746",@"275",
                     @"747",@"158",
                     @"754",@"1012",
                     @"758",@"868",
                     @"760",@"1022",
                     @"761",@"1021",
                     @"762",@"234",
                     @"772",@"259",
                     @"775",@"128",
                     @"776",@"24",
                     @"778",@"968",
                     @"780",@"309",
                     @"781",@"308",
                     @"782",@"307",
                     @"783",@"306",
                     @"791",@"178",
                     @"792",@"941",
                     @"793",@"176",
                     @"794",@"175",
                     @"796",@"133",
                     @"797",@"132",
                     @"798",@"131",
                     @"799",@"136",
                     @"800",@"144",
                     @"801",@"359",
                     @"806",@"169",
                     @"807",@"168",
                     @"809",@"130",
                     @"813",@"161",
                     @"814",@"45",
                     @"815",@"43",
                     @"816",@"1005",
                     @"817",@"13",
                     @"818",@"23",
                     @"819",@"271",
                     @"820",@"134",
                     @"822",@"390",
                     @"823",@"152",
                     @"824",@"164",
                     @"825",@"162",
                     @"826",@"161",
                     @"827",@"160",
                     @"828",@"9159",
                     @"829",@"906",
                     @"830",@"277",
                     @"831",@"277",
                     @"832",@"907",
                     @"833",@"907",
                     @"834",@"874",
                     @"838",@"1088",
                     @"839",@"1086",
                     @"840",@"1084",
                     @"841",@"1082",
                     @"842",@"1080",
                     @"844",@"1041",
                     @"869",@"944",
                     @"890",@"218",
                     @"891",@"35",
                     @"892",@"33",
                     @"893",@"28",
                     @"894",@"27",
                     @"895",@"1044",
                     @"898",@"360",
                     @"899",@"52",
                     @"900",@"333",
                     @"902",@"897",
                     @"904",@"258",
                     @"905",@"257",
                     @"906",@"256",
                     @"907",@"255",
                     @"909",@"923",
                     @"910",@"229",
                     @"911",@"205",
                     @"912",@"209",
                     @"913",@"204",
                     @"915",@"1029",
                     @"917",@"89",
                     @"918",@"341",
                     @"919",@"340",
                     @"920",@"1004",
                     @"921",@"1003",
                     @"922",@"1003",
                     @"924",@"851",
                     @"926",@"850",
                     @"927",@"848",
                     @"928",@"274",
                     @"930",@"1035",
                     @"931",@"1034",
                     @"932",@"1033",
                     @"934",@"862",
                     @"935",@"861",
                     @"936",@"269",
                     @"937",@"268",
                     @"938",@"381",
                     @"939",@"152",
                     @"943",@"188",
                     @"945",@"881",
                     @"946",@"332",
                     @"947",@"330",
                     @"948",@"1011",
                     @"950",@"4146",
                     @"951",@"1010",
                     @"954",@"203",
                     @"955",@"206",
                     @"956",@"40",
                     @"957",@"50",
                     @"958",@"187",
                     @"959",@"186",
                     @"961",@"76",
                     @"962",@"75",
                     @"963",@"73",
                     @"964",@"185",
                     @"966",@"206",
                     @"970",@"316",
                     @"971",@"316",
                     @"972",@"298",
                     @"973",@"297",
                     @"975",@"355",
                     @"976",@"1001",
                     @"977",@"1002",
                     @"986",@"246",
                     @"987",@"244",
                     @"988",@"243",
                     @"989",@"242",
                     @"991",@"1076",
                     @"992",@"1072",
                     @"993",@"1070",
                     @"995",@"410",
                     @"996",@"433",
                     @"3011",@"846",
                     @"3012",@"844",
                     @"3013",@"842",
                     @"3021",@"905",
                     @"3022",@"8581",
                     @"3023",@"1040",
                     @"3024",@"397",
                     @"3031",@"905",
                     @"3032",@"903",
                     @"3033",@"391",
                     @"3041",@"871",
                     @"3042",@"870",
                     @"3045",@"888",
                     @"3046",@"887",
                     @"3047",@"852",
                     @"3051",@"681",
                     @"3052",@"262",
                     @"3053",@"261",
                     @"3064",@"883",
                     @"3072",@"847",
                     @"3078",@"292",
                     @"3325",@"129",
                     @"3326",@"36",
                     @"3328",@"1024",
                     @"3340",@"329",
                     @"3341",@"328",
                     @"3345",@"268",
                     @"3346",@"267",
                     @"3347",@"266",
                     @"3348",@"264",
                     @"3350",@"59",
                     @"3354",@"74",
                     @"3362",@"263",
                     @"3363",@"262",
                     @"3364",@"260",
                     @"3371",@"382",
                     @"3607",@"87",
                     @"3608",@"86",
                     @"3609",@"85",
                     @"3685",@"1028",
                     @"3687",@"68",
                     @"3688",@"66",
                     @"3689",@"49",
                     @"3705",@"35",
                     @"3706",@"33",
                     @"3708",@"31",
                     @"3712",@"1023",
                     @"3713",@"1020",
                     @"3716",@"25",
                     @"3721",@"896",
                     @"3722",@"1027",
                     @"3726",@"1018",
                     @"3727",@"1016",
                     @"3731",@"76",
                     @"3733",@"75",
                     @"3740",@"873",
                     @"3743",@"869",
                     @"3746",@"1030",
                     @"3747",@"120",
                     @"3750",@"1036",
                     @"3752",@"1032",
                     @"3753",@"1031",
                     @"3755",@"140",
                     @"3756",@"1037",
                     @"3760",@"169",
                     @"3761",@"928",
                     @"3765",@"170",
                     @"3766",@"167",
                     @"3768",@"779",
                     @"3770",@"1009",
                     @"3772",@"1007",
                     @"3773",@"1008",
                     @"3774",@"778",
                     @"3776",@"1048",
                     @"3777",@"1015",
                     @"3778",@"1013",
                     @"3779",@"1012",
                     @"3781",@"904",
                     @"3782",@"899",
                     @"3787",@"273",
                     @"3790",@"393",
                     @"3799",@"236",
                     @"3801",@"1098",
                     @"3802",@"1019",
                     @"3803",@"972",
                     @"3804",@"63",
                     @"3805",@"62",
                     @"3806",@"62",
                     @"3807",@"122",
                     @"3808",@"1068",
                     @"3809",@"1066",
                     @"3810",@"1066",
                     @"3811",@"1060",
                     @"3812",@"188",
                     @"3813",@"875",
                     @"3814",@"1074",
                     @"3815",@"877",
                     @"3816",@"876",
                     @"3817",@"875",
                     @"3818",@"923",
                     @"3819",@"278",
                     @"3820",@"306",
                     @"3821",@"305",
                     @"3822",@"295",
                     @"3823",@"386",
                     @"3824",@"8",
                     @"3825",@"323",
                     @"3826",@"1049",
                     @"3827",@"311",
                     @"3828",@"373",
                     @"3829",@"901",
                     @"3830",@"5975",
                     @"3831",@"29",
                     @"3832",@"28",
                     @"3833",@"26",
                     @"3834",@"100",
                     @"3835",@"98",
                     @"3836",@"90",
                     @"3837",@"100",
                     @"3838",@"177",
                     @"3839",@"176",
                     @"3840",@"117",
                     @"3841",@"9159",
                     @"3842",@"164",
                     @"3843",@"1089",
                     @"3844",@"410",
                     @"3845",@"1089",
                     @"3846",@"1090",
                     @"3847",@"1076",
                     @"3848",@"1074",
                     @"3849",@"1070",
                     @"3850",@"189",
                     @"3851",@"187",
                     @"3852",@"306",
                     @"3853",@"1003",
                     @"3854",@"313",
                     @"3855",@"311",
                     @"3856",@"1010",
                     @"3857",@"936",
                     @"3858",@"1007",
                     @"3859",@"914",
                     @"3860",@"379",
                     @"3861",@"378",
                     @"3862",@"358",
                     @"3863",@"379",
                     @"3864",@"376",
                     @"3865",@"2",
                     @"3866",@"926",
                     @"5200",@"1"
                     , nil];
    }
}
//
// clean up memory
//
- (void)dealloc {
}
			  
@end
