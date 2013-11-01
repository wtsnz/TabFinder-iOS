//
//  AppDelegate.h
//  TabFinder
//
//  Created by Luiz Gustavo Faria on 12/06/13.
//  Copyright (c) 2013 PDM Systems. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Favorites.h"
#import "iRate.h"
#import "InAppPurchaseManager.h"
#import "Engine.h"
#import "MainViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) MainViewController *mainViewControllerIpad;
@property (strong, nonatomic) UINavigationController *navigationControllerIpad;
@property (strong, nonatomic) UISplitViewController *splitVC;

+(AppDelegate *)instance;

@end
