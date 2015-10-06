//
//  DatabaseManager.h
//  Daily Dozen
//
//  Created by Chan Kruse on 2015-10-02.
//  Copyright © 2015 NutritionFacts.org. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface DatabaseManager : NSObject {
	NSPersistentStoreCoordinator *_userCoordinator;
	NSPersistentStore *_userStore;
	NSManagedObjectContext *_userContext;
	NSManagedObjectModel *_model;
	NSOperationQueue *_operationQueue;
}

+ (DatabaseManager *)sharedInstance;

// Managing local stores
- (BOOL)isDatabaseUpdateRequiredForUserID:(NSNumber *)identifier error:(NSError *__autoreleasing *)error;
- (BOOL)loadStoreForUserID:(NSNumber *)identifier error:(NSError *__autoreleasing *)error;
- (BOOL)unloadCurrentUserStore:(NSError *__autoreleasing *)error;
- (BOOL)deleteStoreForUserID:(NSNumber *)identifier error:(NSError *__autoreleasing *)error;
- (BOOL)isUserStoreLoaded;

// Obtaining contexts
- (NSManagedObjectContext *)defaultUserContext;

- (BOOL)doesStoreExistForUserID:(NSNumber *)identifier;

@end
