//
//  DBConsumption+CoreDataProperties.h
//  Daily Dozen
//
//  Created by Chan Kruse on 2015-10-02.
//  Copyright © 2015 NutritionFacts.org. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "DBConsumption.h"

NS_ASSUME_NONNULL_BEGIN

@interface DBConsumption (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *consumedServingCount;
@property (nullable, nonatomic, retain) NSString *foodTypeIdentifier;
@property (nullable, nonatomic, retain) NSManagedObject *dailyReport;

@end

NS_ASSUME_NONNULL_END
