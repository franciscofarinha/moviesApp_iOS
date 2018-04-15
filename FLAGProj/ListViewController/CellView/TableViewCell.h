//
//  TableViewCell.h
//  FLAGProj
//
//  Created by formando on 08/03/2018.
//  Copyright © 2018 Pedro Brito. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *cellImageView;


-(void)setCellContent:(NSString*)title;

@end
