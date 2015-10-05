//
//  DBDailyReport.m
//  Daily Dozen
//
//  Created by Chan Kruse on 2015-10-04.
//  Copyright © 2015 NutritionFacts.org. All rights reserved.
//

#import "DBDailyReport.h"
#import "DBConsumption.h"
#import "DBUser.h"
#import "NSManagedObject+Additions.h"
#import "FoodType.h"
#import "FoodHelper.h"


@implementation DBDailyReport

// Insert code here to add functionality to your managed object subclass
+ (DBDailyReport *)getDailyReportForDate:(NSDate *)date inContext:(NSManagedObjectContext *)context error:(NSError *__autoreleasing *)error {
	
	NSFetchRequest *request = [DBDailyReport fetchRequestForManagedObjectContext:context];
	request.predicate = [NSPredicate predicateWithFormat:@"date == %@", date];
	request.returnsObjectsAsFaults = NO;
	NSArray *existingDailyReports = [context executeFetchRequest:request error:error];
	
	DBDailyReport *dailyReport = nil;
	
	if (existingDailyReports.count) {
		dailyReport = existingDailyReports.lastObject;
	}
	
	if (!dailyReport) {
		dailyReport = [DBDailyReport initializeDailyReportForDate:date inContext:context error:error];
	}
	
	for (DBConsumption *consumption in [dailyReport consumptions]) {
		consumption.foodType = [[FoodHelper getInstance] getFoodTypeForFoodIdentifier:[consumption foodTypeIdentifier]];
	}
	
	return dailyReport;
}

+ (DBDailyReport *)initializeDailyReportForDate:(NSDate *)date inContext:(NSManagedObjectContext *)context error:(NSError *__autoreleasing *)error {
	
	NSEntityDescription *entity = [DBDailyReport entityDescriptionInManagedObjectContext:context];
	DBDailyReport *dailyReport = [[DBDailyReport alloc] initWithEntity:entity insertIntoManagedObjectContext:context];
	
	NSMutableArray *consumptions = [NSMutableArray array];
	
	entity = [DBConsumption entityDescriptionInManagedObjectContext:context];
	
	//beans
	DBConsumption *beans = [[DBConsumption alloc] initWithEntity:entity insertIntoManagedObjectContext:context];
	[beans setFoodTypeIdentifier:K_IDENTIFIER_BEANS];
	[beans setConsumedServingCount:@(0.0)];
	[consumptions addObject:beans];
	
	//berries
	DBConsumption *berries = [[DBConsumption alloc] initWithEntity:entity insertIntoManagedObjectContext:context];
	[berries setFoodTypeIdentifier:K_IDENTIFIER_BERRIES];
	[berries setConsumedServingCount:@(0.0)];
	[consumptions addObject:berries];
	
	//other fruit
	DBConsumption *otherFruit = [[DBConsumption alloc] initWithEntity:entity insertIntoManagedObjectContext:context];
	[otherFruit setFoodTypeIdentifier:K_IDENTIFIER_OTHER_FRUIT];
	[otherFruit setConsumedServingCount:@(0.0)];
	[consumptions addObject:otherFruit];
	
	//cruciferous
	DBConsumption *cruciferous = [[DBConsumption alloc] initWithEntity:entity insertIntoManagedObjectContext:context];
	[cruciferous setFoodTypeIdentifier:K_IDENTIFIER_CRUCIFEROUS];
	[cruciferous setConsumedServingCount:@(0.0)];
	[consumptions addObject:cruciferous];
	
	//greens
	DBConsumption *greens = [[DBConsumption alloc] initWithEntity:entity insertIntoManagedObjectContext:context];
	[greens setFoodTypeIdentifier:K_IDENTIFIER_GREENS];
	[greens setConsumedServingCount:@(0.0)];
	[consumptions addObject:greens];
	
	//other vegetables
	DBConsumption *otherVegetables = [[DBConsumption alloc] initWithEntity:entity insertIntoManagedObjectContext:context];
	[otherVegetables setFoodTypeIdentifier:K_IDENTIFIER_OTHER_VEG];
	[otherVegetables setConsumedServingCount:@(0.0)];
	[consumptions addObject:otherVegetables];
	
	//flaxseeds
	DBConsumption *flaxSeeds = [[DBConsumption alloc] initWithEntity:entity insertIntoManagedObjectContext:context];
	[flaxSeeds setFoodTypeIdentifier:K_IDENTIFIER_FLAX];
	[flaxSeeds setConsumedServingCount:@(0.0)];
	[consumptions addObject:flaxSeeds];
	
	//nuts
	DBConsumption *nuts = [[DBConsumption alloc] initWithEntity:entity insertIntoManagedObjectContext:context];
	[nuts setFoodTypeIdentifier:K_IDENTIFIER_NUTS];
	[nuts setConsumedServingCount:@(0.0)];
	[consumptions addObject:nuts];
	
	//spices
	DBConsumption *spices = [[DBConsumption alloc] initWithEntity:entity insertIntoManagedObjectContext:context];
	[spices setFoodTypeIdentifier:K_IDENTIFIER_SPICES];
	[spices setConsumedServingCount:@(0.0)];
	[consumptions addObject:spices];
	
	//whole grains
	DBConsumption *wholeGrains = [[DBConsumption alloc] initWithEntity:entity insertIntoManagedObjectContext:context];
	[wholeGrains setFoodTypeIdentifier:K_IDENTIFIER_WHOLE_GRAINS];
	[wholeGrains setConsumedServingCount:@(0.0)];
	[consumptions addObject:wholeGrains];
	
	//beverages
	DBConsumption *beverages = [[DBConsumption alloc] initWithEntity:entity insertIntoManagedObjectContext:context];
	[beverages setFoodTypeIdentifier:K_IDENTIFIER_BEVERAGES];
	[beverages setConsumedServingCount:@(0.0)];
	[consumptions addObject:beverages];
	
	//exercises
	DBConsumption *exercises = [[DBConsumption alloc] initWithEntity:entity insertIntoManagedObjectContext:context];
	[exercises setFoodTypeIdentifier:K_IDENTIFIER_EXERCISES];
	[exercises setConsumedServingCount:@(0.0)];
	[consumptions addObject:exercises];
	
	[dailyReport setConsumptions:[NSOrderedSet orderedSetWithArray:consumptions]];
	
	[context save:error];
	
	if (*error) return nil;
	
	return dailyReport;
}

@end
