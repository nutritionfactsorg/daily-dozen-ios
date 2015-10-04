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
#import "DataManager.h"

@interface DailyReportViewController ()

@property (nonatomic, strong) DBDailyReport *dailyReport;

@end

@implementation DailyReportViewController

- (id)init {
	if ((self = [super init])) {
		self.dailyReport = [[DataManager getInstance] getReportForToday];
	}
	
	return self;
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
