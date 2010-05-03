//
//  ManagedObjectsController.h
//  chiive
//
//  Created by 17FEET on 11/20/09.
//  Copyright 2009 17FEET. All rights reserved.
//


@interface ManagedObjectsController : NSObject {
    NSPersistentStoreCoordinator	*_persistentStoreCoordinator;
    NSManagedObjectModel			*_managedObjectModel;
    NSManagedObjectContext			*_managedObjectContext;
}

@property (nonatomic, retain, readonly) NSManagedObjectModel			*managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext			*managedObjectContext;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator	*persistentStoreCoordinator;

+ (ManagedObjectsController *)getInstance;
+ (NSEntityDescription *)entityForName:(NSString *)name;

/**
 * Returns a retained NSManagedObject (not autoreleased)
 */
+ (NSManagedObject *)objectWithClass:(Class)klass;

/**
 * Removes all managed objects from the database.  Called when a user logs out.
 */
- (void)resetData;

/**
 * For testing purposes only!
 */
- (NSInteger)numberOfSavedObjectsWithClass:(Class)klass;

- (NSEntityDescription *)entityForName:(NSString *)name;

/**
 * Returns a retained NSManagedObject (not autoreleased)
 */
- (NSManagedObject *)objectWithClass:(Class)klass;

- (void)deleteObject:(NSManagedObject *)object;
- (NSArray *)executeFetchRequest:(NSFetchRequest *)request;
- (BOOL)saveChanges;

@end
