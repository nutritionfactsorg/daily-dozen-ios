//
//  ColorManager.h
//  Daily Dozen
//
//  Created by Chan Kruse on 2015-10-02.
//  Copyright © 2015 NutritionFacts.org. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ColorManager : NSObject

extern UIColor* const K_COLOR_NAV_BAR;

+ (ColorManager *)getInstance;

@end
