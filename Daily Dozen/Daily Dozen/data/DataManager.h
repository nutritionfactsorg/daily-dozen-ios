//
//  DataManager.h
//  Daily Dozen
//
//  Created by Chan Kruse on 2015-10-02.
//  Copyright © 2015 NutritionFacts.org. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DBDailyReport;

@interface DataManager : NSObject

+ (DataManager *)getInstance;
- (DBDailyReport *)getReportForToday;

@end
