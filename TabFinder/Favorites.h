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

+(Song *)addToDatabase:(NSDictionary *)version withContent:(NSString *)tab;
+(void)addToFavorites:(Song *)song;
+(void)removeFromFavorites:(Song *)song;
+(NSArray *)favorites;
+(void)convertOldFavorites;

@end
