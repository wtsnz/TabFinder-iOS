//
//  FavoritesAlertView.m
//  TabFinder
//
//  Created by Luiz Gustavo Faria on 11/07/13.
//  Copyright (c) 2013 PDM Systems. All rights reserved.
//

#import "FavoritesAlertView.h"
#import "SongCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation FavoritesAlertView

+(void)showFavoritesAlertForSong:(Song *)song inView:(UIWebView *)view {
    UIView *alert = [[NSBundle mainBundle] loadNibNamed:song.isFavorite.boolValue ? @"AddedToFavorites": @"RemovedFromFavorites" owner:self options:nil].lastObject;
    alert.layer.cornerRadius = 5;
    CGFloat xCenter;
    if (view.frame.size.width == 320) xCenter = 160;
    else xCenter = view.frame.size.width - alert.frame.size.width/2 - 10;
    alert.center = CGPointMake(xCenter, alert.frame.size.height/2 + 25);
    [view addSubview:alert];
    [UIView animateWithDuration:0.3 delay:2 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        alert.alpha = 0;
    } completion:^(BOOL finished) {
        [alert removeFromSuperview];
    }];
}

@end
