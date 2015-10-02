//
//  DBDailyReport+CoreDataProperties.h
//  Daily Dozen
//
//  Created by Chan Kruse on 2015-10-02.
//  Copyright © 2015 NutritionFacts.org. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "DBDailyReport.h"

NS_ASSUME_NONNULL_BEGIN

@interface DBDailyReport (CoreDataProperties)

@property (nullable, nonatomic, retain) NSDate *date;
@property (nullable, nonatomic, retain) DBUser *user;
@property (nullable, nonatomic, retain) NSSet<DBConsumption *> *consumptions;

@end

@interface DBDailyReport (CoreDataGeneratedAccessors)

- (void)addConsumptionsObject:(DBConsumption *)value;
- (void)removeConsumptionsObject:(DBConsumption *)value;
- (void)addConsumptions:(NSSet<DBConsumption *> *)values;
- (void)removeConsumptions:(NSSet<DBConsumption *> *)values;

@end

NS_ASSUME_NONNULL_END
