//
//  DBConsumption.h
//  Daily Dozen
//
//  Created by Chan Kruse on 2015-10-02.
//  Copyright © 2015 NutritionFacts.org. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class FoodType;

NS_ASSUME_NONNULL_BEGIN

@interface DBConsumption : NSManagedObject

// Insert code here to declare functionality of your managed object subclass
@property (nonatomic, strong) FoodType *foodType;

@end

NS_ASSUME_NONNULL_END

#import "DBConsumption+CoreDataProperties.h"
