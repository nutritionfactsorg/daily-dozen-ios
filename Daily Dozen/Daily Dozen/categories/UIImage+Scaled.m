//
//  UIImage+Scaled.m
//  Daily Dozen
//
//  Created by Chan Kruse on 2015-10-04.
//  Copyright © 2015 NutritionFacts.org. All rights reserved.
//

#import "UIImage+Scaled.h"

@implementation UIImage (Scaled)

// src: http://stackoverflow.com/questions/7645454/resize-uiimage-by-keeping-aspect-ratio-and-width
- (UIImage *)imageScaledToWidth:(float)i_width {
	
	float oldWidth = self.size.width;
	float scaleFactor = i_width / oldWidth;
	
	float newHeight = self.size.height * scaleFactor;
	float newWidth = oldWidth * scaleFactor;
	
	UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight));
	[self drawInRect:CGRectMake(0, 0, newWidth, newHeight)];
	UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return newImage;
}

@end
