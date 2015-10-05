//
//  NSMutableAttributedString+FromHtml.h
//  Daily Dozen
//
//  Created by Chan Kruse on 2015-10-05.
//  Copyright © 2015 NutritionFacts.org. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSMutableAttributedString (FromHtml)

+ (NSMutableAttributedString *)fromHtml:(NSString *)htmlString fontSize:(CGFloat)fontSize;

@end
