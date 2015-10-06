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

- (id)initWithTableView:(UITableView *)tableView maxCheckmarkCount:(NSInteger)maxCheckmarkCount identifier:(NSString *)identifier {
	if ((self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier])) {
		
		self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		
		// handle separator margins
		self.preservesSuperviewLayoutMargins = false; //ignore the layout margins for tableview
		self.layoutMargins = UIEdgeInsetsMake(0, 2.f * kDimenCellLeftSpacer + kImageWidth, 0, 0);
		
		CGFloat xOffset = kDimenCellLeftSpacer;
		CGFloat yOffset = floorf((self.contentView.frame.size.height - kImageHeight)/2.f);
		CGFloat textYOffset = yOffset;
		
		self.iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(xOffset,
																		   yOffset,
																		   kImageWidth,
																		   kImageHeight)];
		self.iconImageView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
		[self.contentView addSubview:self.iconImageView];
		
		UIImage *checkMarkImage = [UIImage imageNamed:@"checkmark_unfilled.png"];
		
		if (maxCheckmarkCount >= 1) {
			self.checkMarkImageView1 = [[UIImageView alloc] initWithImage:checkMarkImage];
			self.checkMarkImageView1.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
			
			xOffset = self.contentView.bounds.size.width - checkMarkImage.size.width;
			yOffset = floorf((self.contentView.frame.size.height - checkMarkImage.size.height)/2.f);
			self.checkMarkImageView1.frame = CGRectMake(xOffset, yOffset, checkMarkImage.size.width, checkMarkImage.size.height);
			[self.contentView addSubview:self.checkMarkImageView1];
		}
		
		if (maxCheckmarkCount >= 2) {
			self.checkMarkImageView2 = [[UIImageView alloc] initWithImage:checkMarkImage];
			self.checkMarkImageView2.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
			
			xOffset = xOffset - kDimenCellRightSpacer/2.f - checkMarkImage.size.width;
			yOffset = floorf((self.contentView.frame.size.height - checkMarkImage.size.height)/2.f);
			self.checkMarkImageView2.frame = CGRectMake(xOffset, yOffset, checkMarkImage.size.width, checkMarkImage.size.height);
			[self.contentView addSubview:self.checkMarkImageView2];
		}
		
		if (maxCheckmarkCount >= 3) {
			self.checkMarkImageView3 = [[UIImageView alloc] initWithImage:checkMarkImage];
			self.checkMarkImageView3.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
			
			xOffset = xOffset - kDimenCellRightSpacer/2.f - checkMarkImage.size.width;
			yOffset = floorf((self.contentView.frame.size.height - checkMarkImage.size.height)/2.f);
			self.checkMarkImageView3.frame = CGRectMake(xOffset, yOffset, checkMarkImage.size.width, checkMarkImage.size.height);
			[self.contentView addSubview:self.checkMarkImageView3];
		}
		
		if (maxCheckmarkCount >= 4) {
			self.checkMarkImageView4 = [[UIImageView alloc] initWithImage:checkMarkImage];
			self.checkMarkImageView4.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
			
			xOffset = xOffset - kDimenCellRightSpacer/2.f - checkMarkImage.size.width;
			yOffset = floorf((self.contentView.frame.size.height - checkMarkImage.size.height)/2.f);
			self.checkMarkImageView4.frame = CGRectMake(xOffset, yOffset, checkMarkImage.size.width, checkMarkImage.size.height);
			[self.contentView addSubview:self.checkMarkImageView4];
		}
		
		if (maxCheckmarkCount == 5) {
			self.checkMarkImageView5 = [[UIImageView alloc] initWithImage:checkMarkImage];
			self.checkMarkImageView5.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
			
			xOffset = xOffset - kDimenCellRightSpacer/2.f - checkMarkImage.size.width;
			yOffset = floorf((self.contentView.frame.size.height - checkMarkImage.size.height)/2.f);
			self.checkMarkImageView5.frame = CGRectMake(xOffset, yOffset, checkMarkImage.size.width, checkMarkImage.size.height);
			[self.contentView addSubview:self.checkMarkImageView5];
		}
		
		xOffset = 2.f * kDimenCellLeftSpacer + kImageWidth;
		CGFloat width = tableView.bounds.size.width - kDimenCellRightSpacer - xOffset;
		
		self.label = [[UILabel alloc] initWithFrame:CGRectMake(xOffset,
															   textYOffset,
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
	return [UIFont systemFontOfSize:17.f];
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
