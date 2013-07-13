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

@interface HistoryViewController ()

@property NSArray *history;

@end

@implementation HistoryViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _history = [Favorites history];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _history.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SongCell";
    SongCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) cell = [[SongCell alloc] init];
    [cell configureWithFavoriteSong:_history[indexPath.row]];
    return cell;
}

#pragma mark - Table view delegate


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        MainViewController *mainVC = ((AppDelegate *)[UIApplication sharedApplication].delegate).mainViewControllerIpad;
        mainVC.currentSong = _history[indexPath.row];
        [mainVC loadFavoritesSong];
    }
    else {
        [self performSegueWithIdentifier:@"ShowTabSegue" sender:self];
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    MainViewController *vc = segue.destinationViewController;
    vc.currentSong = _history[self.tableView.indexPathForSelectedRow.row];
}


@end
