//
//  DataManager.h
//  Daily Dozen
//
//  Created by Chan Kruse on 2015-10-02.
//  Copyright © 2015 NutritionFacts.org. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DBDailyReport, DBConsumption;

@interface DataManager : NSObject

+ (DataManager *)getInstance;
- (NSDate *)getCurrentDate;
- (DBDailyReport *)getReportForToday;
- (void)setServingCount:(double)servingCount forDBConsumption:(DBConsumption *)consumption;

@end
