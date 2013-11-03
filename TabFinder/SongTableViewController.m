//
//  SongTableViewController.m
//  TabFinder
//
//  Created by Luiz Gustavo Faria on 1/11/13.
//  Copyright (c) 2013 PDM Systems. All rights reserved.
//

#import "SongTableViewController.h"

@interface SongTableViewController ()

@end

@implementation SongTableViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    [self setupView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movedBetweenDatabases) name:@"MovedBetweenDatabases" object:nil];
    NSError *error;
	if (![[self fetchedResultsControllerGetter] performFetch:&error]) {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		exit(-1);  // Fail
	}
}

-(NSFetchedResultsController *)fetchedResultsControllerForTableView:(UITableView *)tableView {
    return tableView == self.tableView ? [self fetchedResultsControllerGetter] : [self searchFetchedResultsControllerGetter];
}

-(NSFetchedResultsController *)fetchedResultsControllerGetter {
    return nil;
}

-(NSFetchedResultsController *)searchFetchedResultsControllerGetter {
    return nil;
}

#pragma mark - UITableView Methods

-(NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return [[self fetchedResultsControllerForTableView:tableView] sectionIndexTitles];
}

-(NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    return [[self fetchedResultsControllerForTableView:tableView] sectionForSectionIndexTitle:title atIndex:index];
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [[[self fetchedResultsControllerForTableView:tableView] sections] objectAtIndex:section];
    return [sectionInfo name];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id  sectionInfo = [[[self fetchedResultsControllerForTableView:tableView] sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.backgroundColor = [UIColor colorWithWhite:indexPath.row % 2 == 1 ? 0.98 : 1 alpha:1];
    [(SongCell *)cell configureWithFavoriteSong:[[self fetchedResultsControllerForTableView:tableView] objectAtIndexPath:indexPath]];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[[self fetchedResultsControllerForTableView:tableView] sections] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SongCell";
    SongCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) cell = [[SongCell alloc] init];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    _selectedSong = [[self fetchedResultsControllerForTableView:tableView] objectAtIndexPath:indexPath];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        MainViewController *mainVC = ((AppDelegate *)[UIApplication sharedApplication].delegate).mainViewControllerIpad;
        mainVC.currentSong = [[self fetchedResultsControllerForTableView:tableView] objectAtIndexPath:indexPath];
        [mainVC loadFavoritesSong];
    }
    else {
        [self performSegueWithIdentifier:@"ShowTabSegue" sender:self];
    }

}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    UITableView *tableView = controller == [self fetchedResultsControllerGetter] ? self.tableView : self.searchDisplayController.searchResultsTableView;
    [tableView beginUpdates];
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    NSError *error;
    [[self searchFetchedResultsControllerGetter] performFetch:&error];
    if (error) {
        NSLog(@"error while searching: %@",error.userInfo);
    }
    return YES;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    MainViewController *vc = segue.destinationViewController;
    vc.currentSong = _selectedSong;
}

- (void)searchDisplayController:(UISearchDisplayController *)controller willUnloadSearchResultsTableView:(UITableView *)tableView;
{
    // search is done so get rid of the search FRC and reclaim memory
    self.searchFetchedResultsController.delegate = nil;
    self.searchFetchedResultsController = nil;
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = controller == [self fetchedResultsControllerGetter] ? self.tableView : self.searchDisplayController.searchResultsTableView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert: {
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        }
            
        case NSFetchedResultsChangeDelete: {
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        }
            
        case NSFetchedResultsChangeUpdate: {
            SongCell *cell = (SongCell *)[tableView cellForRowAtIndexPath:indexPath];
            [cell configureWithFavoriteSong:[[self fetchedResultsControllerForTableView:tableView] objectAtIndexPath:indexPath]];
            break;
        }
            
        case NSFetchedResultsChangeMove: {
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        }
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id )sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    UITableView *tableView = controller == [self fetchedResultsControllerGetter] ? self.tableView : self.searchDisplayController.searchResultsTableView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    UITableView *tableView = controller == [self fetchedResultsController] ? self.tableView : self.searchDisplayController.searchResultsTableView;
    // The fetch controller has sent all current change notifications, so tell the table view to process all updates.
    [tableView endUpdates];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

-(void)movedBetweenDatabases {
    if (!_fetchedResultsController) return;
    _fetchedResultsController = nil;
    NSError *error;
    [[self fetchedResultsControllerGetter] performFetch:&error];
    [self.tableView reloadData];
    if (self.searchDisplayController.isActive) {
        _searchFetchedResultsController = nil;
        [[self searchFetchedResultsControllerGetter] performFetch:&error];
        [self.searchDisplayController.searchResultsTableView reloadData];
    }
}

-(void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    UITableViewHeaderFooterView *headerView = (UITableViewHeaderFooterView *)view;
    headerView.contentView.backgroundColor = [UIColor whiteColor];
    headerView.alpha = 0.95;
    headerView.textLabel.font = [UIFont fontWithName:@"ProximaNova-SemiBold" size:15];
    headerView.textLabel.textColor = [UIColor blackColor];
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [[UIView alloc] init];
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 12;
}

-(void)setupView {
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 9, 0, 0);
    self.tableView.tableHeaderView.backgroundColor = [UIColor whiteColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.searchDisplayController.searchResultsTableView.rowHeight = self.tableView.rowHeight;
    self.searchDisplayController.searchResultsTableView.separatorStyle = self.tableView.separatorStyle;
    self.searchDisplayController.searchBar.tintColor = [UIColor defaultColor];
    [self.searchDisplayController.searchBar setBackgroundImage:[UIImage imageNamed:@"white"] forBarPosition:UIBarPositionTopAttached barMetrics:UIBarMetricsDefault];
}

@end