//
//  NavigationController.m
//  TabFinder
//
//  Created by Luiz Gustavo Faria on 6/07/13.
//  Copyright (c) 2013 PDM Systems. All rights reserved.
//

#import "NavigationController.h"
#import <QuartzCore/QuartzCore.h>

@interface NavigationController ()

@end

@implementation NavigationController

- (void)viewDidLoad
{
    [super viewDidLoad];

//    [self.navigationBar setBackgroundImage:[UIImage imageWithColor:[UIColor whiteColor] cornerRadius:2] forBarMetrics:UIBarMetricsDefault];
    [self.navigationBar setBackgroundImage:[UIImage navBarImage] forBarMetrics:UIBarMetricsDefault];
    [self.navigationBar setTitleTextAttributes:@{UITextAttributeTextColor: [UIColor colorWithWhite:0.4 alpha:1],
                UITextAttributeTextShadowColor: [UIColor clearColor],
                           UITextAttributeFont: [UIFont fontWithName:@"HelveticaNeue-Medium" size:17]}];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.navigationBar.layer.shadowOffset = CGSizeMake(0, 1);
        self.navigationBar.layer.shadowColor = [UIColor colorWithWhite:0.4 alpha:0.7].CGColor;
        self.navigationBar.layer.masksToBounds = NO;
    }
    
    NSMutableDictionary * titleTextAttributes = [NSMutableDictionary dictionary];

    [titleTextAttributes setValue:[NSValue valueWithUIOffset:UIOffsetMake(0, 0)] forKey:UITextAttributeTextShadowOffset];
    [titleTextAttributes setValue:[UIColor defaultColor] forKey:UITextAttributeTextColor];
    [titleTextAttributes setValue:[UIFont fontWithName:@"HelveticaNeue" size:15] forKey:UITextAttributeFont];
    
    [[UIBarButtonItem appearanceWhenContainedIn:[NavigationController class], nil] setTitleTextAttributes:titleTextAttributes forState:UIControlStateNormal];
    [[UIBarButtonItem appearanceWhenContainedIn:[NavigationController class], nil] setTitleTextAttributes:titleTextAttributes forState:UIControlStateHighlighted];
    
    NSMutableDictionary *disabledButtonDictionary = [titleTextAttributes mutableCopy];
    [disabledButtonDictionary setValue:[UIColor lightGrayColor] forKey:UITextAttributeTextColor];
    [[UIBarButtonItem appearanceWhenContainedIn:[NavigationController class], nil] setTitleTextAttributes:disabledButtonDictionary forState:UIControlStateDisabled];
    
    [UIBarButtonItem configureFlatButtonsWithColor:[UIColor colorWithWhite:1 alpha:1]
                                  highlightedColor:[UIColor colorWithWhite:1 alpha:1]
                                      cornerRadius:3];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    UIButton *backButton = [[NSBundle mainBundle] loadNibNamed:@"BackButton" owner:self options:nil].lastObject;

    [backButton setTitleColor:[UIColor defaultColor] forState:UIControlStateNormal];
    [backButton setTitleColor:[UIColor defaultColor] forState:UIControlStateSelected];
    [backButton setTitle:self.visibleViewController.navigationItem.title forState:UIControlStateNormal];
    [backButton sizeToFit];

        [backButton addTarget:self action:@selector(didPressBackButton) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
        buttonItem.style = UIBarButtonItemStylePlain;
    viewController.navigationItem.leftBarButtonItem = buttonItem;
        [super pushViewController:viewController animated:YES];
}

-(void)didPressBackButton {
    [self popViewControllerAnimated:YES];
}

@end
