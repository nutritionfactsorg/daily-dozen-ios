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

@interface DailyReportViewController ()

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) DBDailyReport *dailyReport;
@property (nonatomic, strong) NSMutableArray *rowHeights;

@end

@implementation DailyReportViewController

- (id)init {
	if ((self = [super init])) {
		NSError *error = nil;
		
		[[DatabaseManager sharedInstance] loadStoreForUserID:@(0) error:&error];
		
		self.dailyReport = [[DataManager getInstance] getReportForToday];
		
		self.rowHeights = [NSMutableArray array];
	}
	
	return self;
}

- (void)loadView {
	UIView *view = [[UIView alloc] init];
	view.backgroundColor = [UIColor whiteColor];
	view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	self.view = view;
	
	UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
	tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	tableView.delegate = self;
	tableView.dataSource = self;
	[self.view addSubview:tableView];
	self.tableView = tableView;
	
	self.tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	if (!self.rowHeights.count) {
		for (DBConsumption *consumption in self.dailyReport.consumptions) {
			[self.rowHeights addObject:@([ConsumptionTableViewCell calculateRequiredHeightForConsumption:consumption
																							forTableView:self.tableView])];
		}
	}
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
	
	NSString *cellID = @"default";
	
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
																	 identifier:[NSString stringWithFormat:@"maxServingCount%f", foodType.recommendedServingCount]];
	
	return cell;
}

- (void)configureCell:(UITableViewCell *)cell forIndexPath:(NSIndexPath *)indexPath {
	
	ConsumptionTableViewCell *consumptionCell = (ConsumptionTableViewCell *)cell;
	
	DBConsumption *consumption = ((DBConsumption *)(self.dailyReport.consumptions[indexPath.row]));
	FoodType *foodType = consumption.foodType;
	
	consumptionCell.iconImageView.image = [UIImage imageNamed:foodType.iconImageName];
	consumptionCell.label.text = foodType.name;
	
	int consumedCount = (int)consumption.consumedServingCount.integerValue;
	
	if (consumptionCell.checkMarkImageView1) {
		if (consumedCount >= 1) {
			consumptionCell.checkMarkImageView1.image = [UIImage imageNamed:@"checkmark_filled.png"];
		} else {
			consumptionCell.checkMarkImageView1.image = [UIImage imageNamed:@"checkmark_unfilled.png"];
		}
	}
	
	if (consumptionCell.checkMarkImageView2) {
		if (consumedCount >= 2) {
			consumptionCell.checkMarkImageView2.image = [UIImage imageNamed:@"checkmark_filled.png"];
		} else {
			consumptionCell.checkMarkImageView2.image = [UIImage imageNamed:@"checkmark_unfilled.png"];
		}
	}
	
	if (consumptionCell.checkMarkImageView3) {
		if (consumedCount >= 3) {
			consumptionCell.checkMarkImageView3.image = [UIImage imageNamed:@"checkmark_filled.png"];
		} else {
			consumptionCell.checkMarkImageView3.image = [UIImage imageNamed:@"checkmark_unfilled.png"];
		}
	}
	
	if (consumptionCell.checkMarkImageView4) {
		if (consumedCount >= 4) {
			consumptionCell.checkMarkImageView4.image = [UIImage imageNamed:@"checkmark_filled.png"];
		} else {
			consumptionCell.checkMarkImageView4.image = [UIImage imageNamed:@"checkmark_unfilled.png"];
		}
	}
	
	if (consumptionCell.checkMarkImageView5) {
		if (consumedCount >= 5) {
			consumptionCell.checkMarkImageView5.image = [UIImage imageNamed:@"checkmark_filled.png"];
		} else {
			consumptionCell.checkMarkImageView5.image = [UIImage imageNamed:@"checkmark_unfilled.png"];
		}
	}
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
}
@end
