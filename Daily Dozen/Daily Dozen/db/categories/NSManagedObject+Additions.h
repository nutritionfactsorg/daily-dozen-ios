//
//  NSManagedObject+Additions.h
//  Daily Dozen
//
//  Created by Chan Kruse on 2015-10-02.
//  Copyright © 2015 NutritionFacts.org. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObject (Additions)

+ (NSString *)entityName;
+ (NSEntityDescription *)entityDescriptionInManagedObjectContext:(NSManagedObjectContext *)context;
+ (NSFetchRequest *)fetchRequestForManagedObjectContext:(NSManagedObjectContext *)context;

@end
