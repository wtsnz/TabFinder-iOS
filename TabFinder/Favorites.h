//
//  Favorites.h
//  TabFinder
//
//  Created by Luiz Gustavo Faria on 13/05/13.
//  Copyright (c) 2013 PDM Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Song.h"
#import "OldFavorites.h"

@interface Favorites : NSObject

+(Song *)findByUgid:(NSString *)ugid;
+(void)addToFavorites:(Song *)song;
+(void)removeFromFavorites:(Song *)song;
+(NSArray *)favoritesSortedBy:(NSString *)sorting;
+(void)convertOldFavorites;
+(NSArray *)history;
+(void)performImageCheck;
+(NSDictionary *)historyDictionary;
+(void)clearHistoryByDays:(NSInteger)numberOfDays;
+(NSInteger)tabCount;
+(NSInteger)favoritesCount;
+(NSString *)favoriteBand;
+(void)clearFavorites;

@end
