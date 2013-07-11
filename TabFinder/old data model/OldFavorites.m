//
//  Favorites.m
//  TabFinder
//
//  Created by Luiz Gustavo Faria on 30/09/12.
//  Copyright (c) 2012 Luiz Gustavo Faria. All rights reserved.
//

#import "OldFavorites.h"
#import "OldCoreDataHelper.h"

@implementation OldFavorites

+(NSArray *)findAllArtists {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Artist" inManagedObjectContext:OldCoreDataHelper.get.managedObjectContext];
    [fetchRequest setEntity:entity];
    NSError *error;
    return [[OldCoreDataHelper.get.managedObjectContext executeFetchRequest:fetchRequest error:&error] sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]]];
}


@end
