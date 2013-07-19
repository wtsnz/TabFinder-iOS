//
//  Api.h
//  TabFinder
//
//  Created by Luiz Gustavo Faria on 5/05/13.
//  Copyright (c) 2013 PDM Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIImageView+AFNetworking.h"
#import "SongCell.h"

@interface Api : NSObject

+(void)tabSearch:(NSString *)title page:(NSInteger)page success:(void (^)(id))successCallback failure:(void (^)())failureCallback;
+(void)fetchTabContentForVersion:(NSDictionary *)version success:(void(^)(NSString *html))successCallback failure:(void (^)())failureCallback;

+(void)configureImageViewForCell:(SongCell *)cell;
+(UIImage *)artistPhotoForArtist:(NSString *)artist;
+(void)downloadArtistImageOnBackgroundForSong:(Song *)song;

@end
