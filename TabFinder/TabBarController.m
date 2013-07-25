//
//  TabBarController.m
//  TabFinder
//
//  Created by Luiz Gustavo Faria on 26/07/13.
//  Copyright (c) 2013 PDM Systems. All rights reserved.
//

#import "TabBarController.h"

@interface TabBarController ()

@end

@implementation TabBarController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tabBar configureFlatTabBarWithColor:[UIColor whiteColor] selectedColor:[UIColor whiteColor]];
    for (UITabBarItem *item in self.tabBar.items) {
        [item setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor colorWithWhite:0.1 alpha:1]} forState:UIControlStateNormal];
        [item setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor colorWithWhite:0.1 alpha:1]} forState:UIControlStateSelected];
    }
    //[[UITabBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor colorWithWhite:0.1 alpha:1]}];
//    [[UITabBarItem appearance] ;
}

@end
