//
//  Api.m
//  TabFinder
//
//  Created by Luiz Gustavo Faria on 5/05/13.
//  Copyright (c) 2013 PDM Systems. All rights reserved.
//

#import "Api.h"
#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"
#import "XMLReader.h"
#import "CoreDataHelper.h"

@implementation Api

#define BASEURL [NSURL URLWithString:@"http://app.ultimate-guitar.com"]

+(void)tabSearch:(NSString *)title page:(NSInteger)page success:(void (^)(id))successCallback failure:(void (^)())failureCallback {
    NSString *searchTerm = [title stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    NSString *url = [NSString stringWithFormat:@"search.php?search_type=title&value=%@&iphone=1&page=%i",searchTerm,page];
//    url = [url stringByAppendingString:@"&type%5B%5D=200&type%5B%5D=300"];
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:BASEURL];
    NSMutableURLRequest *request = [httpClient requestWithMethod:@"GET" path:url parameters:nil];
    [request setTimeoutInterval:8];
    //set up operation
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [httpClient registerHTTPOperationClass:[AFHTTPRequestOperation class]];
    //setup callbacks
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError *error;
        id parsedResponse = [[XMLReader dictionaryForXMLData:responseObject error:&error] objectForKey:@"results"];
        if (error) {
            NSLog(@"%@",error.localizedDescription);
        } else {
            if (successCallback) {
                successCallback(parsedResponse);
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failureCallback) {
            failureCallback();
        }
    }];
    [operation start];
}

+(void)fetchTabContentForVersion:(NSDictionary *)version success:(void(^)(NSString *html))successCallback failure:(void (^)())failureCallback {
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:version.url];
    [request setHTTPMethod:@"POST"];
    NSString *postRequestBody = [NSString stringWithFormat:@"artist=%@&title=%@&version=%@&type1=%@&type2=%@",version.artist,version.name,version.versionNumber,version.type,version.type2];
    [request setHTTPBody:[[postRequestBody stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] dataUsingEncoding:NSUTF8StringEncoding]];

    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"http://tabfinder.herokuapp.com"]];
    [request setTimeoutInterval:60];
    //set up operation
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [httpClient registerHTTPOperationClass:[AFHTTPRequestOperation class]];
    //setup callbacks
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, NSData *responseObject) {
        NSError *error;
        if (error) {
            NSLog(@"%@",error.localizedDescription);
        } else {
            if (successCallback) {
                successCallback([[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failureCallback) {
            failureCallback();
        }
    }];
    [operation start];

}

static NSMutableDictionary *_artistPhotosCache;
static NSMutableDictionary *_artistNameFixes;

+(void)addArtistToCache:(Song *)song {
    if (!_artistPhotosCache) _artistPhotosCache = [NSMutableDictionary dictionary];
    _artistPhotosCache[song.artist] = [UIImage imageWithData:song.artistImage];
}

+(UIImage *)cachedImageForArtist:(NSString *)artist {
    NSString *finalArtist = _artistNameFixes[artist] ? _artistNameFixes[artist] : artist;
    return _artistPhotosCache[finalArtist];
}

+(void)getPhotoForArtist:(NSString *)artist callback:(void(^)(UIImage *artistPhoto))successCallback {
    if (!_artistPhotosCache) _artistPhotosCache = [NSMutableDictionary dictionary];
    if (!_artistNameFixes) _artistNameFixes = [NSMutableDictionary dictionary];
    NSString *finalArtist = _artistNameFixes[artist] ? _artistNameFixes[artist] : artist;
    if (_artistPhotosCache[finalArtist]) {
        successCallback(_artistPhotosCache[finalArtist]);
        return;
    }
    AFHTTPRequestOperation *operation = [self getArtistOperationFor:finalArtist];
    //setup callbacks
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError *error;
        NSDictionary *parsedResponse = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:&error];
        if (error) {
            NSLog(@"%@",error.localizedDescription);
        } else {
            UIImage *unknownArtistImage = [UIImage imageNamed:@"unknown_artist"];
            NSDictionary *dict = [parsedResponse valueForKeyPath:@"artist"];
            NSString *bio = [[dict[@"bio"] objectForKey:@"content"] lowercaseString];
            if (bio && [bio rangeOfString:[NSString stringWithFormat:@"music/the+%@\"",[artist.lowercaseString stringByReplacingOccurrencesOfString:@" " withString:@"+"]]].location != NSNotFound && [artist rangeOfString:@"The "].location != 0) {
                if (!_artistNameFixes[artist]) _artistNameFixes[artist] = [@"The " stringByAppendingString:artist];
                [self getPhotoForArtist:_artistNameFixes[artist] callback:successCallback];
                return;
            }
            NSArray *images = [dict valueForKeyPath:@"image"];
            NSString *photoURL = [[images objectAtIndex:3] valueForKeyPath:@"#text"];
            if (photoURL != nil && photoURL.length > 10) {
                NSURL *finalUrl = [NSURL URLWithString:photoURL];
                UIImageView *dummyImageView = [[UIImageView alloc] init];
                [dummyImageView setImageWithURLRequest:[NSURLRequest requestWithURL:finalUrl] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                    [_artistPhotosCache setObject:UIImagePNGRepresentation(image).length > 0 ? image : unknownArtistImage forKey:finalArtist];
                    successCallback(_artistPhotosCache[finalArtist]);
                } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                    [_artistPhotosCache setObject:unknownArtistImage forKey:finalArtist];
                    successCallback(_artistPhotosCache[finalArtist]);
                }];
            } else {
                [_artistPhotosCache setObject:unknownArtistImage forKey:finalArtist];
                successCallback(_artistPhotosCache[finalArtist]);
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) { }];
    [operation start];
}

+(AFHTTPRequestOperation *)getArtistOperationFor:(NSString *)artist {
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"http://ws.audioscrobbler.com/2.0"]];
    NSMutableURLRequest *request = [httpClient requestWithMethod:@"GET" path:[[NSString stringWithFormat:@"?method=artist.getinfo&artist=%@&api_key=e4b978b3a47b0ffa063df03eea94fb1b&format=json",artist] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] parameters:nil];
    [request setTimeoutInterval:8];
    //set up operation
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [httpClient registerHTTPOperationClass:[AFHTTPRequestOperation class]];
    return operation;
}

-(void)requestWithURL:(NSString *)relativeURL method:(NSString *)method args:(NSDictionary *)args successCallback:(void(^)(id parsedResponse))successCallback failure:(void(^)())failureCallback {
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:BASEURL];
    NSMutableURLRequest *request = [httpClient requestWithMethod:method path:relativeURL parameters:args];
    [request setTimeoutInterval:8];
    //set up operation
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [httpClient registerHTTPOperationClass:[AFHTTPRequestOperation class]];
    //setup callbacks
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failureCallback) {
            failureCallback();
        }
    }];
    [operation start];
}

@end
