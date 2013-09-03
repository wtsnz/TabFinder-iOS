//
//  HistoryViewController.m
//  TabFinder
//
//  Created by Luiz Gustavo Faria on 12/07/13.
//  Copyright (c) 2013 PDM Systems. All rights reserved.
//

#import "HistoryViewController.h"
#import "Song.h"
#import "SongCell.h"
#import "MainViewController.h"
#import "AppDelegate.h"
#import "Favorites.h"
#import "CoreDataHelper.h"

@interface HistoryViewController ()

@property NSDictionary *history;
@property NSArray *historyDictKeys;

@end

@implementation HistoryViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _history = [NSDictionary dictionary];
    _historyDictKeys = [NSArray array];
}

-(void)viewWillAppear:(BOOL)animated {
    [self loadHistory];
}

-(void)loadHistory {
    _history = [Favorites historyDictionary];
    _historyDictKeys = [_history.allKeys sortedArrayUsingSelector:@selector(localizedStandardCompare:)];
    [self.tableView reloadData];
    [self performSelectorInBackground:@selector(performImageCheck) withObject:nil];
}

-(void)performImageCheck {
    [Favorites performImageCheck];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _history.allKeys.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *songs = _history[_historyDictKeys[section]];
    return songs.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SongCell";
    SongCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) cell = [[SongCell alloc] init];
    NSArray *songs = _history[_historyDictKeys[indexPath.section]];
    [cell configureWithFavoriteSong:songs[indexPath.row]];
    return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.backgroundColor = [UIColor colorWithWhite:indexPath.row % 2 == 1 ? 0.98 : 1 alpha:1];
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *sectionName = _historyDictKeys[section];
    return [sectionName substringFromIndex:1];
}

#pragma mark - Table view delegate


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        MainViewController *mainVC = ((AppDelegate *)[UIApplication sharedApplication].delegate).mainViewControllerIpad;
        NSArray *songs = _history[_historyDictKeys[indexPath.section]];
        mainVC.currentSong = songs[indexPath.row];
        [mainVC loadFavoritesSong];
    }
    else {
        [self performSegueWithIdentifier:@"ShowTabSegue" sender:self];
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    MainViewController *vc = segue.destinationViewController;
    NSArray *songs = _history[_historyDictKeys[self.tableView.indexPathForSelectedRow.section]];
    Song *song = songs[self.tableView.indexPathForSelectedRow.row];
    vc.currentSong = song;
}


@end
