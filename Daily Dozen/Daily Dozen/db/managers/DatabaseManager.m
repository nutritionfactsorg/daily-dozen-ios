//
//  DatabaseManager.m
//  Daily Dozen
//
//  Created by Chan Kruse on 2015-10-02.
//  Copyright © 2015 NutritionFacts.org. All rights reserved.
//

#import "DatabaseManager.h"
#import <UIKit/UIApplication.h>
#import "NSManagedObject+Additions.h"
#import "DBUser.h"

static NSString * const USER_DATABASE_PREFIX = @"User";
static NSString * const DATABASE_EXTENSION = @"sqlite";
static NSString * const MODEL_NAME = @"Daily_Dozen";
static NSString * const MODEL_EXTENSION = @"momd";

@interface DatabaseManager ()

- (DBUser *)user:(NSError *__autoreleasing *)error;
- (NSURL *)storeURLForUserID:(NSNumber *)userID;
- (NSOperation *)performBackgroundChanges:(void (^)(NSManagedObjectContext *context))changeBlock foregroundContext:(NSManagedObjectContext *)foregroundContext completion:(void (^)(NSManagedObjectContext *context))completion;

@end

@implementation DatabaseManager

// Singleton instance variable
static DatabaseManager *_sharedInstance;

+ (DatabaseManager *)sharedInstance {
	@synchronized(self) {
		if(!_sharedInstance) {
			_sharedInstance = [[DatabaseManager alloc] init];
		}
		
		return _sharedInstance;
	}
}

- (id)init {
	if(self = [super init]) {
		// Load the managed object model
		NSURL *modelURL = [[NSBundle mainBundle] URLForResource:MODEL_NAME withExtension:MODEL_EXTENSION];
		_model = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
		
		// Create the persisten store coordinators from the model
		_userCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:_model];
		_dataCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:_model];
		
		// Load the data store
		[self loadDataStore:nil];
		
		_operationQueue = [[NSOperationQueue alloc] init];
		
		// Register for receiving notifications when contexts change
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contextChanged:) name:NSManagedObjectContextDidSaveNotification object:nil];
	}
	
	return self;
}

#pragma mark Managing local stores

- (BOOL)loadDataStore:(NSError *__autoreleasing *)error {
	NSDictionary *options = @{NSMigratePersistentStoresAutomaticallyOption : @(YES), NSInferMappingModelAutomaticallyOption : @(YES)};
	_dataStore = [_dataCoordinator addPersistentStoreWithType:NSInMemoryStoreType configuration:nil URL:nil options:options error:error];
	
	if(!_dataStore || (error && *error)) return NO;
	
	// Create a new context to manage changes to store
	_dataContext = [[NSManagedObjectContext alloc] init];
	_dataContext.persistentStoreCoordinator = _dataCoordinator;
	_dataContext.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy;
	
	return YES;
}

- (BOOL)resetDataStore:(NSError *__autoreleasing *)error {
	if(_dataStore) [_dataCoordinator removePersistentStore:_dataStore error:error];
	if(error && *error) return NO;
	
	return [self loadDataStore:error];
}

- (BOOL)isDataStoreLoaded {
	return _dataStore ? YES : NO;
}

- (BOOL)isDatabaseUpdateRequiredForUserID:(NSNumber *)identifier error:(NSError *__autoreleasing *)error {
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSURL *storeURL = [self storeURLForUserID:identifier];
	NSString *storePath = [storeURL path];
	
	// Unload the existing store
	BOOL success = [self unloadCurrentUserStore:error];
	
	if(*error || !success) return NO;
	
	// Copy the default file if no database already exists for this user
	if(![fileManager fileExistsAtPath:storePath]) {
		return NO; //since the database doesn't yet exist
	}
	
	// Determine if a migration is needed
	NSDictionary *sourceMetadata = [NSPersistentStoreCoordinator metadataForPersistentStoreOfType:NSSQLiteStoreType
																							  URL:storeURL
																							error:error];
	NSManagedObjectModel *destinationModel = [_userCoordinator managedObjectModel];
	BOOL currentStoreCompatibile = [destinationModel isConfiguration:nil compatibleWithStoreMetadata:sourceMetadata];
	
	return !currentStoreCompatibile;
}

- (BOOL)loadStoreForUserID:(NSNumber *)identifier error:(NSError *__autoreleasing *)error {
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSURL *storeURL = [self storeURLForUserID:identifier];
	NSString *storePath = [storeURL path];
	
	// Unload the existing store
	BOOL success = [self unloadCurrentUserStore:error];
	
	if(*error || !success) return NO;
	
	// Load store for user and migrate it to current model if necessary
	NSDictionary *options = @{NSMigratePersistentStoresAutomaticallyOption : @(YES), NSInferMappingModelAutomaticallyOption : @(YES)};
	_userStore = [_userCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:error];
	
	if(!_userStore || *error) return NO;
	
	// Create a new context to handle managed objects from new store
	_userContext = [[NSManagedObjectContext alloc] init];
	_userContext.persistentStoreCoordinator = _userCoordinator;
	[_userContext setMergePolicy:[[NSMergePolicy alloc] initWithMergeType:NSMergeByPropertyObjectTrumpMergePolicyType]];
	
	// Create a new user object if none already exists
	if(![self user:error]) {
		NSEntityDescription *entity = [DBUser entityDescriptionInManagedObjectContext:_userContext];
		DBUser *user = [[DBUser alloc] initWithEntity:entity insertIntoManagedObjectContext:_userContext];
		user.identifier = identifier;
		
		[_userContext save:error];
	}
	
	return YES;
}

- (BOOL)unloadCurrentUserStore:(NSError *__autoreleasing *)error {
	if(!_userStore) return YES;
	
	// Remove the existing store from the persistent store coordinator
	BOOL success = [_userCoordinator removePersistentStore:_userStore error:error];
	
	// Clear the store and context properties
	_userContext = nil;
	_userStore = nil;
	
	return (!*error && success);
}

- (BOOL)deleteStoreForUserID:(NSNumber *)identifier error:(NSError *__autoreleasing *)error {
	NSURL *storeURL = [self storeURLForUserID:identifier];
	BOOL success = NO;
	
	if(_userStore && [_userStore.URL isEqual:storeURL]) {
		// Unload the existing store before deleting
		success = [self unloadCurrentUserStore:error];
		
		if(*error || !success) return NO;
	}
	
	// Delete the file backing the store
	success = [[NSFileManager defaultManager] removeItemAtURL:storeURL error:error];
	
	return (!*error && success);
}

- (BOOL)isUserStoreLoaded {
	return _userStore ? YES : NO;
}

- (NSURL *)storeURLForUserID:(NSNumber *)identifier {
	NSString *storeName = [NSString stringWithFormat:@"%@%d.%@", USER_DATABASE_PREFIX, [identifier intValue], DATABASE_EXTENSION];
	NSURL *documentsDirectoryURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
	
	return [documentsDirectoryURL URLByAppendingPathComponent:storeName];
}

#pragma mark Obtaining contexts

- (NSManagedObjectContext *)defaultDataContext {
	return _dataContext;
}

- (NSManagedObjectContext *)temporaryDataContext {
	if(!_dataStore) return nil;
	
	NSManagedObjectContext *context = [[NSManagedObjectContext alloc] init];
	context.persistentStoreCoordinator = _dataCoordinator;
	context.undoManager = nil;
	context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy;
	
	return context;
}

- (NSManagedObjectContext *)defaultUserContext {
	return _userContext;
}

- (NSManagedObjectContext *)temporaryUserContext {
	if(!_userStore) return nil;
	
	NSManagedObjectContext *context = [[NSManagedObjectContext alloc] init];
	context.persistentStoreCoordinator = _userCoordinator;
	context.undoManager = nil;
	context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy;
	
	return context;
}

#pragma mark Performing changes in the background

- (NSOperation *)performBackgroundDataChanges:(void (^)(NSManagedObjectContext *))changeBlock completion:(void (^)(NSManagedObjectContext *))completion {
	return [self performBackgroundChanges:changeBlock foregroundContext:_dataContext completion:completion];
}

- (NSOperation *)performBackgroundUserChanges:(void (^)(NSManagedObjectContext *))changeBlock completion:(void (^)(NSManagedObjectContext *))completion {
	return [self performBackgroundChanges:changeBlock foregroundContext:_userContext completion:completion];
}

- (NSOperation *)performBackgroundChanges:(void (^)(NSManagedObjectContext *))changeBlock foregroundContext:(NSManagedObjectContext *)foregroundContext completion:(void (^)(NSManagedObjectContext *))completion {
	__block UIBackgroundTaskIdentifier backgroundTask;
	UIApplication *application = [UIApplication sharedApplication];
	
	backgroundTask = [application beginBackgroundTaskWithExpirationHandler:^{
		[application endBackgroundTask:backgroundTask];
		backgroundTask = UIBackgroundTaskInvalid;
	}];
	
	__block NSOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
		NSManagedObjectContext *backgroundContext = nil;
		
		if(foregroundContext == _userContext) backgroundContext = [self temporaryUserContext];
		else if(foregroundContext == _dataContext) backgroundContext = [self temporaryDataContext];
		else [operation cancel];
		
		if(operation.isCancelled) {
			[application endBackgroundTask:backgroundTask];
			backgroundTask = UIBackgroundTaskInvalid;
			return;
		}
		
		changeBlock(backgroundContext);
		
		if(operation.isCancelled) {
			[application endBackgroundTask:backgroundTask];
			backgroundTask = UIBackgroundTaskInvalid;
			return;
		}
		
		dispatch_sync(dispatch_get_main_queue(), ^{
			completion(foregroundContext);
		});
		
		[application endBackgroundTask:backgroundTask];
		backgroundTask = UIBackgroundTaskInvalid;
	}];
	
	[_operationQueue addOperation:operation];
	
	return operation;
}

- (void)cancelBackgroundChanges {
	[_operationQueue cancelAllOperations];
	[_operationQueue waitUntilAllOperationsAreFinished];
	DLog(@"All background operations successfully cancelled");
}

- (void)waitUntilBackgroundChangesAreFinished {
	[_operationQueue waitUntilAllOperationsAreFinished];
	DLog(@"All background operations are finished");
}

#pragma mark Propagating changes from background contexts

- (void)contextChanged:(NSNotification *)notification {
	NSManagedObjectContext *notificationContext = [notification object];
	
	if(notificationContext == _userContext || notificationContext == _dataContext) return;
	
	if(![NSThread isMainThread]) {
		[self performSelectorOnMainThread:@selector(contextChanged:) withObject:notification waitUntilDone:YES];
		return;
	}
	
	if(notificationContext.persistentStoreCoordinator == _userCoordinator) {
		[_userContext mergeChangesFromContextDidSaveNotification:notification];
	} else if(notificationContext.persistentStoreCoordinator == _dataCoordinator) {
		[_dataContext mergeChangesFromContextDidSaveNotification:notification];
	}
}

#pragma mark Getting user info

- (DBUser *)user:(NSError *__autoreleasing *)error {
	NSFetchRequest *request = [DBUser fetchRequestForManagedObjectContext:_userContext];
	NSArray *results = [_userContext executeFetchRequest:request error:error];
	
	if (results.count) {
		// Only one user in each store
		return [results lastObject];
	}
	
	return nil;
}

@end
