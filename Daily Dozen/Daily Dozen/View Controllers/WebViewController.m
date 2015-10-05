//
//  WebViewController.m
//  Daily Dozen
//
//  Created by Chan Kruse on 2015-10-05.
//  Copyright © 2015 NutritionFacts.org. All rights reserved.
//

#import "WebViewController.h"

@interface WebViewController()

@property (nonatomic, strong) NSURL *url;

@end

@implementation WebViewController

- (id)initWithUrl:(NSURL *)url {
	if ((self = [super init])) {
		self.url = url;
	}
	
	return self;
}

- (void)loadView {
	UIView *view = [[UIView alloc] init];
	view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	self.view = view;
	
	UIWebView *webView = [[UIWebView alloc] init];
	webView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	[webView loadRequest:[NSURLRequest requestWithURL:self.url]];
	[self.view addSubview:webView];
}

@end
