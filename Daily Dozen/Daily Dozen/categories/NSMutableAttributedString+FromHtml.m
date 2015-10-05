//
//  NSMutableAttributedString+FromHtml.m
//  Daily Dozen
//
//  Created by Chan Kruse on 2015-10-05.
//  Copyright © 2015 NutritionFacts.org. All rights reserved.
//

#import "NSMutableAttributedString+FromHtml.h"

@implementation NSMutableAttributedString (FromHtml)

+ (NSMutableAttributedString *)fromHtml:(NSString *)htmlString fontSize:(CGFloat)fontSize {
	
	NSMutableAttributedString *recommendationText = [[NSMutableAttributedString alloc] initWithData:[htmlString dataUsingEncoding:NSUTF8StringEncoding]
																							options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
																									  NSCharacterEncodingDocumentAttribute: @(NSUTF8StringEncoding)}
																				 documentAttributes:nil
																							  error:nil];
	
	NSRange range = (NSRange){0,[recommendationText length]};
	[recommendationText enumerateAttribute:NSFontAttributeName inRange:range options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired usingBlock:^(id value, NSRange range, BOOL *stop) {
		UIFont *currentFont = value;
		UIFont *replacementFont = nil;
		
		if ([currentFont.fontName rangeOfString:@"bold" options:NSCaseInsensitiveSearch].location != NSNotFound) {
			replacementFont = [UIFont fontWithName:@"HelveticaNeue-Medium" size:fontSize];
		} else {
			replacementFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:fontSize];
		}
		
		[recommendationText addAttribute:NSFontAttributeName value:replacementFont range:range];
	}];
	
	return recommendationText;
}

@end
