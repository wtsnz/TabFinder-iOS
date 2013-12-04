//
//  iPadMainViewController.h
//  TabFinder
//
//  Created by Luiz Gustavo Faria on 11/07/13.
//  Copyright (c) 2013 PDM Systems. All rights reserved.
//

#import "MainViewController.h"
#import "TabHeaderView.h"
#import <iAd/iAd.h>

@interface iPadMainViewController : MainViewController <ADBannerViewDelegate, UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet TabHeaderView *tabHeaderView;
@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;
- (IBAction)didPressChordDictionary:(id)sender;

@end
