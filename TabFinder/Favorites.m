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

+(void)clearFavorites {
    for (Song *song in [Favorites history]) {
        [[CoreDataHelper get].managedObjectContext deleteObject:song];
        [CoreDataHelper.get saveContext];
    }
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

+(void)performImageCheck {
    for (Song *song in [self history]) {
        if (!song.artistImage) [Api getPhotoForArtist:song.artist callback:^(UIImage *artistPhoto) {
            song.artistImage = UIImagePNGRepresentation(artistPhoto);
            [CoreDataHelper.get saveContext];
        }];
    }
}

+(NSInteger)tabCount {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Song" inManagedObjectContext:CoreDataHelper.get.managedObjectContext]];
    NSError *err;
    NSUInteger count = [CoreDataHelper.get.managedObjectContext countForFetchRequest:request error:&err];
    return count;
}

+(NSInteger)favoritesCount {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Song" inManagedObjectContext:CoreDataHelper.get.managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"self.isFavorite == %@",@(YES)]];
    NSError *err;
    NSUInteger count = [CoreDataHelper.get.managedObjectContext countForFetchRequest:fetchRequest error:&err];
    return count;
}

+(NSString *)favoriteBand {
    NSArray *history = [self history];
    NSArray *unique = [history valueForKeyPath:@"artist"];
    NSMutableArray *countsArray = [NSMutableArray arrayWithCapacity:unique.count];
    for (NSString *artist in unique) {
        NSArray *filtered = [history filteredArrayUsingPredicate:
                             [NSPredicate predicateWithFormat:@"artist = %@", artist]];
        [countsArray addObject:@{@"artist":artist, @"count":@(filtered.count)}];
    }
    NSArray *result = [countsArray sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"count" ascending:NO]]];
    return [result.firstObject objectForKey:@"artist"];
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

