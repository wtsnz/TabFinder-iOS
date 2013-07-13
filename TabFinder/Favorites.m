//
//  Favorites.m
//  TabFinder
//
//  Created by Luiz Gustavo Faria on 13/05/13.
//  Copyright (c) 2013 PDM Systems. All rights reserved.
//

#import "Favorites.h"
#import "CoreDataHelper.h"
#import "NSDictionary+Song.h"
#import "Api.h"
#import "OldCoreDataHelper.h"

@implementation Favorites

+(Song *)addToDatabase:(NSDictionary *)version withContent:(NSString *)tab {
    Song *song = [NSEntityDescription insertNewObjectForEntityForName:@"Song" inManagedObjectContext:[CoreDataHelper.get managedObjectContext]];
    song.name = version.name;
    song.artist= version.artist;
    song.type = version.type;
    song.tab = tab;
    song.version = @(version.versionNumber.integerValue);
    song.ugid = version[@"id"];
    song.type2 = version.type2;
    song.isFavorite = @(NO);
    song.dateOfCreation = [NSDate date];
    if ([Api artistPhotoForArtist:song.artist]) {
        song.artistImage = UIImagePNGRepresentation([Api artistPhotoForArtist:song.artist]);
    }
    [CoreDataHelper.get saveContext];
    return song;
}

+(void)addToFavorites:(Song *)song {
    song.isFavorite = @(YES);
    [CoreDataHelper.get saveContext];
}

+(void)removeFromFavorites:(Song *)song {
    song.isFavorite = @(NO);
    [CoreDataHelper.get saveContext];
}

+(Song *)findByUgid:(NSString *)ugid {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Song" inManagedObjectContext:CoreDataHelper.get.managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"self.ugid == %@",ugid]];
    NSError *error;
    return [[CoreDataHelper.get.managedObjectContext executeFetchRequest:fetchRequest error:&error] sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]]].lastObject;
}

+(NSArray *)favorites {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Song" inManagedObjectContext:CoreDataHelper.get.managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"self.isFavorite == %@",@(YES)]];
    NSError *error;
    return [[CoreDataHelper.get.managedObjectContext executeFetchRequest:fetchRequest error:&error] sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]]];
}

+(NSArray *)history {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Song" inManagedObjectContext:CoreDataHelper.get.managedObjectContext];
    [fetchRequest setEntity:entity];
    NSError *error;
    return [[CoreDataHelper.get.managedObjectContext executeFetchRequest:fetchRequest error:&error] sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"dateOfCreation" ascending:NO]]];
}

+(void)convertOldFavorites {
    NSArray *oldFavoriteArtists = [OldFavorites findAllArtists];
    for (OldArtist *artist in oldFavoriteArtists) {
        for (OldSong *oldsong in artist.songs) {
            Song *song = [NSEntityDescription insertNewObjectForEntityForName:@"Song" inManagedObjectContext:[CoreDataHelper.get managedObjectContext]];
            song.name = oldsong.title;
            song.version = @(0);
            song.type = @"Tab";
            song.tab = oldsong.html;
            song.ugid = @"oldfavorites";
            song.artistImage = artist.photo;
            song.artist = artist.name;
            song.isFavorite = @(YES);
            [CoreDataHelper.get saveContext];
        }
        [OldCoreDataHelper.get.managedObjectContext deleteObject:artist];
        [OldCoreDataHelper.get saveContext];
    }
}

@end

