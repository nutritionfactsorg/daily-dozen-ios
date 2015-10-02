//
//  UserManager.m
//  Daily Dozen
//
//  Created by Chan Kruse on 2015-10-02.
//  Copyright © 2015 NutritionFacts.org. All rights reserved.
//

#import "UserManager.h"

@implementation UserManager

static UserManager *sharedUserManager;

+ (void)initialize {
	static BOOL initialized = NO;
	
	if(!initialized) {
		initialized = YES;
		sharedUserManager = [[UserManager alloc] init];
	}
}

+ (UserManager *)getInstance {
	return sharedUserManager;
}

- (BOOL)hasUserRegistered {
	return YES;
}


@end
