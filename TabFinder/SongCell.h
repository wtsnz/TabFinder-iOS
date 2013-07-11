//
//  SearchCell.h
//  TabFinder
//
//  Created by Luiz Gustavo Faria on 12/06/13.
//  Copyright (c) 2013 PDM Systems. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Song.h"
#import "NSDictionary+Song.h"

@interface SongCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *artistImageView;
@property (weak, nonatomic) IBOutlet UILabel *songLabel;
@property (weak, nonatomic) IBOutlet UILabel *artistLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

-(void)configureWithInternetSong:(NSDictionary *)song;
-(void)configureWithFavoriteSong:(Song *)song;

@end
