//
//  ManagedObjectsController.m
//  chiive
//
//  Created by 17FEET on 11/20/09.
//  Copyright 2009 17FEET. All rights reserved.
//

#import "ManagedObjectsController.h"

@implementation ManagedObjectsController

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// public class methods

+ (NSEntityDescription *)entityForName:(NSString *)name
{
	return [[self getInstance] entityForName:name];
}

+ (NSManagedObject *)objectWithClass:(Class)klass
{
	return [[self getInstance] objectWithClass:klass];
}

- (void)resetData
{
	NSArray *persistentStores = [[self.persistentStoreCoordinator persistentStores] copy];
	for (NSPersistentStore *store in persistentStores) {
		NSError *error;
		NSURL *storeURL = store.URL;
		[self.persistentStoreCoordinator removePersistentStore:store error:&error];
		[[NSFileManager defaultManager] removeItemAtPath:storeURL.path error:&error];
	}
	[persistentStores release];
	
	// drop the coordinator and managed object context
	TT_RELEASE_SAFELY(_persistentStoreCoordinator);
	TT_RELEASE_SAFELY(_managedObjectContext);
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// public instance methods

- (NSInteger)numberOfSavedObjectsWithClass:(Class)klass
{
	NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
	[request setEntity:[self entityForName:NSStringFromClass(klass)]];
	NSArray *savedChildren = [self executeFetchRequest:request];
	
	if (!savedChildren)
		return 0;
	
	return [savedChildren count];
}

- (NSEntityDescription *)entityForName:(NSString *)name
{
	NSManagedObjectContext *context = self.managedObjectContext;
	return [NSEntityDescription entityForName:name inManagedObjectContext:context];
}

- (NSManagedObject *)objectWithClass:(Class)klass
{
	NSManagedObjectContext *context = self.managedObjectContext;
	return [[[klass alloc] initWithEntity:[self entityForName:NSStringFromClass(klass)] 
		   insertIntoManagedObjectContext:context] autorelease];
}

- (BOOL)saveChanges
{
	NSError *error;
	if ([self.managedObjectContext hasChanges])
	{
		@try {
			if (![self.managedObjectContext save:&error]) {
				// Handle the error.
				NSLog(@"Unresolved Core Data save error %@, %@", error, [error userInfo]);
				return NO;
			}
		}
		@catch(NSException* ex) {
			NSLog(@"Failed Core Data save! Exception: %@", [ex reason]);
			return NO;
		}
	}
	return YES;
}

- (NSArray *)executeFetchRequest:(NSFetchRequest *)request
{
	NSError *error = nil;
	NSArray *savedChildren = [self.managedObjectContext executeFetchRequest:request error:&error];
	
	// Handle errors
	if (savedChildren == nil) {
		NSLog(@"Unresolved Core Data fetch error %@, %@", error, [error userInfo]);
		// exit(-1);  // Fail		
	}
	
	return savedChildren;
}

- (void)deleteObject:(NSManagedObject *)object
{
	[[object managedObjectContext] deleteObject:object];
}




////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Core Data Setup

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext {
	
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
	
    NSPersistentStoreCoordinator *coordinator = self.persistentStoreCoordinator;
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    return _managedObjectContext;
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created by merging all of the models found in the application bundle.
 */
- (NSManagedObjectModel *)managedObjectModel {
	
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
	
	// replaced default model creation from bundle
	//_managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];    
	
	// to model creation from the versioned ModelData.xcdatamodeld bundle
	// this allows versioning and mapping of the data model
	NSString *path = [[NSBundle mainBundle] pathForResource:@"ModelData" ofType:@"momd"];
    NSURL *momURL = [NSURL fileURLWithPath:path];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:momURL];
	
    return _managedObjectModel;
}


/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
	
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
	
	// retrieve the path to the application's documents directory
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *applicationDocumentsDirectory = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
	
    NSURL *storeUrl = [NSURL fileURLWithPath: [applicationDocumentsDirectory stringByAppendingPathComponent: @"Locations.sqlite"]];
	
	//Turn on automatic store migration
	NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
							 [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
							 [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
	
	NSError *error;
	_persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: self.managedObjectModel];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:options error:&error]) {
		// Handle the error.
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	}
	
    return _persistentStoreCoordinator;
}





////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Singleton Setup

static ManagedObjectsController *sharedInstance = nil;

+ (ManagedObjectsController *)getInstance {
    @synchronized(self) {
        if (sharedInstance == nil) {
            [[self alloc] init]; // assignment not done here
        }
    }
    return sharedInstance;
}

+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if (sharedInstance == nil) {
            sharedInstance = [super allocWithZone:zone];
			return sharedInstance;  // assignment and return on first allocation
        }
    }
    return nil; //on subsequent allocation attempts return nil
}

- (id)copyWithZone:(NSZone *)zone {
    return self;	
}

- (id)retain {
    return self;
}

- (unsigned)retainCount {
	return UINT_MAX;  //denotes an object that cannot be released
}

- (void)release {
    //do nothing
}

- (id)autorelease {
    return self;	
}

@end
