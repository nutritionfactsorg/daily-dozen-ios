//
//  FoodTypeDetailsViewController.m
//  Daily Dozen
//
//  Created by Chan Kruse on 2015-10-04.
//  Copyright © 2015 NutritionFacts.org. All rights reserved.
//

#import "FoodTypeDetailsViewController.h"
#import "DBConsumption.h"
#import "FoodType.h"
#import "UIImage+Scaled.h"

@interface FoodTypeDetailsViewController()

@property (nonatomic, strong) DBConsumption *consumption;
@property (nonatomic, strong) UIScrollView *scrollView;

@end

@implementation FoodTypeDetailsViewController

- (id)initWithDBConsumption:(DBConsumption *)consumption {
	if ((self = [super init])) {
		self.consumption = consumption;
		
		self.title = consumption.foodType.name;
	}
	
	return self;
}

- (void)loadView {
	
	FoodType *foodType = self.consumption.foodType;
	
	CGRect screenRect = [[UIScreen mainScreen] bounds];
	
	DLog(@"screenrect %@", NSStringFromCGRect(screenRect));
	UIView *view = [[UIView alloc] init];
	view.backgroundColor = [UIColor whiteColor];
	view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	self.view = view;
	
	UIScrollView *scrollView = [[UIScrollView alloc] init];
	scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	scrollView.backgroundColor = [UIColor whiteColor];
	[self.view addSubview:scrollView];
	self.scrollView = scrollView;
	
	UIImage *exampleImage = [UIImage imageNamed:foodType.overviewImageName];
	exampleImage = [exampleImage imageScaledToWidth:screenRect.size.width];
	
	UIImageView *imageView = [[UIImageView alloc] initWithImage:exampleImage];
	[scrollView addSubview:imageView];
	
	CGFloat horizontalIndent = 15.f;
	CGFloat verticalSpacer = 20.f;
	CGFloat yOffset = imageView.frame.size.height;
	CGFloat textWidth = screenRect.size.width - 2.f*horizontalIndent;
	
	CGRect viewFrame = self.view.frame;
	
	UIView *todaysServingContainer = [[UIView alloc] initWithFrame:CGRectMake(0.f, yOffset, viewFrame.size.width, 60.f)];
	todaysServingContainer.backgroundColor = [UIColor whiteColor];
	todaysServingContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	[scrollView addSubview:todaysServingContainer];
	
	yOffset += todaysServingContainer.frame.size.height;
	
	CGFloat fontSize = 18.f;
	
	if (foodType.recommendedServingCount > 0.f) {
		
		NSString *servingsString;
		
		if (foodType.recommendedServingCount > 1) {
			servingsString = @"servings";
		} else {
			servingsString = @"serving";
		}
		//<p style=\"color:#666666\">
		NSString *recommendationString = [NSString stringWithFormat:@"<b>Recommendation:</b> %i %@ a day", (int)foodType.recommendedServingCount, servingsString];
		
		NSMutableAttributedString *recommendationText = [[NSMutableAttributedString alloc] initWithData:[recommendationString dataUsingEncoding:NSUTF8StringEncoding]
																								options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
																										  NSCharacterEncodingDocumentAttribute: @(NSUTF8StringEncoding)}
																					 documentAttributes:nil
																								  error:nil];
		
		NSRange range = (NSRange){0,[recommendationText length]};
		[recommendationText enumerateAttribute:NSFontAttributeName inRange:range options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired usingBlock:^(id value, NSRange range, BOOL *stop) {
			UIFont *currentFont = value;
			UIFont *replacementFont = nil;
			
			if ([currentFont.fontName rangeOfString:@"bold" options:NSCaseInsensitiveSearch].location != NSNotFound) {
				replacementFont = [UIFont fontWithName:@"HelveticaNeue-Bold" size:fontSize];
			} else {
				replacementFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:fontSize];
			}
			
			[recommendationText addAttribute:NSFontAttributeName value:replacementFont range:range];
		}];
		
		CGFloat requiredHeight = [recommendationText boundingRectWithSize:CGSizeMake(textWidth, 1000000)
																  options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading
																  context:nil].size.height;
		UILabel *recommendationLabel = [[UILabel alloc] initWithFrame:CGRectMake(horizontalIndent, yOffset, textWidth, requiredHeight)];
		recommendationLabel.attributedText = recommendationText;
		recommendationLabel.numberOfLines = 0;
		[scrollView addSubview:recommendationLabel];
		
		yOffset += recommendationLabel.frame.size.height;
		
		yOffset += verticalSpacer;
	}
	
	
	if (foodType.servingExample) {
		
		NSString *recommendationString = [NSString stringWithFormat:@"<b>1 Serving:</b>\n%@", foodType.servingExample];
		
		NSMutableAttributedString *recommendationText = [[NSMutableAttributedString alloc] initWithData:[recommendationString dataUsingEncoding:NSUTF8StringEncoding]
																								options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
																										  NSCharacterEncodingDocumentAttribute: @(NSUTF8StringEncoding)}
																					 documentAttributes:nil
																								  error:nil];
		
		NSRange range = (NSRange){0,[recommendationText length]};
		[recommendationText enumerateAttribute:NSFontAttributeName inRange:range options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired usingBlock:^(id value, NSRange range, BOOL *stop) {
			UIFont *currentFont = value;
			UIFont *replacementFont = nil;
			
			if ([currentFont.fontName rangeOfString:@"bold" options:NSCaseInsensitiveSearch].location != NSNotFound) {
				replacementFont = [UIFont fontWithName:@"HelveticaNeue-Bold" size:fontSize];
			} else {
				replacementFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:fontSize];
			}
			
			[recommendationText addAttribute:NSFontAttributeName value:replacementFont range:range];
		}];
		
		CGFloat requiredHeight = [recommendationText boundingRectWithSize:CGSizeMake(textWidth, 1000000)
																  options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading
																  context:nil].size.height;
		UILabel *recommendationLabel = [[UILabel alloc] initWithFrame:CGRectMake(horizontalIndent, yOffset, textWidth, requiredHeight)];
		recommendationLabel.attributedText = recommendationText;
		recommendationLabel.numberOfLines = 0;
		recommendationLabel.textColor = [UIColor blackColor];
		[scrollView addSubview:recommendationLabel];
		
		yOffset += recommendationLabel.frame.size.height;
		
		yOffset += verticalSpacer;
	}
	
	for (int i=0; i<foodType.exampleTitles.count; i++) {
		
		NSString *exampleString = [NSString stringWithFormat:@"<b>%@</b> %@", foodType.exampleTitles[i], foodType.exampleBodies[i]];
		
		NSMutableAttributedString *exampleText = [[NSMutableAttributedString alloc] initWithData:[exampleString dataUsingEncoding:NSUTF8StringEncoding]
																								options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
																										  NSCharacterEncodingDocumentAttribute: @(NSUTF8StringEncoding)}
																					 documentAttributes:nil
																								  error:nil];
		
		NSRange range = (NSRange){0,[exampleText length]};
		[exampleText enumerateAttribute:NSFontAttributeName inRange:range options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired usingBlock:^(id value, NSRange range, BOOL *stop) {
			UIFont *currentFont = value;
			UIFont *replacementFont = nil;
			
			if ([currentFont.fontName rangeOfString:@"bold" options:NSCaseInsensitiveSearch].location != NSNotFound) {
				replacementFont = [UIFont fontWithName:@"HelveticaNeue-Bold" size:fontSize];
			} else {
				replacementFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:fontSize];
			}
			
			[exampleText addAttribute:NSFontAttributeName value:replacementFont range:range];
		}];
		
		CGFloat requiredHeight = [exampleText boundingRectWithSize:CGSizeMake(textWidth, 1000000)
																  options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading
																  context:nil].size.height;
		UILabel *recommendationLabel = [[UILabel alloc] initWithFrame:CGRectMake(horizontalIndent, yOffset, textWidth, requiredHeight)];
		recommendationLabel.attributedText = exampleText;
		recommendationLabel.numberOfLines = 0;
		recommendationLabel.textColor = [UIColor blackColor];
		[scrollView addSubview:recommendationLabel];
		
		yOffset += recommendationLabel.frame.size.height;
		
		yOffset += verticalSpacer;
		
	}
}

- (void)viewDidLayoutSubviews {
	[super viewDidLayoutSubviews];
	
	CGRect contentRect = CGRectZero;
	for (UIView *view in self.scrollView.subviews) {
		contentRect = CGRectUnion(contentRect, view.frame);
	}
	
	contentRect.size.height += 20.f;
	
	self.scrollView.contentSize = contentRect.size;
	
	DLog(@"scrollview contentsize %@", NSStringFromCGSize(self.scrollView.contentSize));
}

@end
