//
//  CustomSalesCell.m
//  XStitcherU
//
//  Created by Alex Vye on 2014-03-25.
//
//

#import "CustomSalesCell.h"

@implementation CustomSalesCell

@synthesize brandImage, primaryLabel, purchaseButton;

float primaryFont;
float secondaryFont;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        primaryFont = 12.0;
        secondaryFont = 10.0;
    } else {
        primaryFont = 24.0;
        secondaryFont = 20.0;
    }
    
    
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        // Initialization code
		
		//
		// labels
		//
		primaryLabel = [[UILabel alloc]init];
		primaryLabel.font = [UIFont fontWithName:@"Helvetica" size:primaryFont];
		
		//
		// images
		//
		self.brandImage = [[UIImageView alloc]init];
		
		//
		// buttons
		//
        self.purchaseButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [self.purchaseButton setImage:[UIImage imageNamed:@"shopping.png"] forState:UIControlStateNormal];
        [self.purchaseButton addTarget:self
                               action:@selector(buy:)
                     forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.purchaseButton];
        
		//
		// fields everyoone gets
		//
	    [self.contentView addSubview:primaryLabel];
		[self.contentView addSubview:self.brandImage];
		
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

-(IBAction) buy: (UIButton*) aButton {
}

- (void)layoutSubviews {
    [super layoutSubviews];
	CGRect contentRect = self.contentView.bounds;
	CGFloat boundsX = contentRect.origin.x;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        //
        // images
        //
        brandImage.frame = CGRectMake(boundsX+1.0,2.0,40.0,40.0);
        
        //
        // labels
        //
        primaryLabel.frame = CGRectMake(boundsX+44.0,0.0,38.0,20.0);
        
        //
        // buttons and textbox. Because project buttons and shopping buttons
        // don't always appear, need to dynamically set frames
        //
        CGRect frame1 = CGRectMake(boundsX+154.0,8.0,44.0,29.0);

        purchaseButton.frame = frame1;
        
    } else { //IPad
        //
        // images
        //
        brandImage.frame = CGRectMake(boundsX+10.0,5.0,150.0,56);
        
        //
        // labels
        //
        primaryLabel.frame = CGRectMake(boundsX+170,5.0,100.0,25.0);
        
        //
        // buttons and textbox. Because project buttons and shopping buttons
        // don't always appear, need to dynamically set frames
        //
        CGRect frame1 = CGRectMake(boundsX+420.0,10.0,60.0,46.0);

        purchaseButton.frame = frame1;
    }
	
    
}

-(void)drawBuyOption:(NSString*)brand {
/*
    if(anchor!=NULL) {
        [self.contentView addSubview:anchorButton];
    } else {
        [self.anchorButton removeFromSuperview];
    }
 */
}

- (void)dealloc {
}


@end

