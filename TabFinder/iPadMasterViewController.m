//
//  iPadMasterViewController.m
//  TabFinder
//
//  Created by Luiz Gustavo Faria on 10/07/13.
//  Copyright (c) 2013 PDM Systems. All rights reserved.
//

#import "iPadMasterViewController.h"
#import "SearchViewController.h"
#import "FavoritesViewController.h"

@interface iPadMasterViewController ()

@property SearchViewController *searchVC;
@property FavoritesViewController *favoritesVC;

@end

@implementation iPadMasterViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"iPad" bundle:nil];
    _searchVC = [storyboard instantiateViewControllerWithIdentifier:@"SearchViewController"];
    _favoritesVC = [storyboard instantiateViewControllerWithIdentifier:@"FavoritesViewController"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)changedSegment:(id)sender {
    UISegmentedControl *segment = (UISegmentedControl *)sender;
    if (segment.selectedSegmentIndex == 0) {
    } else {
        [_searchVC.view removeFromSuperview];
        [self.view addSubview:_favoritesVC.view];
    }
}

@end
