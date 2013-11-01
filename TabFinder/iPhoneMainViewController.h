//
//  iPhoneMainViewController.h
//  TabFinder
//
//  Created by Luiz Gustavo Faria on 11/07/13.
//  Copyright (c) 2013 PDM Systems. All rights reserved.
//

#import "MainViewController.h"
#import "TabHeaderView.h"
#import <iAd/iAd.h>
#import "Favorites.h"
#import "Engine.h"

@interface iPhoneMainViewController : MainViewController <ADBannerViewDelegate>

@property (weak, nonatomic) IBOutlet TabHeaderView *tabHeaderView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bannerHeight;
@property (weak, nonatomic) IBOutlet ADBannerView *bannerView;

@end
