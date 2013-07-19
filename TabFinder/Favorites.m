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
    } else {
        [Api downloadArtistImageOnBackgroundForSong:song];
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

+(void)performImageCheck {
    for (Song *song in [self history]) {
        if (!song.artistImage) [Api downloadArtistImageOnBackgroundForSong:song];
    }
}

+(NSArray *)favorites {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Song" inManagedObjectContext:CoreDataHelper.get.managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"self.isFavorite == %@",@(YES)]];
    NSError *error;
    return [[CoreDataHelper.get.managedObjectContext executeFetchRequest:fetchRequest error:&error] sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]]];
}

+(NSDictionary *)historyDictionary {
    NSMutableDictionary *historyDict = [NSMutableDictionary dictionary];
    NSDate *today = [NSDate date];
    NSDate *yesterday = [NSDate dateWithTimeIntervalSinceNow:-24*60*60];
    for (Song *song in [self history]) {
        NSDate *baseDate = song.dateOfCreation;
        if (baseDate == nil) baseDate = [NSDate dateWithTimeIntervalSinceNow:-24*60*60*31];
        NSCalendar* calendar = [NSCalendar currentCalendar];
        NSDateComponents* comps = [calendar components:(NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit) fromDate:baseDate];
        NSDate* theMidnightHour = [calendar dateFromComponents:comps];
        NSTimeInterval intervalFromToday = [today timeIntervalSinceDate:theMidnightHour];
        if (intervalFromToday >= 0 && intervalFromToday < 60*60*24) {
            if (!historyDict[@"0Today"]) historyDict[@"0Today"] = [[NSMutableArray alloc] init];
            [historyDict[@"0Today"] addObject:song];
            continue;
        }
        NSTimeInterval intervalFromYesterday = [yesterday timeIntervalSinceDate:theMidnightHour];
        if (intervalFromToday >= 0 && intervalFromYesterday < 60*60*24) {
            if (!historyDict[@"1Yesterday"]) historyDict[@"1Yesterday"] = [[NSMutableArray alloc] init];
            [historyDict[@"1Yesterday"] addObject:song];
            continue;
        }
        if (abs([baseDate timeIntervalSinceNow]) < 60*60*24*7) {
            if (!historyDict[@"2Last 7 days"]) historyDict[@"2Last 7 days"] = [[NSMutableArray alloc] init];
            [historyDict[@"2Last 7 days"] addObject:song];
            continue;
        }
        if (abs([baseDate timeIntervalSinceNow]) < 60*60*24*30) {
            if (!historyDict[@"3Last 30 days"]) historyDict[@"3Last 30 days"] = [[NSMutableArray alloc] init];
            [historyDict[@"3Last 30 days"] addObject:song];
            continue;
        }
        if (!historyDict[@"4Older than 30 days"]) historyDict[@"4Older than 30 days"] = [[NSMutableArray alloc] init];
        [historyDict[@"4Older than 30 days"] addObject:song];
        continue;
    }
    return historyDict;
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

