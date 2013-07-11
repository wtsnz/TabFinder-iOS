//
//  CoreDataHelper.h
//  TabFinder
//
//  Created by Luiz Gustavo Faria on 01/10/12.
//  Copyright (c) 2012 Luiz Gustavo Faria. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OldCoreDataHelper : NSObject

+(OldCoreDataHelper *)get;
- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
- (NSManagedObjectContext *)managedObjectContext;
- (id)disconnectedEntityForName:(NSString *)entityName;

@end
