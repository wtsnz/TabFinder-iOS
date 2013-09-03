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

+(void)fetchTop50success:(void (^)(id))successCallback failure:(void (^)())failureCallback {
    NSString *url = @"api/top50";
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:BASE_URL];
    NSMutableURLRequest *request = [httpClient requestWithMethod:@"GET" path:url parameters:nil];
    [request setTimeoutInterval:20];
    //set up operation
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [httpClient registerHTTPOperationClass:[AFHTTPRequestOperation class]];
    //setup callbacks
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError *error;
        id parsedResponse = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:&error];
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

static NSMutableDictionary *_artistPhotos;

+(void)configureImageViewForCell:(SongCell *)cell {
    NSString *artist = cell.artistName;
    UIImageView *imageView = cell.artistImageView;
    if (!_artistPhotos) _artistPhotos = [NSMutableDictionary dictionary];
    if (_artistPhotos[artist]) {
        [imageView setImage:_artistPhotos[artist]];
    } else {
        [imageView setImage:nil];
        UIImage *unknown_artist = [UIImage imageNamed:@"unknown_artist"];
        AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"http://ws.audioscrobbler.com/2.0"]];
        NSString *beatlesSafe = [artist isEqualToString:@"Beatles"] ? @"the beatles" : artist;
        NSMutableURLRequest *request = [httpClient requestWithMethod:@"GET" path:[[NSString stringWithFormat:@"?method=artist.getinfo&artist=%@&api_key=e4b978b3a47b0ffa063df03eea94fb1b&format=json",beatlesSafe] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] parameters:nil];
        [request setTimeoutInterval:8];
        //set up operation
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        [httpClient registerHTTPOperationClass:[AFHTTPRequestOperation class]];
        //setup callbacks
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSError *error;
            NSDictionary *parsedResponse = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:&error];
            if (error) {
                NSLog(@"%@",error.localizedDescription);
            } else {
                NSDictionary *dict = [parsedResponse valueForKeyPath:@"artist"];
                NSArray *images = [dict valueForKeyPath:@"image"];
                NSString *photoURL = [[images objectAtIndex:2] valueForKeyPath:@"#text"];
                if (photoURL != nil && photoURL.length > 10) {
                    NSURL *finalUrl = [NSURL URLWithString:photoURL];
                    [imageView setImageWithURLRequest:[NSURLRequest requestWithURL:finalUrl] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                        [_artistPhotos setObject:UIImagePNGRepresentation(image).length > 0 ? image : unknown_artist forKey:artist];
                        [self configureImageViewForCell:cell];
                    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                        [_artistPhotos setObject:unknown_artist forKey:artist];
                        [self configureImageViewForCell:cell];
                    }];
                } else {
                    [_artistPhotos setObject:unknown_artist forKey:artist];
                    [self configureImageViewForCell:cell];
                }
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) { }];
        [operation start];
    }
}

+(UIImage *)artistPhotoForArtist:(NSString *)artist {
    if (!_artistPhotos) _artistPhotos = [NSMutableDictionary dictionary];
    return _artistPhotos[artist];
}

+(void)downloadArtistImageOnBackgroundForSong:(Song *)song {
    NSString *artist = song.artist;
    UIImageView *imageView = [[UIImageView alloc] init];
    UIImage *unknown_artist = [UIImage imageNamed:@"unknown_artist"];
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"http://ws.audioscrobbler.com/2.0"]];
    NSString *beatlesSafe = [artist isEqualToString:@"Beatles"] ? @"the beatles" : artist;
    NSMutableURLRequest *request = [httpClient requestWithMethod:@"GET" path:[[NSString stringWithFormat:@"?method=artist.getinfo&artist=%@&api_key=e4b978b3a47b0ffa063df03eea94fb1b&format=json",beatlesSafe] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] parameters:nil];
    [request setTimeoutInterval:8];
    //set up operation
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [httpClient registerHTTPOperationClass:[AFHTTPRequestOperation class]];
    //setup callbacks
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError *error;
        NSDictionary *parsedResponse = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:&error];
        if (error) {
            NSLog(@"%@",error.localizedDescription);
        } else {
            NSDictionary *dict = [parsedResponse valueForKeyPath:@"artist"];
            NSArray *images = [dict valueForKeyPath:@"image"];
            NSString *photoURL = [[images objectAtIndex:2] valueForKeyPath:@"#text"];
            if (photoURL != nil && photoURL.length > 10) {
                NSURL *finalUrl = [NSURL URLWithString:photoURL];
                [imageView setImageWithURLRequest:[NSURLRequest requestWithURL:finalUrl] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                    [_artistPhotos setObject:UIImagePNGRepresentation(image).length > 0 ? image : unknown_artist forKey:artist];
                    song.artistImage = UIImagePNGRepresentation([self artistPhotoForArtist:artist]);
                    [CoreDataHelper.get saveContext];
                } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                    [_artistPhotos setObject:unknown_artist forKey:artist];
                    song.artistImage = UIImagePNGRepresentation([self artistPhotoForArtist:artist]);
                    [CoreDataHelper.get saveContext];
                }];
            } else {
                [_artistPhotos setObject:unknown_artist forKey:artist];
                song.artistImage = UIImagePNGRepresentation([self artistPhotoForArtist:artist]);
                [CoreDataHelper.get saveContext];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) { }];
    [operation start];
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
