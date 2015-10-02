//
//  NSManagedObject+Additions.m
//  Daily Dozen
//
//  Created by Chan Kruse on 2015-10-02.
//  Copyright © 2015 NutritionFacts.org. All rights reserved.
//

#import "NSManagedObject+Additions.h"

@implementation NSManagedObject (Additions)

+ (NSString *)entityName {
	return NSStringFromClass([self class]);
}

+ (NSEntityDescription *)entityDescriptionInManagedObjectContext:(NSManagedObjectContext *)context {
	return [NSEntityDescription entityForName:[self entityName] inManagedObjectContext:context];
}

+ (NSFetchRequest *)fetchRequestForManagedObjectContext:(NSManagedObjectContext *)context {
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	request.entity = [self entityDescriptionInManagedObjectContext:context];
	
	return request;
}

@end
