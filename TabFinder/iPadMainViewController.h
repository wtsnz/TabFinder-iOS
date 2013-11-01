//
//  iPadMainViewController.h
//  TabFinder
//
//  Created by Luiz Gustavo Faria on 11/07/13.
//  Copyright (c) 2013 PDM Systems. All rights reserved.
//

#import "MainViewController.h"
#import "TabHeaderView.h"

@interface iPadMainViewController : MainViewController <ADBannerViewDelegate>

@property (weak, nonatomic) IBOutlet TabHeaderView *tabHeaderView;

@end
