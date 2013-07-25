//
//  FavoritesViewController.m
//  TabFinder
//
//  Created by Luiz Gustavo Faria on 24/06/13.
//  Copyright (c) 2013 PDM Systems. All rights reserved.
//

#import "FavoritesViewController.h"
#import "Favorites.h"
#import "SongCell.h"
#import "Song.h"
#import "MainViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "AppDelegate.h"

@interface FavoritesViewController ()

@property NSArray *favorites;
@property NSArray *filteredFavorites;
@property NSMutableDictionary *sectionedFavorites;
@property NSMutableArray *sortedSections;
@property Song *selectedSong;

@end

@implementation FavoritesViewController

static FavoritesViewController *_currentInstance;

- (void)viewDidLoad
{
    [super viewDidLoad];
    _currentInstance = self;
    [self.searchDisplayController.searchBar makeItFlat];
    _sortedSections = [NSMutableArray array];
    _sectionedFavorites = [NSMutableDictionary dictionary];
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self.navigationItem.rightBarButtonItem removeTitleShadow];
    self.tableView.sectionIndexColor = [UIColor defaultColor];
    self.tableView.sectionIndexMinimumDisplayRowCount = 20;
}

+(FavoritesViewController *)currentInstance {
    return _currentInstance;
}

-(BOOL)showsSectionHeaders {
    return _favorites.count > 15;
}

-(BOOL)showsSearchBar {
    return _favorites.count > 40;
}

-(void)reloadFavorites {
    _favorites = [Favorites favorites];
    _filteredFavorites = @[];
    [_sortedSections removeAllObjects];
    [_sectionedFavorites removeAllObjects];
    for (Song *song in _favorites) {
        NSString *sectionIndex = [song.name substringWithRange:NSMakeRange(0, 1)];
        NSMutableArray *array = _sectionedFavorites[sectionIndex];
        if (!array) {
            array = [[NSMutableArray alloc] initWithObjects:song, nil];
            _sectionedFavorites[sectionIndex] = array;
            [_sortedSections addObject:sectionIndex];
        }
        else {
            [array addObject:song];
        }
    }
    self.tableView.tableHeaderView = [self showsSearchBar] ? self.searchDisplayController.searchBar : nil;
    [self performSelectorInBackground:@selector(performImageCheck) withObject:nil];
}

-(void)performImageCheck {
    [Favorites performImageCheck];
}

-(void)viewWillAppear:(BOOL)animated {
    [self reloadFavorites];
    [self.tableView reloadData];
}

-(NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    if (tableView == self.tableView)
        return _sortedSections;
    else return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return 0;
    } else {
        return [self showsSectionHeaders] ? 22 : 0;
    }
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (tableView != self.tableView) return nil;
    if ([self showsSectionHeaders]) {
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
        label.center = CGPointMake(label.center.x + 10, label.center.y + 3);
        return header;
    } else return nil;
}

-(NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    return index;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (tableView == self.tableView)
        return [self showsSectionHeaders] ? _sortedSections[section] : nil;
    else return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView)
        return _filteredFavorites.count;
    if ([self showsSectionHeaders]) {
        return [_sectionedFavorites[_sortedSections[section]] count];
    } else {
        return _favorites.count;
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableView == self.searchDisplayController.searchResultsTableView) return 1;
    return [self showsSectionHeaders] ? _sectionedFavorites.count : 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SongCell";
    SongCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) cell = [[SongCell alloc] init];
    [cell configureWithFavoriteSong:[self songForTableView:tableView atIndexPath:indexPath]];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return tableView == self.tableView;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Song *song = [self songForTableView:tableView atIndexPath:indexPath];
        NSInteger numberOfSections = [self numberOfSectionsInTableView:tableView];
        [Favorites removeFromFavorites:song];
        [self reloadFavorites];
        if ([self numberOfSectionsInTableView:tableView] != numberOfSections) {
            [self.tableView reloadData];
        } else {
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    }
}

-(Song *)songForTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return _filteredFavorites[indexPath.row];
    }
    if ([self showsSectionHeaders]) {
        return [_sectionedFavorites[_sortedSections[indexPath.section]] objectAtIndex:indexPath.row];
    } else {
        return _favorites[indexPath.row];
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    _selectedSong = [self songForTableView:tableView atIndexPath:indexPath];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        MainViewController *mainVC = ((AppDelegate *)[UIApplication sharedApplication].delegate).mainViewControllerIpad;
        mainVC.currentSong = _selectedSong;
        [mainVC loadFavoritesSong];
    }
    else {
        [self performSegueWithIdentifier:@"ShowTabSegue" sender:self];
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    MainViewController *vc = segue.destinationViewController;
    vc.currentSong = _selectedSong;
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    _filteredFavorites = [_favorites filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.name beginswith[c] %@ || self.artist beginswith[c] %@",searchString, searchString]];
    return YES;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.tableView.rowHeight;
}

@end
