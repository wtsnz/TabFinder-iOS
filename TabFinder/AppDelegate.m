//
//  AppDelegate.m
//  TabFinder
//
//  Created by Luiz Gustavo Faria on 12/06/13.
//  Copyright (c) 2013 PDM Systems. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSFontAttributeName: [UIFont proximaNovaSemiBoldSize:19], NSForegroundColorAttributeName: [UIColor whiteColor]}];
    [[UIBarButtonItem appearance] setTitleTextAttributes:@{NSFontAttributeName: [UIFont proximaNovaSemiBoldSize:15]} forState:UIControlStateNormal];
    [[UINavigationBar appearance] setBarTintColor:[UIColor defaultColor]];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        _splitVC = (UISplitViewController *)self.window.rootViewController;
        _navigationControllerIpad = _splitVC.viewControllers.lastObject;
        _mainViewControllerIpad = _navigationControllerIpad.viewControllers[0];
        _splitVC.delegate = _mainViewControllerIpad;
        _splitVC.presentsWithGesture = NO;
    } else {
        [Engine.instance attachToWindow:self.window];
    }
    application.idleTimerDisabled = YES;
    [Favorites convertOldFavorites];
    [iRate sharedInstance].promptAtLaunch = NO;
    [iRate sharedInstance].appStoreID = 551889599;
    [iRate sharedInstance].eventsUntilPrompt = 9999;
    [[InAppPurchaseManager sharedInstance] loadStore];
    return YES;
}

+(AppDelegate *)instance {
    return (AppDelegate *)[UIApplication sharedApplication].delegate;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    if (![InAppPurchaseManager sharedInstance].userHasFullApp) {
      [[InAppPurchaseManager sharedInstance] loadStore];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
}

@end
