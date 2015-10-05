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
#import "NSMutableAttributedString+FromHtml.h"
#import "DataManager.h"

@interface FoodTypeDetailsViewController()

@property (nonatomic, strong) DBConsumption *consumption;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UILabel *servingsLabel;

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
	
	yOffset += verticalSpacer;
	
	CGRect viewFrame = self.view.frame;
	
	CGFloat todaysServingsContainerHeight = 60.f;
	
	UIView *todaysServingContainer = [[UIView alloc] initWithFrame:CGRectMake(0.f, yOffset, screenRect.size.width, todaysServingsContainerHeight)];
	[scrollView addSubview:todaysServingContainer];
	
	CGFloat buttonXoffset;
	CGFloat buttonYoffset;
	
	UIImage *buttonImage = [UIImage imageNamed:@"btn_plus.png"];
	UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
	[button setImage:buttonImage forState:UIControlStateNormal];
	[button addTarget:self action:@selector(increaseServingCount) forControlEvents:UIControlEventTouchUpInside];

	buttonXoffset = todaysServingContainer.bounds.size.width - horizontalIndent - buttonImage.size.width;
	buttonYoffset = ceilf((todaysServingsContainerHeight - buttonImage.size.height)/2.f);
	
	button.frame = CGRectMake(buttonXoffset, buttonYoffset, buttonImage.size.width, buttonImage.size.height);
	[todaysServingContainer addSubview:button];

	buttonXoffset -= 40.f;
	
	UILabel *servingCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(buttonXoffset, buttonYoffset, 40.f, buttonImage.size.height)];
	servingCountLabel.backgroundColor = [UIColor colorWithWhite:0.f alpha:0.05f];//[UIColor colorWithRed:237.f/255.f green:247.f/255.f blue:255.f/255.f alpha:1.f];
	servingCountLabel.font = [UIFont boldSystemFontOfSize:24.f];
	servingCountLabel.text = [NSString stringWithFormat:@"%i", (int)[self.consumption consumedServingCount].integerValue];
	servingCountLabel.textAlignment = NSTextAlignmentCenter;
	[todaysServingContainer addSubview:servingCountLabel];
	self.servingsLabel = servingCountLabel;
	
	buttonImage = [UIImage imageNamed:@"btn_minus.png"];
	button = [UIButton buttonWithType:UIButtonTypeCustom];
	[button setImage:buttonImage forState:UIControlStateNormal];
	[button addTarget:self action:@selector(decreaseServingCount) forControlEvents:UIControlEventTouchUpInside];
	
	buttonXoffset -= buttonImage.size.width;
	
	button.frame = CGRectMake(buttonXoffset, buttonYoffset, buttonImage.size.width, buttonImage.size.height);
	[todaysServingContainer addSubview:button];
	
	CGFloat fontSize = 18.f;
	
	UILabel *servingsTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(horizontalIndent, buttonYoffset, buttonXoffset - 2.f *horizontalIndent, buttonImage.size.height)];
	servingsTitleLabel.text = @"Today's Servings";
	servingsTitleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:fontSize];
	[todaysServingContainer addSubview:servingsTitleLabel];
	
	yOffset += todaysServingContainer.frame.size.height;
	
	yOffset += verticalSpacer;
	
	UIView *sepView = [[UIView alloc] initWithFrame:CGRectMake(1*horizontalIndent, yOffset, screenRect.size.width - 2*horizontalIndent, 1.f)];
	sepView.backgroundColor = [UIColor colorWithWhite:0.f alpha:0.05f];
	[scrollView addSubview:sepView];
	
	yOffset += verticalSpacer;
	
	
	if (foodType.recommendedServingCount > 0.f) {
		
		NSString *servingsString;
		
		if (foodType.recommendedServingCount > 1) {
			servingsString = @"servings";
		} else {
			servingsString = @"serving";
		}
		//<p style=\"color:#666666\">
		NSString *recommendationString = [NSString stringWithFormat:@"<b>Recommendation:</b> %i %@ a day", (int)foodType.recommendedServingCount, servingsString];
		
		NSMutableAttributedString *recommendationText = [NSMutableAttributedString fromHtml:recommendationString fontSize:fontSize];
		
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
		
		NSMutableAttributedString *recommendationText = [NSMutableAttributedString fromHtml:recommendationString fontSize:fontSize];
		
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
		
		NSMutableAttributedString *exampleText = [NSMutableAttributedString fromHtml:exampleString fontSize:fontSize];
		
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

- (void)increaseServingCount {
	double currentServing = self.consumption.consumedServingCount.doubleValue;
	
	[[DataManager getInstance] setServingCount:(currentServing + 1) forDBConsumption:self.consumption];
	
	self.servingsLabel.text = [NSString stringWithFormat:@"%i", (int)self.consumption.consumedServingCount.integerValue];
}

- (void)decreaseServingCount {
	double currentServing = self.consumption.consumedServingCount.doubleValue;
	
	if (currentServing > 0.0) {
		[[DataManager getInstance] setServingCount:(currentServing - 1) forDBConsumption:self.consumption];
		
		self.servingsLabel.text = [NSString stringWithFormat:@"%i", (int)self.consumption.consumedServingCount.integerValue];
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
