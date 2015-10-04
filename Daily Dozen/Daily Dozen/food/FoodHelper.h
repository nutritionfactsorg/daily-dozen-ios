//
//  FoodHelper.h
//  Daily Dozen
//
//  Created by Chan Kruse on 2015-10-04.
//  Copyright © 2015 NutritionFacts.org. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FoodType;

@interface FoodHelper : NSObject

+ (FoodHelper *)getInstance;
- (FoodType *)getFoodTypeForFoodIdentifier:(NSString *)identifier;

@end
