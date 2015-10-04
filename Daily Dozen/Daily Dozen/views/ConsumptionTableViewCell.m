//
//  ConsumptionTableViewCell.m
//  Daily Dozen
//
//  Created by Chan Kruse on 2015-10-04.
//  Copyright © 2015 NutritionFacts.org. All rights reserved.
//

#import "ConsumptionTableViewCell.h"
#import "DBConsumption.h"
#import "FoodType.h"
#import "DimenConstants.h"

#define kImageWidth 30.f
#define kImageHeight 30.f

@interface ConsumptionTableViewCell()


@end

@implementation ConsumptionTableViewCell

- (id)initWithTableView:(UITableView *)tableView identifier:(NSString *)identifier {
	if ((self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier])) {
		
		self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		
		// handle separator margins
		self.preservesSuperviewLayoutMargins = false; //ignore the layout margins for tableview
		self.layoutMargins = UIEdgeInsetsMake(0, 2.f * kDimenCellLeftSpacer + kImageWidth, 0, 0);
		
		CGFloat xOffset = kDimenCellLeftSpacer;
		CGFloat yOffset = floorf((self.contentView.frame.size.height - kImageHeight)/2.f);
		
		self.iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(xOffset,
																		   yOffset,
																		   kImageWidth,
																		   kImageHeight)];
		self.iconImageView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
		[self.contentView addSubview:self.iconImageView];
		
		xOffset = 2.f * kDimenCellLeftSpacer + kImageWidth;
		CGFloat width = tableView.bounds.size.width - kDimenCellRightSpacer - xOffset;
		
		self.label = [[UILabel alloc] initWithFrame:CGRectMake(xOffset,
															   yOffset,
															   width,
															   kImageHeight)];
		self.label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		self.label.numberOfLines = 0;
		self.label.font = [ConsumptionTableViewCell labelFont];
		self.label.textColor = [UIColor blackColor];
		
		[self.contentView addSubview:self.label];
	}
	
	return self;
}

+ (UIFont *)labelFont {
	return [UIFont systemFontOfSize:18.f];
}

+ (CGFloat)calculateRequiredHeightForConsumption:(DBConsumption *)consumption forTableView:(UITableView *)tableView {
	
	CGFloat requiredHeight = 0.f;
	
	CGFloat textHeight = [[consumption.foodType name] boundingRectWithSize:CGSizeMake(tableView.frame.size.width, 1000000)
																   options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading
																attributes:@{NSFontAttributeName: [self labelFont]}
																   context:nil].size.height;
	
	requiredHeight += MAX(kImageHeight, textHeight);
	
	requiredHeight += 2.f * kDimenRowVerticalSpacer;
	
	return requiredHeight;
}

@end
