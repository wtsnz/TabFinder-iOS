//
//  Song.m
//  TabFinder
//
//  Created by Luiz Gustavo Faria on 14/05/13.
//  Copyright (c) 2013 PDM Systems. All rights reserved.
//

#import "Song.h"
#import "FavoritesViewController.h"
#import "CoreDataHelper.h"
#import "Api.h"

@implementation Song

@dynamic artist;
@dynamic name;
@dynamic tab;
@dynamic version;
@dynamic type;
@dynamic ugid;
@dynamic type2;
@dynamic artistImage;
@dynamic isFavorite;
@dynamic dateOfCreation;
@dynamic favoritesSectionTitle;
@dynamic historySectionTitle;

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
    if ([Api cachedImageForArtist:song.artist]) {
        song.artistImage = UIImagePNGRepresentation([Api cachedImageForArtist:song.artist]);
    } else {
        [Api getPhotoForArtist:song.artist callback:^(UIImage *artistPhoto) {
            song.artistImage = UIImagePNGRepresentation(artistPhoto);
            [CoreDataHelper.get saveContext];
        }];
    }
    [CoreDataHelper.get saveContext];
    return song;
}

+(void)removeOlderThanDays:(NSInteger)numberOfDays {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Song" inManagedObjectContext:CoreDataHelper.get.managedObjectContext];
    [fetchRequest setEntity:entity];
    NSDate *date = [NSDate dateWithTimeIntervalSinceNow:-24*60*60*numberOfDays];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"self.dateOfCreation < %@",date]];
    NSError *error;
    NSArray *songs = [CoreDataHelper.get.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    NSInteger batchSize = 200;
    NSInteger i=0;
    for (Song *song in songs) {
        i++;
        if (song.isFavorite.boolValue) {
            song.dateOfCreation = nil;
        } else {
            [CoreDataHelper.get.managedObjectContext deleteObject:song];
        }
        if (i % batchSize == 0) {
            [CoreDataHelper.get saveContext];
        }
    }
    [CoreDataHelper.get saveContext];
    return;
}

-(NSString *)historySectionTitle {
    NSDate *baseDate = self.dateOfCreation;
    NSTimeInterval timeIntervalSinceNow = abs([baseDate timeIntervalSinceNow]);
    if (baseDate == nil) baseDate = [NSDate dateWithTimeIntervalSinceNow:-24*60*60*31];
    if (timeIntervalSinceNow < 60*60*24) {
        return @"Last 24 hours";
    }
    if (timeIntervalSinceNow < 60*60*24*2) {
        return @"Last 48 hours";
    }
    if (timeIntervalSinceNow < 60*60*24*7) {
        return @"Last 7 days";
    }
    if (timeIntervalSinceNow < 60*60*24*30) {
        return @"Last 30 days";
    }
    return @"Older than 30 days";
}

-(NSString *)favoritesSectionTitle {
    if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"favorites_sorting"] isEqualToString:@"artist"]) {
        return [self.artist substringToIndex:1];
    } else {
        return [self.name substringToIndex:1];
    }
}

-(NSString *)fullVersionTitle {
    NSString *type2 = self.type2.length > 0 ? [[self.type2 stringByAppendingString:@" "] capitalizedString] : @"";
    return [NSString stringWithFormat:@"%@%@, Version %@",type2,self.type.capitalizedString,self.version.stringValue];
}

-(NSString *)shortVersionTitle {
    NSString *type2 = self.type2.length > 0 ? [[self.type2 stringByAppendingString:@" "] capitalizedString] : @"";
    return [NSString stringWithFormat:@"%@%@, v. %@",type2,self.type.capitalizedString,self.version.stringValue];
}

@end
