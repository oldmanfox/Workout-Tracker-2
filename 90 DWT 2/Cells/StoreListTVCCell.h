//
//  StoreListTVCCell.h
//  90 DWT 1
//
//  Created by Grant, Jared on 5/13/13.
//  Copyright (c) 2013 Grant, Jared. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StoreListTVCCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UIButton *buyButton;

@end
