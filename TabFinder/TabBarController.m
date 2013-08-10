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
    [self.tabBar setSelectedImageTintColor:[UIColor clearColor]];
    [[UITabBarItem appearance] setTitleTextAttributes:@{UITextAttributeTextColor: [UIColor defaultColor], UITextAttributeFont: [UIFont fontWithName:@"HelveticaNeue-Light" size:11]} forState:UIControlStateSelected];
    [[UITabBarItem appearance] setTitleTextAttributes:@{UITextAttributeTextColor: [UIColor colorWithWhite:0.4 alpha:1], UITextAttributeFont: [UIFont fontWithName:@"HelveticaNeue-Light" size:11]} forState:UIControlStateNormal];
    for (UITabBarItem *item in self.tabBar.items) {
        NSString *active = [NSString stringWithFormat:@"tabitem_%i_active",[self.tabBar.items indexOfObject:item]];
        NSString *inactive = [NSString stringWithFormat:@"tabitem_%i_inactive",[self.tabBar.items indexOfObject:item]];
        [item setFinishedSelectedImage:[UIImage imageNamed:active] withFinishedUnselectedImage:[UIImage imageNamed:inactive]];
    }
}

@end
