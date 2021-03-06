//
//  AppDelegate.m
//  TabFinder
//
//  Created by Luiz Gustavo Faria on 12/06/13.
//  Copyright (c) 2013 PDM Systems. All rights reserved.
//

#import "AppDelegate.h"
#import "Favorites.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        UISplitViewController *splitVC = (UISplitViewController *)self.window.rootViewController;
        _navigationControllerIpad = splitVC.viewControllers.lastObject;
        _mainViewControllerIpad = _navigationControllerIpad.viewControllers[0];
        splitVC.delegate = _mainViewControllerIpad;
        splitVC.presentsWithGesture = NO;
    }
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor colorWithWhite:0.3 alpha:1]}];
    [[UISearchBar appearance] setBarTintColor:[UIColor colorWithWhite:0.9 alpha:1]];
    [Favorites convertOldFavorites];
    return YES;
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
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
}

@end
