//
//  SearchCell.m
//  TabFinder
//
//  Created by Luiz Gustavo Faria on 12/06/13.
//  Copyright (c) 2013 PDM Systems. All rights reserved.
//

#import "SongCell.h"
#import "Api.h"
#import <QuartzCore/QuartzCore.h>

@interface SongCell ()

@end

@implementation SongCell

-(id)init {
    self = [[NSBundle mainBundle] loadNibNamed:@"SongCell" owner:self options:nil].lastObject;
    _artistImageView.layer.cornerRadius = 30;
    _artistImageView.layer.masksToBounds = YES;
    _songLabel.font = [UIFont proximaNovaSemiBoldSize:17];
    _artistLabel.font = [UIFont proximaNovaSemiBoldSize:13];
    _versionsLabel.font = [UIFont proximaNovaSemiBoldSize:12];
    UIView *v = [[UIView alloc] initWithFrame:self.frame];
    v.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
    self.selectedBackgroundView = v;
    return self;
}

-(void)configureWithFavoriteSong:(Song *)song {
    _artistImageView.image = [UIImage imageWithData:song.artistImage];
    _songLabel.text = song.name;
    _artistLabel.text = song.artist;
    _versionsLabel.text = song.shortVersionTitle;
}

-(void)configureWithInternetSong:(NSDictionary *)song {
    _artistName = song.artist;
    _songLabel.text = song.name;
    _artistLabel.text = song.artist;
    _versionsLabel.text = [NSString stringWithFormat:@"%i version%@",song.versions.count,song.versions.count > 1 ? @"s" : @""];
    _artistImageView.image = [Api cachedImageForArtist:song.artist];
    if (_artistImageView.image) return;
    [Api getPhotoForArtist:song.artist callback:^(UIImage *artistPhoto) {
        if ([_artistLabel.text isEqualToString:song.artist]) {
            _artistImageView.image = artistPhoto;
        }
    }];
}

@end
