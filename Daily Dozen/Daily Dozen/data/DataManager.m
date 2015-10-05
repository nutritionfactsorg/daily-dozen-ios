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

- (DBDailyReport *)getReportForToday {
	
	NSError *error = nil;
	
	NSDateComponents *components = [[NSCalendar currentCalendar]
									components:(NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay)
									fromDate:[NSDate date]];
	
	NSDate *startDate = [[NSCalendar currentCalendar]
						 dateFromComponents:components];
	
	return [DBDailyReport getDailyReportForDate:startDate
									inContext:[[DatabaseManager sharedInstance] defaultUserContext]
										  error:&error];
}

- (void)setServingCount:(double)servingCount forDBConsumption:(DBConsumption *)consumption {
	
	NSError *error = nil;
	
	[consumption setConsumedServingCount:@(servingCount)];
	
	[[[DatabaseManager sharedInstance] defaultUserContext] save:&error];
}

- (DBConsumption *)getConsumption:(NSManagedObjectID *)objectId {
	return [[[DatabaseManager sharedInstance] defaultDataContext] objectWithID:objectId];
}

@end
