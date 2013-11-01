//
//  SongTableViewController.h
//  TabFinder
//
//  Created by Luiz Gustavo Faria on 1/11/13.
//  Copyright (c) 2013 PDM Systems. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "AppDelegate.h"
#import "SongCell.h"
#import "Song.h"

@interface SongTableViewController : UITableViewController <UISearchDisplayDelegate, NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSFetchedResultsController *searchFetchedResultsController;
@property (strong, nonatomic) Song *selectedSong;

-(NSFetchedResultsController *)fetchedResultsControllerForTableView:(UITableView *)tableView;
-(NSFetchedResultsController *)fetchedResultsControllerGetter;
-(NSFetchedResultsController *)searchFetchedResultsControllerGetter;

-(void)movedBetweenDatabases;

@end
