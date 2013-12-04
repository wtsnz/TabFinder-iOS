//
//  NavController.m
//  TabFinder
//
//  Created by Luiz Gustavo Faria on 16/09/13.
//  Copyright (c) 2013 PDM Systems. All rights reserved.
//

#import "NavController.h"

@interface NavController ()

@end

@implementation NavController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

-(id)initWithRootViewController:(UIViewController *)rootViewController {
    self = [super initWithRootViewController:rootViewController];
    self.navigationBar.translucent = NO;
    return self;
}

-(UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
