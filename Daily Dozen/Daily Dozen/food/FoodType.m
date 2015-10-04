//
//  FoodType.m
//  Daily Dozen
//
//  Created by Chan Kruse on 2015-10-02.
//  Copyright © 2015 NutritionFacts.org. All rights reserved.
//

#import "FoodType.h"

NSString *const K_IDENTIFIER_BEANS = @"K_IDENTIFIER_BEANS";
NSString *const K_IDENTIFIER_BERRIES = @"K_IDENTIFIER_BERRIES";
NSString *const K_IDENTIFIER_OTHER_FRUIT = @"K_IDENTIFIER_OTHER_FRUIT";
NSString *const K_IDENTIFIER_CRUCIFEROUS = @"K_IDENTIFIER_CRUCIFEROUS";
NSString *const K_IDENTIFIER_GREENS = @"K_IDENTIFIER_GREENS";
NSString *const K_IDENTIFIER_OTHER_VEG = @"K_IDENTIFIER_OTHER_VEG";
NSString *const K_IDENTIFIER_FLAX = @"K_IDENTIFIER_FLAX";
NSString *const K_IDENTIFIER_NUTS = @"K_IDENTIFIER_NUTS";
NSString *const K_IDENTIFIER_SPICES = @"K_IDENTIFIER_SPICES";
NSString *const K_IDENTIFIER_WHOLE_GRAINS = @"K_IDENTIFIER_WHOLE_GRAINS";
NSString *const K_IDENTIFIER_BEVERAGES = @"K_IDENTIFIER_BEVERAGES";
NSString *const K_IDENTIFIER_EXERCISES = @"K_IDENTIFIER_EXERCISES";

@implementation FoodType

- (id)init {
	if ((self = [super init])) {
		self.exampleTitles = [NSMutableArray array];
		self.exampleBodies = [NSMutableArray array];
	}
	
	return self;
}
@end
