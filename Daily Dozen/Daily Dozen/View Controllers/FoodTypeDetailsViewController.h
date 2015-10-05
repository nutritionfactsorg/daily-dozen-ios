//
//  FoodTypeDetailsViewController.h
//  Daily Dozen
//
//  Created by Chan Kruse on 2015-10-04.
//  Copyright © 2015 NutritionFacts.org. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DBConsumption;

@interface FoodTypeDetailsViewController : UIViewController

- (id)initWithDBConsumption:(DBConsumption *)consumption;

@end
