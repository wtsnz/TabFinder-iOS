//
//  SearchCell.m
//  TabFinder
//
//  Created by Luiz Gustavo Faria on 12/06/13.
//  Copyright (c) 2013 PDM Systems. All rights reserved.
//

#import "SongCell.h"
#import "Api.h"

@interface SongCell ()

@end

@implementation SongCell
/*
- (void)awakeFromNib
{
    [super awakeFromNib];
    
    for (NSLayoutConstraint *cellConstraint in self.constraints)
    {
        [self removeConstraint:cellConstraint];
        
        id firstItem = cellConstraint.firstItem == self ? self.contentView : cellConstraint.firstItem;
        id seccondItem = cellConstraint.secondItem == self ? self.contentView : cellConstraint.secondItem;
        
        NSLayoutConstraint* contentViewConstraint = [NSLayoutConstraint constraintWithItem:firstItem
                                                                                 attribute:cellConstraint.firstAttribute
                                                                                 relatedBy:cellConstraint.relation
                                                                                    toItem:seccondItem
                                                                                 attribute:cellConstraint.secondAttribute
                                                                                multiplier:cellConstraint.multiplier
                                                                                  constant:cellConstraint.constant];
        
        [self.contentView addConstraint:contentViewConstraint];
    }
}
*/
-(id)init {
    self = [[NSBundle mainBundle] loadNibNamed:@"SongCell7" owner:self options:nil].lastObject;
    return self;
}

-(void)configureWithFavoriteSong:(Song *)song {
    _artistImageView.image = [UIImage imageWithData:song.artistImage];
    _songLabel.text = song.name;
    _songLabel.textColor = [UIColor colorWithWhite:0.3 alpha:1];
    [self configureArtistLabelWithArtist:song.artist versionInfo:song.shortVersionTitle];
}

-(void)configureArtistLabelWithArtist:(NSString *)artist versionInfo:(NSString *)versionInfo {
    NSMutableAttributedString *artistName = [[NSMutableAttributedString alloc] initWithString:artist attributes:@{NSForegroundColorAttributeName: [UIColor colorWithWhite:0.5 alpha:1], NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:13]}];
    NSAttributedString *version = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"  %@",versionInfo] attributes:@{NSForegroundColorAttributeName:self.tintColor,NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:11]}];
    [artistName appendAttributedString:version];
    [_artistLabel setAttributedText:artistName];
}

-(void)configureWithInternetSong:(NSDictionary *)song {
    _artistName = song.artist;
    _artistImageView.clipsToBounds = YES;
    _songLabel.text = song.name;
    _artistImageView.image = [Api artistPhotoForArtist:song.artist];
    [self configureArtistLabelWithArtist:song.artist versionInfo:[NSString stringWithFormat:@"%i version%@",song.versions.count,song.versions.count > 1 ? @"s" : @""]];
    if (_artistImageView.image == nil) {
        [Api configureImageViewForCell:self];
    }
}

@end
