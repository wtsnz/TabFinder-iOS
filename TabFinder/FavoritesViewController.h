//
//  FavoritesViewController.h
//  TabFinder
//
//  Created by Luiz Gustavo Faria on 24/06/13.
//  Copyright (c) 2013 PDM Systems. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "SongTableViewController.h"
#import "Favorites.h"
#import <QuartzCore/QuartzCore.h>
#import "AlertPopupView.h"
#import "CoreDataHelper.h"

@interface FavoritesViewController : SongTableViewController

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSFetchedResultsController *searchFetchedResultsController;

@end
