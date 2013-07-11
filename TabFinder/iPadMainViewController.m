//
//  iPadMainViewController.m
//  TabFinder
//
//  Created by Luiz Gustavo Faria on 11/07/13.
//  Copyright (c) 2013 PDM Systems. All rights reserved.
//

#import "iPadMainViewController.h"

@interface iPadMainViewController ()

@property (strong, nonatomic) UIPopoverController *popoverReference;

@end

@implementation iPadMainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

-(void)loadFavoritesSong {
    [super loadFavoritesSong];
    [_popoverReference dismissPopoverAnimated:YES];
}

-(void)loadInternetSong {
    [super loadInternetSong];
    [_popoverReference dismissPopoverAnimated:YES];
}

-(IBAction)didPressFavoritesButton:(id)sender {
    [super didPressFavoritesButton:sender];
    if ([FavoritesViewController currentInstance]) {
        [[FavoritesViewController currentInstance] reloadFavorites];
        [[FavoritesViewController currentInstance].tableView reloadData];
    }
}

-(void)splitViewController:(UISplitViewController *)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem {
    self.navigationItem.leftBarButtonItem = nil;
    _popoverReference = nil;
}

-(void)splitViewController:(UISplitViewController *)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)pc {
    barButtonItem.title = @"Search";
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    _popoverReference = pc;
}


@end
