//
//  DataManager.m
//  Daily Dozen
//
//  Created by Chan Kruse on 2015-10-02.
//  Copyright © 2015 NutritionFacts.org. All rights reserved.
//

#import "DataManager.h"
#import "DatabaseManager.h"
#import "DBDailyReport.h"
#import "DBConsumption.h"

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

- (BOOL)isFirstRun {
	return ![[DatabaseManager sharedInstance] doesStoreExistForUserID:@(0)];
}

- (NSDate *)getCurrentDate {
	
	NSDateComponents *components = [[NSCalendar currentCalendar]
									components:(NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay)
									fromDate:[NSDate date]];
	
	return [[NSCalendar currentCalendar]
			dateFromComponents:components];
}

- (DBDailyReport *)getReportForToday {
	
	NSError *error = nil;
	
	NSDateComponents *components = [[NSCalendar currentCalendar]
									components:(NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay)
									fromDate:[NSDate date]];
	
	NSDate *date = [self getCurrentDate];
	
	return [DBDailyReport getDailyReportForDate:date
									inContext:[[DatabaseManager sharedInstance] defaultUserContext]
										  error:&error];
}

- (void)setServingCount:(double)servingCount forDBConsumption:(DBConsumption *)consumption {
	
	NSError *error = nil;
	
	[consumption setConsumedServingCount:@(servingCount)];
	
	[[[DatabaseManager sharedInstance] defaultUserContext] save:&error];
}

@end
