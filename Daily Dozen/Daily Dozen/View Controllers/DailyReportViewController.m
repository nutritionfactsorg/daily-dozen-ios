//
//  DailyReportViewController.m
//  Daily Dozen
//
//  Created by Chan Kruse on 2015-10-02.
//  Copyright © 2015 NutritionFacts.org. All rights reserved.
//

#import "DailyReportViewController.h"
#import "ColorConstants.h"
#import "DBDailyReport.h"
#import "DBConsumption.h"
#import "DataManager.h"
#import "DatabaseManager.h"
#import "ConsumptionTableViewCell.h"
#import "FoodType.h"
#import "FoodTypeDetailsViewController.h"
#import "MoreInfoViewController.h"
#import "DimenConstants.h"
#import "WelcomeViewController.h"

@interface DailyReportViewController ()

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) DBDailyReport *dailyReport;
@property (nonatomic, strong) NSMutableArray *rowHeights;
@property (nonatomic, strong) UIImage *checkedImage;
@property (nonatomic, strong) UIImage *uncheckedImage;
@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong) UILabel *progressLabel;
@property (nonatomic, strong) NSDate *currentDate;
@property (nonatomic, assign) BOOL showWelcomeScreen;

@end

@implementation DailyReportViewController

- (id)init {
	if ((self = [super init])) {
		self.title = @"Dr. Gregor's Daily Dozen";
		
		NSError *error = nil;
		
		self.showWelcomeScreen = [[DataManager getInstance] isFirstRun];

		[[DatabaseManager sharedInstance] loadStoreForUserID:@(0) error:&error];
		
		self.checkedImage = [UIImage imageNamed:@"checkmark_filled.png"];
		self.uncheckedImage = [UIImage imageNamed:@"checkmark_unfilled.png"];
	}
	
	return self;
}

- (void)settingsPressed {
	MoreInfoViewController *vController = [[MoreInfoViewController alloc] init];
	
	UINavigationController *nController = [[UINavigationController alloc] initWithRootViewController:vController];
	
	[self presentViewController:nController animated:YES completion:NULL];
}

- (void)loadView {
	
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic_settings.png"]
																			  style:UIBarButtonItemStylePlain
																			 target:self
																			 action:@selector(settingsPressed)];
	
	CGRect screenRect = [[UIScreen mainScreen] bounds];
	
	UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0.f, self.navigationController.navigationBar.frame.size.height, screenRect.size.width, screenRect.size.height - self.navigationController.navigationBar.frame.size.height - [UIApplication sharedApplication].statusBarFrame.size.height)];
	view.backgroundColor = [UIColor whiteColor];
	self.view = view;
	
	CGFloat verticalSpacer = 20.f;
	CGFloat progressContainerHeight = verticalSpacer;
	
	UIView *progressContainer = [[UIView alloc] init];
	progressContainer.backgroundColor = [UIColor colorWithWhite:0.93f alpha:1.f];
	
	UIFont *font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16.f];
	
	NSString *title = @"Daily Progress";
	
	CGRect rect = [title boundingRectWithSize:CGSizeMake(screenRect.size.width, 1000000)
									  options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading
								   attributes:@{NSFontAttributeName: font}
									  context:nil];
	
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(kDimenCellLeftSpacer, verticalSpacer, ceilf(rect.size.width), ceilf(rect.size.height))];
	label.font = font;
	label.text = title;
	
	progressContainerHeight += label.frame.size.height;
	
	[progressContainer addSubview:label];
	
	title = @"100 %";
	
	rect = [title boundingRectWithSize:CGSizeMake(screenRect.size.width, 1000000)
									  options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading
								   attributes:@{NSFontAttributeName: font}
									  context:nil];
	
	label = [[UILabel alloc] initWithFrame:CGRectMake(screenRect.size.width - kDimenCellRightSpacer - ceilf(rect.size.width), verticalSpacer, ceilf(rect.size.width), ceilf(rect.size.height))];
	label.font = font;
	label.text = @"100 %";
	label.textAlignment = NSTextAlignmentRight;
	label.numberOfLines = 0;
	
	[progressContainer addSubview:label];
	self.progressLabel = label;
	
	
	UIProgressView *progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
	progressView.frame = CGRectMake(kDimenCellLeftSpacer, label.frame.origin.y + label.frame.size.height + 5.f, screenRect.size.width - kDimenCellRightSpacer - kDimenCellLeftSpacer, progressView.frame.size.height);
	progressView.tintColor = kColorAccent;
	[progressContainer addSubview:progressView];
	self.progressView = progressView;
	
	progressContainerHeight += progressView.frame.size.height + 5.f;
	
	progressContainerHeight += verticalSpacer;
	
	DLog(@"container height %f", progressContainerHeight);
	progressContainer.frame = CGRectMake(0.f, 0.f, screenRect.size.width, progressContainerHeight);
	
	[self.view addSubview:progressContainer];
	
	UIView *sepView = [[UIView alloc] initWithFrame:CGRectMake(0.f, progressContainerHeight, screenRect.size.width, 1.f)];
	sepView.backgroundColor = [UIColor colorWithWhite:0.f alpha:0.2f];
	[self.view addSubview:sepView];
	
	UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.f,
																		   progressContainerHeight + 1.f,
																		   screenRect.size.width,
																		   self.view.frame.size.height - progressContainerHeight - 1.f)
														  style:UITableViewStylePlain];
	//tableView.autoresizingMask =UIViewAutoresizingFlexibleHeight;
	tableView.translatesAutoresizingMaskIntoConstraints = NO;
	tableView.delegate = self;
	tableView.dataSource = self;
	[self.view addSubview:tableView];
	self.tableView = tableView;
	
	self.tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
	
}

- (void)appForegrounded {
	if ([self isViewLoaded] && self.view.window) {
		
		NSDate *date = [[DataManager getInstance] getCurrentDate];
		
		if (!self.currentDate || [self.currentDate compare:date] != NSOrderedSame) {
			
			self.currentDate = date;
			self.dailyReport = [[DataManager getInstance] getReportForToday];
			
			self.rowHeights = [NSMutableArray array];
		}
	}
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	NSDate *date = [[DataManager getInstance] getCurrentDate];
	
	if (!self.currentDate || [self.currentDate compare:date] != NSOrderedSame) {
		
		self.currentDate = date;
		self.dailyReport = [[DataManager getInstance] getReportForToday];
		
		self.rowHeights = [NSMutableArray array];
	}
	
	if (!self.rowHeights.count) {
		for (DBConsumption *consumption in self.dailyReport.consumptions) {
			[self.rowHeights addObject:@([ConsumptionTableViewCell calculateRequiredHeightForConsumption:consumption
																							forTableView:self.tableView])];
		}
	}
	
	[self.tableView reloadData];
	
	[self updateProgress];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	if (self.showWelcomeScreen) {
		self.showWelcomeScreen = NO;
		
		WelcomeViewController *vController = [[WelcomeViewController alloc] init];
		[self presentViewController:vController animated:YES completion:NULL];
	}
}

- (void)updateProgress {
	double totalServings = 0.0;
	double consumedServings = 0.0;
	
	for (DBConsumption *consumption in self.dailyReport.consumptions) {
		
		if (consumption.foodType.recommendedServingCount >= 0.0) {
			totalServings += consumption.foodType.recommendedServingCount;
			consumedServings += MIN(consumption.consumedServingCount.doubleValue, consumption.foodType.recommendedServingCount);
		}
	}
	
	CGFloat percentProgress = consumedServings/totalServings;
	self.progressView.progress = percentProgress;
	
	self.progressLabel.text = [NSString stringWithFormat:@"%i %%", (int)roundf(percentProgress * 100.f)];
}
- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.navigationController.navigationBar.barTintColor = kColorNavBar;
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return self.dailyReport.consumptions.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return [self.rowHeights[indexPath.row] floatValue];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath  {
	
	DBConsumption *consumption = ((DBConsumption *)(self.dailyReport.consumptions[indexPath.row]));
	FoodType *foodType = consumption.foodType;
	
	NSString *cellID = [NSString stringWithFormat:@"maxServingCount%f", foodType.recommendedServingCount];
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
	
	if(cell == nil) {
		cell = [self tableviewCellWithReuseIdentifier:cellID AtIndex:indexPath];
	}
	
	[self configureCell:cell forIndexPath:indexPath];
	
	return cell;
}

- (UITableViewCell *)tableviewCellWithReuseIdentifier:(NSString *)identifier AtIndex:(NSIndexPath *)indexPath {
	
	DBConsumption *consumption = ((DBConsumption *)(self.dailyReport.consumptions[indexPath.row]));
	FoodType *foodType = consumption.foodType;
	
	UITableViewCell *cell = [[ConsumptionTableViewCell alloc] initWithTableView:self.tableView
															  maxCheckmarkCount:ceilf(foodType.recommendedServingCount)
																	 identifier:identifier];
	
	return cell;
}

- (void)configureCell:(UITableViewCell *)cell forIndexPath:(NSIndexPath *)indexPath {
	
	ConsumptionTableViewCell *consumptionCell = (ConsumptionTableViewCell *)cell;
	
	DBConsumption *consumption = ((DBConsumption *)(self.dailyReport.consumptions[indexPath.row]));
	FoodType *foodType = consumption.foodType;
	
	consumptionCell.iconImageView.image = foodType.iconImageName;
	consumptionCell.label.text = foodType.name;
	
	int consumedCount = (int)consumption.consumedServingCount.integerValue;
	
	if (consumptionCell.checkMarkImageView1) {
		if (consumedCount >= 1) {
			consumptionCell.checkMarkImageView1.image = self.checkedImage;
		} else {
			consumptionCell.checkMarkImageView1.image = self.uncheckedImage;
		}
	}
	
	if (consumptionCell.checkMarkImageView2) {
		if (consumedCount >= 2) {
			consumptionCell.checkMarkImageView2.image = self.checkedImage;
		} else {
			consumptionCell.checkMarkImageView2.image = self.uncheckedImage;
		}
	}
	
	if (consumptionCell.checkMarkImageView3) {
		if (consumedCount >= 3) {
			consumptionCell.checkMarkImageView3.image = self.checkedImage;
		} else {
			consumptionCell.checkMarkImageView3.image = self.uncheckedImage;
		}
	}
	
	if (consumptionCell.checkMarkImageView4) {
		if (consumedCount >= 4) {
			consumptionCell.checkMarkImageView4.image = self.checkedImage;
		} else {
			consumptionCell.checkMarkImageView4.image = self.uncheckedImage;
		}
	}
	
	if (consumptionCell.checkMarkImageView5) {
		if (consumedCount >= 5) {
			consumptionCell.checkMarkImageView5.image = self.checkedImage;
		} else {
			consumptionCell.checkMarkImageView5.image = self.uncheckedImage;
		}
	}
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	DBConsumption *consumption = ((DBConsumption *)(self.dailyReport.consumptions[indexPath.row]));
	
	FoodTypeDetailsViewController *vController = [[FoodTypeDetailsViewController alloc] initWithDBConsumption:consumption];
	[self.navigationController pushViewController:vController animated:YES];
}

@end
