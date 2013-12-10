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

+(void)getPhotoForArtist:(NSString *)artist callback:(void(^)(UIImage *artistPhoto))successCallback;
+(UIImage *)cachedImageForArtist:(NSString *)artist;
+(void)addArtistToCache:(Song *)song;
+(void)reportPurchase;

@end
