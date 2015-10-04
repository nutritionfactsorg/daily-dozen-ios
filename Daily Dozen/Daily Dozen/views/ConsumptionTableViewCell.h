//
//  ConsumptionTableViewCell.h
//  Daily Dozen
//
//  Created by Chan Kruse on 2015-10-04.
//  Copyright © 2015 NutritionFacts.org. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DBConsumption;

@interface ConsumptionTableViewCell : UITableViewCell

@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UIImageView *checkMarkImageView1;
@property (nonatomic, strong) UIImageView *checkMarkImageView2;
@property (nonatomic, strong) UIImageView *checkMarkImageView3;
@property (nonatomic, strong) UIImageView *checkMarkImageView4;
@property (nonatomic, strong) UIImageView *checkMarkImageView5;

- (id)initWithTableView:(UITableView *)tableView maxCheckmarkCount:(NSInteger)maxCheckmarkCount identifier:(NSString *)identifier;
+ (CGFloat)calculateRequiredHeightForConsumption:(DBConsumption *)consumption forTableView:(UITableView *)tableView;

@end
