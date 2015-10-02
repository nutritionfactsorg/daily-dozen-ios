//
//  DBUser+CoreDataProperties.h
//  Daily Dozen
//
//  Created by Chan Kruse on 2015-10-02.
//  Copyright © 2015 NutritionFacts.org. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "DBUser.h"

NS_ASSUME_NONNULL_BEGIN

@interface DBUser (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *usageCount;
@property (nullable, nonatomic, retain) NSNumber *identifier;
@property (nullable, nonatomic, retain) NSSet<DBDailyReport *> *dailyReports;

@end

@interface DBUser (CoreDataGeneratedAccessors)

- (void)addDailyReportsObject:(DBDailyReport *)value;
- (void)removeDailyReportsObject:(DBDailyReport *)value;
- (void)addDailyReports:(NSSet<DBDailyReport *> *)values;
- (void)removeDailyReports:(NSSet<DBDailyReport *> *)values;

@end

NS_ASSUME_NONNULL_END
