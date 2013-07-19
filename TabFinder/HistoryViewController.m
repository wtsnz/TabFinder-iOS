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
    _history = [Favorites historyDictionary];
    _historyDictKeys = [_history.allKeys sortedArrayUsingSelector:@selector(localizedStandardCompare:)];
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

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *sectionName = _historyDictKeys[section];
    return [sectionName substringFromIndex:1];
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
        UIView *header = [[UIView alloc] init];
        UILabel *label = [[UILabel alloc] init];
        label.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:13];
        label.textColor = [UIColor defaultColor];
        label.text = [self tableView:tableView titleForHeaderInSection:section];
        label.backgroundColor = [UIColor clearColor];
        header.backgroundColor = tableView.backgroundColor;
        header.alpha = 0.95;
        [label sizeToFit];
        [header addSubview:label];
        [header sizeToFit];
        label.center = CGPointMake(label.center.x + 10, label.center.y + 5);
        return header;
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
