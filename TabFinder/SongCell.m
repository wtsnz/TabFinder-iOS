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
    _artistImageView.layer.cornerRadius = 25;
    _artistImageView.layer.masksToBounds = YES;
    UIView *bgView = [[UIView alloc] initWithFrame:self.frame];
    bgView.backgroundColor = [UIColor colorWithWhite:0.2 alpha:1];
    self.selectedBackgroundView = bgView;
    return self;
}

-(void)configureWithFavoriteSong:(Song *)song {
    _artistImageView.image = [UIImage imageWithData:song.artistImage];
    _songLabel.text = song.name;
    [self configureArtistLabelWithArtist:song.artist versionInfo:song.shortVersionTitle];
}

-(void)configureArtistLabelWithArtist:(NSString *)artist versionInfo:(NSString *)versionInfo {
    NSMutableAttributedString *artistName = [[NSMutableAttributedString alloc] initWithString:artist attributes:@{NSForegroundColorAttributeName: [UIColor colorWithWhite:0.7 alpha:1], NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:13]}];
    NSAttributedString *version = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"  %@",versionInfo] attributes:@{NSForegroundColorAttributeName:[self tintColor],NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:11]}];
    [artistName appendAttributedString:version];
    [_artistLabel setAttributedText:artistName];
}

-(void)configureWithInternetSong:(NSDictionary *)song {
    _artistName = song.artist;
    _songLabel.text = song.name;
    _artistImageView.image = [Api artistPhotoForArtist:song.artist];
    [self configureArtistLabelWithArtist:song.artist versionInfo:[NSString stringWithFormat:@"%i version%@",song.versions.count,song.versions.count > 1 ? @"s" : @""]];
    if (_artistImageView.image == nil) {
        [Api configureImageViewForCell:self];
    }
}

@end
