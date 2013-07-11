//
//  FavoritesAlertView.m
//  TabFinder
//
//  Created by Luiz Gustavo Faria on 11/07/13.
//  Copyright (c) 2013 PDM Systems. All rights reserved.
//

#import "FavoritesAlertView.h"
#import "SongCell.h"

@implementation FavoritesAlertView

+(void)showFavoritesAlertForSong:(Song *)song inView:(UIView *)view {
    FavoritesAlertView *alertView = [[FavoritesAlertView alloc] init];
    alertView.messageLabel.text =  song.isFavorite.boolValue ? @"Added to your favorites:" : @"Removed from your favorites:";
    SongCell *cell = [[SongCell alloc] init];
    [cell configureWithFavoriteSong:song];
    [cell setAccessoryType:UITableViewCellAccessoryNone];
    cell.center = CGPointMake(cell.center.x, cell.center.y + 30);
    [alertView addSubview:cell];
    alertView.center = CGPointMake(view.frame.size.width - alertView.frame.size.width/2 - 10, alertView.frame.size.height/2 + 10);
    [view addSubview:alertView];
    [UIView animateWithDuration:0.3 delay:2 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        alertView.alpha = 0;
    } completion:^(BOOL finished) {
        [alertView removeFromSuperview];
    }];
}

-(id)init {
    self = [[NSBundle mainBundle] loadNibNamed:@"FavoritesAlertView" owner:nil options:nil].lastObject;
    [self addShadows];
    _messageLabel.textColor = [UIColor defaultColor];
    return self;
}

@end
