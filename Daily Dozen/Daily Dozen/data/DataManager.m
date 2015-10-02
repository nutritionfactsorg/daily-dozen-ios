//
//  DataManager.m
//  Daily Dozen
//
//  Created by Chan Kruse on 2015-10-02.
//  Copyright © 2015 NutritionFacts.org. All rights reserved.
//

#import "DataManager.h"
#import "DBDailyReport.h"

@implementation DataManager

static DataManager *sharedInstance;

+ (void)initialize {
	static BOOL initialized = NO;
	
	if(!initialized) {
		initialized = YES;
		sharedInstance = [[DataManager alloc] init];
	}
}

+ (DataManager *)getInstance {
	return sharedInstance;
}

- (DBDailyReport *)getReportForToday {
	
}

@end
