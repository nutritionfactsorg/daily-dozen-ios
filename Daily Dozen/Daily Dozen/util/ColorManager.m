//
//  ColorManager.m
//  Daily Dozen
//
//  Created by Chan Kruse on 2015-10-02.
//  Copyright © 2015 NutritionFacts.org. All rights reserved.
//

#import "ColorManager.h"

@implementation ColorManager

static ColorManager *sharedColorManager;

+ (void)initialize {
	static BOOL initialized = NO;
	
	if(!initialized) {
		initialized = YES;
		sharedColorManager = [[ColorManager alloc] init];
	}
}

+ (ColorManager *)getInstance {
	return sharedColorManager;
}

@end
