//
//  Engine.m
//  TabFinder
//
//  Created by Luiz Gustavo Faria on 2/09/13.
//  Copyright (c) 2013 PDM Systems. All rights reserved.
//

#import "Engine.h"
#import <QuartzCore/QuartzCore.h>
#import "IIWrapController.h"
#import "IISideController.h"

@interface Engine () <UIGestureRecognizerDelegate, IIViewDeckControllerDelegate>

@end

@implementation Engine

static Engine *_instance;

+(Engine *)instance {
    if (!_instance) {
        _instance = [[Engine alloc] init];
    }
    return _instance;
}

-(id)init {
    self = [super init];
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    _navigationController = [sb instantiateViewControllerWithIdentifier:@"NavigationController"];
    _searchViewController = [sb instantiateViewControllerWithIdentifier:@"SearchViewController"];
    _historyViewController = [sb instantiateViewControllerWithIdentifier:@"HistoryViewController"];
    _chordsViewController = [sb instantiateViewControllerWithIdentifier:@"ChordsViewController"];
    _favoritesViewController = [sb instantiateViewControllerWithIdentifier:@"FavoritesViewController"];
    _menuViewController = [sb instantiateViewControllerWithIdentifier:@"MenuViewController"];
    _viewDeckController = [[IIViewDeckController alloc] initWithCenterViewController:_navigationController leftViewController:[[IISideController alloc] initWithViewController:_menuViewController]];
    _viewDeckController.panningMode = IIViewDeckFullViewPanning;
    _viewDeckController.centerhiddenInteractivity = IIViewDeckCenterHiddenNotUserInteractiveWithTapToClose;
    _viewDeckController.parallaxAmount = 0.2;
    _viewDeckController.panningGestureDelegate = self;
    _viewDeckController.delegate = self;
    _navigationController.viewControllers = @[_searchViewController];
    _vcArray = @[_searchViewController, _favoritesViewController, _historyViewController, _chordsViewController];
    for (UIViewController *vc in _vcArray) {
        vc.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Menu" style:UIBarButtonItemStylePlain target:self action:@selector(showMenu)];
    }
    return self;
}

-(void)viewDeckController:(IIViewDeckController *)viewDeckController didOpenViewSide:(IIViewDeckSide)viewDeckSide animated:(BOOL)animated {
    if (viewDeckSide == IIViewDeckLeftSide)
        [_navigationController.visibleViewController.view endEditing:YES];
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch locationInView:_navigationController.view].x > 150 && _navigationController.visibleViewController == _favoritesViewController) return NO;
    if (_navigationController.visibleViewController == _favoritesViewController && _favoritesViewController.tableView.isEditing) return NO;
    return YES;
}

-(void)attachToWindow:(UIWindow *)window {
    window.rootViewController = _viewDeckController;
}

-(void)switchMenuToIndex:(NSInteger)index {
    [_navigationController setViewControllers:@[_vcArray[index]] animated:YES];
    if (index == 0) {
        [_searchViewController.tableView setContentOffset:CGPointMake(0, 0) animated:NO];
        [_searchViewController.searchBar becomeFirstResponder];
    }
    [_viewDeckController toggleLeftViewAnimated:YES];
}

-(void)showMenu {
    [_viewDeckController toggleLeftViewAnimated:YES];
}

-(void)disableLeftMenu {
    _viewDeckController.panningMode = IIViewDeckNoPanning;
}

-(void)enableLeftMenu {
    _viewDeckController.panningMode = IIViewDeckFullViewPanning;
}

@end
