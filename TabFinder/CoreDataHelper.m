//
//  CoreDataHelper.m
//  TabFinder
//
//  Created by Luiz Gustavo Faria on 01/10/12.
//  Copyright (c) 2012 Luiz Gustavo Faria. All rights reserved.
//

#import "CoreDataHelper.h"
#import <CoreData/CoreData.h>
#import "Favorites.h"
#import "Engine.h"

@interface CoreDataHelper ()

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSPersistentStore *iCloudStore;
@property (readonly, strong, nonatomic) NSPersistentStore *localStore;

@end

@implementation CoreDataHelper

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

static CoreDataHelper *coreDataHelper;

+(CoreDataHelper *)get {
    if (coreDataHelper == nil) {
        coreDataHelper = [[CoreDataHelper alloc] init];
    }
    return coreDataHelper;
}

+(void)reset {
    [coreDataHelper loadPersistentStores];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    [self loadPersistentStores];
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Favorites" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    return _persistentStoreCoordinator;
}

-(NSDictionary *)localOptions {
    return [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
            [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
}

- (BOOL)loadLocalPersistentStore:(NSError **)error {
    BOOL success = YES;
    NSError *localError = nil;
    NSPersistentStoreCoordinator *psc = [self persistentStoreCoordinator];
    if (_iCloudStore) {
        [psc removePersistentStore:_iCloudStore error:error];
    }
    //load the local store file
    NSURL *storePath = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Favorites.sqlite"];
    NSDictionary *options = [self localOptions];
    
    //add the store
    _localStore = [psc addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storePath options:options error:&localError];
    
    success = (_localStore != nil);
    if (success == NO) {
        if (localError && (error != NULL)) {
            *error = localError;
        }
    }
    return success;
}

-(NSDictionary *)iCloudOptions {
    return [NSDictionary dictionaryWithObjectsAndKeys:
            @"iCloudStore", NSPersistentStoreUbiquitousContentNameKey,
            [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
            [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
}

-(BOOL)loadiCloudStore:(NSError **)error {
    BOOL success = YES;
    NSPersistentStoreCoordinator *psc = _persistentStoreCoordinator;
    if (_localStore) {
        [_persistentStoreCoordinator removePersistentStore:_localStore error:error];
    }
    NSError *localError = nil;
    NSDictionary *iCloudOptions = nil;
    NSURL *iCloudStoreUrl = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"iCloudStore.sqlite"];
    //  The API to turn on Core Data iCloud support here.
    iCloudOptions = [self iCloudOptions];
    _iCloudStore = [psc addPersistentStoreWithType:NSSQLiteStoreType
                                     configuration:nil
                                               URL:iCloudStoreUrl
                                           options:iCloudOptions
                                             error:&localError];
    success = (_iCloudStore != nil);
    if (!success) {
        if (localError  && (error != NULL)) {
            *error = localError;
        }
    }
    return success;
}

- (void)loadPersistentStores {
    NSLog(@"Loading persistent stores...");
    BOOL locked = NO;
    NSLock *loadingLock = [[NSLock alloc] init];
    @try {
        
        [loadingLock lock];
        locked = YES;
        [self nowLoadPersistentStores];
    }
    @finally {
        if (locked) {
            [loadingLock unlock];
            locked = NO;
        }
    }
    loadingLock = nil;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MovedBetweenDatabases" object:self userInfo:nil];
}

- (void)nowLoadPersistentStores {
    NSError *error = nil;
    BOOL useLocalStore = NO;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults synchronize];
    if ([defaults boolForKey:@"enable_iCloud"]) {
        if ([self loadiCloudStore:&error]) {
            if ([[NSFileManager defaultManager] fileExistsAtPath:[[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Favorites.sqlite"].path] && ![defaults boolForKey:@"did_seed_local_to_iCloud"]) {
                [self seedStore:_iCloudStore withPersistentStoreAtURL:[[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Favorites.sqlite"] error:&error];
                [defaults setBool:YES forKey:@"did_seed_local_to_iCloud"];
            } else {
                NSLog(@"Nothing to seed from local store to iCloud");
            }
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deDupe:) name:NSPersistentStoreDidImportUbiquitousContentChangesNotification object:nil];
        }
        else {
            [[[UIAlertView alloc] initWithTitle:@"Unable to sync with iCloud" message:@"Something went wrong, try again later." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
            NSLog(@"iCloud failure reason: %@", [error localizedFailureReason]);
            useLocalStore = YES;
        }
    }
    else {
        useLocalStore = YES;
    }
    if (useLocalStore) {
        if ([self loadLocalPersistentStore:&error]) {
            NSLog(@"Local store loaded!");
            [defaults setBool:NO forKey:@"enable_iCloud"];
        }
    }
}

- (void)deDupe:(NSNotification *)importNotification {
    //if importNotification, scope dedupe by inserted records
    //else no search scope, prey for efficiency.
    [self removeDuplicates];
    [self.managedObjectContext mergeChangesFromContextDidSaveNotification:importNotification];
}

-(void)removeDuplicates {
    @autoreleasepool {
        NSError *error = nil;
        NSManagedObjectContext *moc = [[NSManagedObjectContext alloc] init];
        [moc setPersistentStoreCoordinator:_persistentStoreCoordinator];
        //
        NSFetchRequest *fr = [[NSFetchRequest alloc] initWithEntityName:@"Song"];
        [fr setIncludesPendingChanges:NO]; //distinct has to go down to the db, not implemented for in memory filtering
        [fr setFetchBatchSize:300]; //protect thy memory
        
        NSExpression *countExpr = [NSExpression expressionWithFormat:@"count:(ugid)"];
        NSExpressionDescription *countExprDesc = [[NSExpressionDescription alloc] init];
        [countExprDesc setName:@"count"];
        [countExprDesc setExpression:countExpr];
        [countExprDesc setExpressionResultType:NSInteger64AttributeType];
        
        NSAttributeDescription *ugidAttr = [[[[[_persistentStoreCoordinator managedObjectModel] entitiesByName] objectForKey:@"Song"] propertiesByName] objectForKey:@"ugid"];
        [fr setPropertiesToFetch:[NSArray arrayWithObjects:ugidAttr, countExprDesc, nil]];
        [fr setPropertiesToGroupBy:[NSArray arrayWithObject:ugidAttr]];
        
        [fr setResultType:NSDictionaryResultType];
        
        NSArray *countDictionaries = [moc executeFetchRequest:fr error:&error];
        NSMutableArray *duplicatedTabs = [[NSMutableArray alloc] init];
        for (NSDictionary *dict in countDictionaries) {
            NSNumber *count = [dict objectForKey:@"count"];
            if ([count integerValue] > 1) {
                [duplicatedTabs addObject:[dict objectForKey:@"ugid"]];
            }
        }
        
        NSLog(@"Tabs with dupes: %@", duplicatedTabs);
        
        //fetch out all the duplicate records
        fr = [NSFetchRequest fetchRequestWithEntityName:@"Song"];
        [fr setIncludesPendingChanges:NO];
        
        
        NSPredicate *p = [NSPredicate predicateWithFormat:@"ugid IN (%@)", duplicatedTabs];
        [fr setPredicate:p];
        
        NSSortDescriptor *emailSort = [NSSortDescriptor sortDescriptorWithKey:@"ugid" ascending:YES];
        [fr setSortDescriptors:[NSArray arrayWithObject:emailSort]];
        
        NSUInteger batchSize = 500; //can be set 100-10000 objects depending on individual object size and available device memory
        [fr setFetchBatchSize:batchSize];
        NSArray *dupes = [moc executeFetchRequest:fr error:&error];
        
        Song *prevSong = nil;
        
        NSUInteger i = 1;
        for (Song *song in dupes) {
            if (prevSong && [song.ugid isEqualToString:prevSong.ugid]) {
                if (prevSong.isFavorite.boolValue) song.isFavorite = @(YES);
                [moc deleteObject:prevSong];
            }
            prevSong = song;
            if (0 == (i % batchSize)) {
                //save the changes after each batch, this helps control memory pressure by turning previously examined objects back in to faults
                if ([moc save:&error]) {
                    NSLog(@"Saved successfully after uniquing");
                } else {
                    NSLog(@"Error saving unique results: %@", error);
                }
            }
            i++;
        }
        if ([moc save:&error]) {
            NSLog(@"Saved successfully after uniquing");
        } else {
            NSLog(@"Error saving unique results: %@", error);
        }
    }
}

- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (id)disconnectedEntityForName:(NSString *)entityName {
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:entityName inManagedObjectContext:[self managedObjectContext]];
    return [[NSManagedObject alloc] initWithEntity:entityDescription insertIntoManagedObjectContext:nil];
}

// seeding

-(BOOL)seedStore:(NSPersistentStore *)store withPersistentStoreAtURL:(NSURL *)seedStoreURL error:(NSError * __autoreleasing *)error {
    BOOL success = YES;
    NSError *localError = nil;
    
    NSManagedObjectModel *model = _managedObjectModel;
    NSPersistentStoreCoordinator *seedPSC = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
    NSDictionary *seedStoreOptions = @{ NSReadOnlyPersistentStoreOption : [NSNumber numberWithBool:YES] };
    NSPersistentStore *seedStore = [seedPSC addPersistentStoreWithType:NSSQLiteStoreType
                                                         configuration:nil
                                                                   URL:seedStoreURL
                                                               options:seedStoreOptions
                                                                 error:&localError];
    if (seedStore) {
        NSManagedObjectContext *seedMOC = [[NSManagedObjectContext alloc] init];
        [seedMOC setPersistentStoreCoordinator:seedPSC];
        
        //fetch all the person objects, use a batched fetch request to control memory usage
        NSFetchRequest *fr = [NSFetchRequest fetchRequestWithEntityName:@"Song"];
        NSUInteger batchSize = 5000;
        [fr setFetchBatchSize:batchSize];
        NSArray *songs = [seedMOC executeFetchRequest:fr error:&localError];
        NSManagedObjectContext *moc = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        [moc setPersistentStoreCoordinator:_persistentStoreCoordinator];
        NSUInteger i = 1;
        for (Song *song in songs) {
            if (song.isFavorite.boolValue) {
                [self addSong:song toStore:store withContext:moc];
            }
            if (0 == (i % batchSize)) {
                success = [moc save:&localError];
                if (success) {
                    [moc reset];
                } else {
                    NSLog(@"Error saving during seed: %@", localError);
                    break;
                }
            }
            i++;
        }
        if (songs.count > 100) {
            [[[UIAlertView alloc] initWithTitle:@"iCloud synching enabled!" message:[NSString stringWithFormat:@"%i songs will be uploaded to iCloud. If you're synching other devices, it could take a few hours before it's all completed. You can keep using the app normally on each device",songs.count] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
        }
        //one last save
        if ([moc hasChanges]) {
            success = [moc save:&localError];
            [moc reset];
        }
        [self removeDuplicates];
    } else {
        success = NO;
        NSLog(@"Error adding seed store: %@", localError);
    }
    if (NO == success) {
        if (localError  && (error != NULL)) {
            *error = localError;
        }
    }
    return success;
}

- (void)addSong:(Song *)song toStore:(NSPersistentStore *)store withContext:(NSManagedObjectContext *)moc {
    NSEntityDescription *entity = [song entity];
    Song *newSong = [[Song alloc] initWithEntity:entity insertIntoManagedObjectContext:moc];
    newSong.artist = song.artist;
    newSong.artistImage = song.artistImage;
    newSong.name = song.name;
    newSong.tab = song.tab;
    newSong.type = song.type;
    newSong.type2 = song.type2;
    newSong.dateOfCreation = song.dateOfCreation;
    newSong.ugid = song.ugid;
    newSong.isFavorite = song.isFavorite;
    newSong.version = song.version;
    [moc assignObject:newSong toPersistentStore:store];
}

@end
