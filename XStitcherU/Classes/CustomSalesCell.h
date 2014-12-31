//
//  CustomSalesCell.h
//  XStitcherU
//
//  Created by Alex Vye on 2014-03-25.
//
//

#import <Foundation/Foundation.h>

@interface CustomSalesCell : UITableViewCell {
}

@property (nonatomic,retain)IBOutlet UIImageView *brandImage;
@property (nonatomic,retain)IBOutlet UIButton *purchaseButton;
@property (nonatomic,retain)IBOutlet UILabel  *primaryLabel;


-(void)drawBuyOption:(NSString*)brand;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;



@end
