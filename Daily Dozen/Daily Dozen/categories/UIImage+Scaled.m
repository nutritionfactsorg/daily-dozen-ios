//
//  UIImage+Scaled.m
//  Daily Dozen
//
//  Created by Chan Kruse on 2015-10-04.
//  Copyright © 2015 NutritionFacts.org. All rights reserved.
//

#import "UIImage+Scaled.h"

@implementation UIImage (Scaled)

- (UIImage *)imageScaledToWidth:(float)i_width {
	
	float oldWidth = self.size.width;
	float scaleFactor = i_width / oldWidth;
	
	float newHeight = self.size.height * scaleFactor;
	float newWidth = oldWidth * scaleFactor;
	
	UIGraphicsBeginImageContextWithOptions(CGSizeMake(newWidth, newHeight), NO, 0);
	[self drawInRect:CGRectMake(0, 0, newWidth, newHeight)];
	UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return newImage;
}

@end
