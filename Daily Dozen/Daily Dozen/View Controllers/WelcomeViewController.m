//
//  WelcomeViewController.m
//  Daily Dozen
//
//  Created by Chan Kruse on 2015-10-06.
//  Copyright © 2015 NutritionFacts.org. All rights reserved.
//

#import "WelcomeViewController.h"
#import "UIImage+Scaled.h"
#import "NSMutableAttributedString+FromHtml.h"

@interface WelcomeViewController()

@property (nonatomic, strong) UIScrollView *scrollView;

@end

@implementation WelcomeViewController

- (void)loadView {
	
	CGRect screenRect = [[UIScreen mainScreen] bounds];
	
	UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, screenRect.size.width, screenRect.size.height)];
	view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	view.backgroundColor = [UIColor whiteColor];
	self.view = view;
	
	DLog(@"initial frame %@", NSStringFromCGRect(self.view.frame));
	
	CGFloat buttonHeight = 60.f;
	
	UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.f, 0.f, self.view.frame.size.width, self.view.frame.size.height - buttonHeight)];
	scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	scrollView.backgroundColor = [UIColor whiteColor];
	scrollView.alwaysBounceVertical = YES;
	[self.view addSubview:scrollView];
	self.scrollView = scrollView;
	
	UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[button setTitle:@"Get Started" forState:UIControlStateNormal];
	button.titleLabel.font = [UIFont systemFontOfSize:24.f];
	button.frame = CGRectMake(0.f, self.view.frame.size.height - buttonHeight, self.scrollView.frame.size.width, buttonHeight);
	button.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
	[self.view addSubview:button];
	[button addTarget:self action:@selector(getStarted) forControlEvents:UIControlEventTouchUpInside];
	
	CGFloat verticalSpacer = 20.f;
	CGFloat yOffset = [UIApplication sharedApplication].statusBarFrame.size.height + verticalSpacer;
	CGFloat horizontalIndent = 20.f;
	CGFloat textWidth = scrollView.frame.size.width - 2.f*horizontalIndent;
	
	CGFloat greyViewHeight;
	
	UIView *greyView = [[UIView alloc] init];
	greyView.backgroundColor = [UIColor colorWithWhite:0.93f alpha:1.f];
	[self.scrollView addSubview:greyView];
	
	UIImage *image = [UIImage imageNamed:@"nutrition_facts_logo.png"];
	image = [image imageScaledToWidth:scrollView.frame.size.width - 50.f];
	
	UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
	imageView.frame = CGRectMake(floorf((scrollView.frame.size.width - image.size.width)/2.f), yOffset, image.size.width, image.size.height);
	[self.scrollView addSubview:imageView];
	
	yOffset += imageView.frame.origin.y + imageView.frame.size.height;
//	yOffset += verticalSpacer;
	
	image = [UIImage imageNamed:@"dr_greger.png"];
	image = [image imageScaledToWidth:floorf(screenRect.size.width/2.f)];
	
	imageView = [[UIImageView alloc] initWithImage:image];
	imageView.frame = CGRectMake(floorf((scrollView.frame.size.width - image.size.width)/2.f), yOffset, image.size.width, image.size.height);
	[self.scrollView addSubview:imageView];
	
	yOffset += imageView.frame.size.height;
	greyViewHeight = yOffset;
	
	greyView.frame = CGRectMake(0.f, 0.f, self.scrollView.frame.size.width, greyViewHeight);
	
	yOffset += 20.f;
	
	CGFloat fontSize = 16.f;
	
	NSString *text = @"<b>Welcome to my Daily Dozen!</b>";
	
	NSAttributedString *attributedText = [NSMutableAttributedString fromHtml:text fontSize:fontSize];
	
	CGFloat requiredHeight = [attributedText boundingRectWithSize:CGSizeMake(textWidth, 1000000)
														  options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading
														  context:nil].size.height;
	
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(horizontalIndent, yOffset, textWidth, requiredHeight)];
	label.attributedText = attributedText;
	[self.scrollView addSubview:label];
	
	yOffset += requiredHeight + verticalSpacer;
	
	text = @"Use this app on a daily basis to keep track of the foods I recommend for optimal health and longevity in my book How Not to Die.<br /><br />To add a serving throughout the day, or to learn about each category tap on the row. It’s that easy!";
	
	attributedText = [NSMutableAttributedString fromHtml:text fontSize:fontSize];
	
	requiredHeight = [attributedText boundingRectWithSize:CGSizeMake(textWidth, 1000000)
														  options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading
														  context:nil].size.height;
	
	label = [[UILabel alloc] initWithFrame:CGRectMake(horizontalIndent, yOffset, textWidth, requiredHeight)];
	label.attributedText = attributedText;
	label.numberOfLines = 0;
	[self.scrollView addSubview:label];
	
	yOffset += requiredHeight + verticalSpacer;
	
}

- (void)viewDidLayoutSubviews {
	[super viewDidLayoutSubviews];
	
	CGRect contentRect = CGRectZero;
	for (UIView *view in self.scrollView.subviews) {
		contentRect = CGRectUnion(contentRect, view.frame);
	}
	
	self.scrollView.contentSize = contentRect.size;
	
	DLog(@"scrollview contentsize %@", NSStringFromCGSize(self.scrollView.contentSize));
}

- (void)getStarted {
	[self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
}

@end
