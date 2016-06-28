//
//  MoreInfoViewController.m
//  Daily Dozen
//
//  Created by Chan Kruse on 2015-10-05.
//  Copyright © 2015 NutritionFacts.org. All rights reserved.
//

#import "MoreInfoViewController.h"
#import "WebViewController.h"

@interface MoreInfoViewController()

@property (nonatomic, strong) NSArray *rowTitles;
@property (nonatomic, strong) NSArray *rowUrls;

@end

@implementation MoreInfoViewController

- (void)backPressed {
	[self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
}

- (void)loadView {
	
	self.rowTitles = @[@"Latest Video", @"Donate", @"Book", @"Subscribe", @"Open Source", @"Acknowledgements"];
	self.rowUrls = @[@"http://nutritionfacts.org/", @"https://nutritionfacts.org/donate/", @"http://www.nutritionfacts.org/book", @"http://nutritionfacts.org/subscribe/", @"http://nutritionfacts.org/open-source/", @"Acknowledgements"];
	
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back"
																			  style:UIBarButtonItemStylePlain
																			 target:self
																			 action:@selector(backPressed)];
	UIView *view = [[UIView alloc] init];
	view.backgroundColor = [UIColor whiteColor];
	view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	self.view = view;
	
	UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
	tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	tableView.delegate = self;
	tableView.dataSource = self;
	[self.view addSubview:tableView];
	
	tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return self.rowTitles.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 60.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath  {
	
	NSString *cellID = @"default";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
	
	if(cell == nil) {
		cell = [self tableviewCellWithReuseIdentifier:cellID AtIndex:indexPath];
	}
	
	[self configureCell:cell forIndexPath:indexPath];
	
	return cell;
}

- (UITableViewCell *)tableviewCellWithReuseIdentifier:(NSString *)identifier AtIndex:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
	
	return cell;
}

- (void)configureCell:(UITableViewCell *)cell forIndexPath:(NSIndexPath *)indexPath {
	cell.textLabel.text = self.rowTitles[indexPath.row];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	if (indexPath.row < 5) {
		NSURL *url = [NSURL URLWithString:self.rowUrls[indexPath.row]];
		
		[[UIApplication sharedApplication] openURL:url];
	} else {
		
		UIAlertView *aiView = [[UIAlertView alloc] initWithTitle:@"Ackowledgements"
														 message:@"Designed by Allan Portera at DigitalBoro.com\n\nDeveloped by Chan Kruse\n\nPhotos by xxx"
														delegate:nil
											   cancelButtonTitle:@"Dismiss"
											   otherButtonTitles:nil];
		
		[aiView show];
	}
}

@end
