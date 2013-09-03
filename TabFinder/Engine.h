//
//  Engine.h
//  TabFinder
//
//  Created by Luiz Gustavo Faria on 2/09/13.
//  Copyright (c) 2013 PDM Systems. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "IIViewDeckController.h"
#import "SearchViewController.h"
#import "FavoritesViewController.h"
#import "HistoryViewController.h"
#import "ChordsTableViewController.h"
#import "MenuViewController.h"

@class MenuViewController;

@interface Engine : NSObject

@property IIViewDeckController *viewDeckController;
@property UINavigationController *navigationController;
@property SearchViewController *searchViewController;
@property HistoryViewController *historyViewController;
@property FavoritesViewController *favoritesViewController;
@property ChordsTableViewController *chordsViewController;
@property MenuViewController *menuViewController;
@property NSArray *vcArray;

-(void)attachToWindow:(UIWindow *)window;
-(void)switchMenuToIndex:(NSInteger)index;
-(void)disableLeftMenu;
-(void)enableLeftMenu;

+(Engine *)instance;
-(void)pushViewController:(UIViewController *)viewController;

@end
