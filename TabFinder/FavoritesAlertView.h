//
//  FavoritesAlertView.h
//  TabFinder
//
//  Created by Luiz Gustavo Faria on 11/07/13.
//  Copyright (c) 2013 PDM Systems. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Song.h"

@interface FavoritesAlertView : UIView

+(void)showFavoritesAlertForSong:(Song *)song inView:(UIWebView *)view;

@end
