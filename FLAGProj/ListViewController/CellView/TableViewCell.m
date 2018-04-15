//
//  TableViewCell.m
//  FLAGProj
//
//  Created by formando on 08/03/2018.
//  Copyright © 2018 Pedro Brito. All rights reserved.
//

#import "TableViewCell.h"

@interface TableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;



@end


@implementation TableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setCellContent:(NSString*)title{
    
    [self.titleLabel setText: title];
    
 
}



@end
