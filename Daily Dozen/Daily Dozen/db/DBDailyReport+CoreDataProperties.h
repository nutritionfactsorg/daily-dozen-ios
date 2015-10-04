//
//  DBDailyReport+CoreDataProperties.h
//  Daily Dozen
//
//  Created by Chan Kruse on 2015-10-04.
//  Copyright © 2015 NutritionFacts.org. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "DBDailyReport.h"

NS_ASSUME_NONNULL_BEGIN

@interface DBDailyReport (CoreDataProperties)

@property (nullable, nonatomic, retain) NSDate *date;
@property (nullable, nonatomic, retain) NSOrderedSet<DBConsumption *> *consumptions;
@property (nullable, nonatomic, retain) DBUser *user;

@end

@interface DBDailyReport (CoreDataGeneratedAccessors)

- (void)insertObject:(DBConsumption *)value inConsumptionsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromConsumptionsAtIndex:(NSUInteger)idx;
- (void)insertConsumptions:(NSArray<DBConsumption *> *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeConsumptionsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInConsumptionsAtIndex:(NSUInteger)idx withObject:(DBConsumption *)value;
- (void)replaceConsumptionsAtIndexes:(NSIndexSet *)indexes withConsumptions:(NSArray<DBConsumption *> *)values;
- (void)addConsumptionsObject:(DBConsumption *)value;
- (void)removeConsumptionsObject:(DBConsumption *)value;
- (void)addConsumptions:(NSOrderedSet<DBConsumption *> *)values;
- (void)removeConsumptions:(NSOrderedSet<DBConsumption *> *)values;

@end

NS_ASSUME_NONNULL_END
