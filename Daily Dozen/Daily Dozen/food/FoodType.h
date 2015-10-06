//
//  FoodType.h
//  Daily Dozen
//
//  Created by Chan Kruse on 2015-10-02.
//  Copyright © 2015 NutritionFacts.org. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

extern NSString *const K_IDENTIFIER_BEANS;
extern NSString *const K_IDENTIFIER_BERRIES;
extern NSString *const K_IDENTIFIER_OTHER_FRUIT;
extern NSString *const K_IDENTIFIER_CRUCIFEROUS;
extern NSString *const K_IDENTIFIER_GREENS;
extern NSString *const K_IDENTIFIER_OTHER_VEG;
extern NSString *const K_IDENTIFIER_FLAX;
extern NSString *const K_IDENTIFIER_NUTS;
extern NSString *const K_IDENTIFIER_SPICES;
extern NSString *const K_IDENTIFIER_WHOLE_GRAINS;
extern NSString *const K_IDENTIFIER_BEVERAGES;
extern NSString *const K_IDENTIFIER_EXERCISES;

@interface FoodType : NSObject

@property (nonatomic, strong) UIImage *iconImageName;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *overviewImageName;
@property (nonatomic, assign) CGFloat recommendedServingCount;
@property (nonatomic, strong) NSString *customRecommendation;
@property (nonatomic, strong) NSString *servingExample;
@property (nonatomic, strong) NSMutableArray *exampleTitles;
@property (nonatomic, strong) NSMutableArray *exampleBodies;

@end
