//
//  SearchViewController.m
//  TabFinder
//
//  Created by Luiz Gustavo Faria on 5/05/13.
//  Copyright (c) 2013 PDM Systems. All rights reserved.
//

#import "SearchViewController.h"
#import "NSDictionary+Song.h"
#import "Api.h"
#import "MainViewController.h"
#import "AppDelegate.h"

@interface SearchViewController ()

@property NSMutableDictionary *searchResults;
@property NSMutableArray *searchResultsDictionaryKeys;
@property NSInteger totalSearchPages;
@property NSInteger currentSearchPage;
@property BOOL noResultsFound;

@end

@implementation SearchViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [_searchBar makeItFlat];
    [self resetSearchResults];
    [self.navigationItem.rightBarButtonItem removeTitleShadow];
}

-(void)resetSearchResults {
    _noResultsFound = NO;
    _currentSearchPage = 0;
    _totalSearchPages = 0;
    _searchResults = [NSMutableDictionary dictionary];
    _searchResultsDictionaryKeys = [NSMutableArray array];
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [_searchBar makeItFlat]; //layout fix
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ([_searchBar isFirstResponder]) [_searchBar resignFirstResponder];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    NSString *term = [searchBar.text stringByTrimmingCharactersInSet:[[NSCharacterSet alphanumericCharacterSet] invertedSet]];
    if (term.length < 3) {
        [[[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Your search must be at least 3 characters long!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
        return;
    }
    [_searchBar resignFirstResponder];
    _currentSearchPage = 0;
    _totalSearchPages = 0;
    [self requestData];
}

-(void)requestData {
    UIActivityIndicatorView *loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    loadingIndicator.center = CGPointMake(_searchBar.frame.size.width - 50, _searchBar.frame.size.height/2);
    [_searchBar addSubview:loadingIndicator];
    [loadingIndicator startAnimating];
    _currentSearchPage++;
    [Api tabSearch:_searchBar.text page:_currentSearchPage success:^(id parsedResponse) {
        [loadingIndicator removeFromSuperview];
        if (_currentSearchPage == 1){
            [_searchResults removeAllObjects];
            [_searchResultsDictionaryKeys removeAllObjects];
        }
        _totalSearchPages = [[parsedResponse objectForKey:@"pages"] integerValue];
        id resultsObject = [parsedResponse objectForKey:@"result"];
        if ([[parsedResponse objectForKey:@"total"] integerValue] == 0) {
            if (_currentSearchPage == 1) _noResultsFound = YES;
            [self.tableView reloadData];
            return;
        }
        _noResultsFound = NO;
        NSMutableArray *allSongs;
        if ([resultsObject respondsToSelector:@selector(objectAtIndex:)]) {
            allSongs = [parsedResponse objectForKey:@"result"];
        } else {
            allSongs = [NSMutableArray arrayWithObject:resultsObject];
        }
        for (NSDictionary *song in allSongs) {
            NSString *key = [NSString stringWithFormat:@"%@ [][] %@",song.name,song.artist];
            if (!_searchResults[key]) {
                _searchResults[key] = [NSMutableDictionary dictionaryWithDictionary:
                               @{@"name": song.name,
                                 @"artist": song.artist,
                                 @"versions": [NSMutableArray array]}];
                [_searchResultsDictionaryKeys addObject:key];
            }
            NSMutableDictionary *existingSong = _searchResults[key];
            [existingSong.versions addObject:song];
        }
        [self.tableView reloadData];
    } failure:^{
        [loadingIndicator removeFromSuperview];
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_noResultsFound) return 1;
    return _searchResults.allKeys.count + (_currentSearchPage < _totalSearchPages);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_noResultsFound) {
        UITableViewCell *cell = [[NSBundle mainBundle] loadNibNamed:@"NoResultsCell" owner:nil options:nil].lastObject;
        return cell;
    }
    if (_searchResults.allKeys.count == indexPath.row) {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        UIActivityIndicatorView *ai = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [cell addSubview:ai];
        ai.center = CGPointMake(cell.center.x, tableView.rowHeight/2);
        [ai startAnimating];
        return cell;
    }
    static NSString *songCellIdentifier = @"SongCell";
    SongCell *cell = [tableView dequeueReusableCellWithIdentifier:songCellIdentifier];
    if (!cell) cell = [[SongCell alloc] init];
    NSDictionary *song = _searchResults[_searchResultsDictionaryKeys[indexPath.row]];
    [cell configureWithInternetSong:song];
    return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell isMemberOfClass:[SongCell class]]) {
        if (!((SongCell*)cell).artistImageView.image)
            [((SongCell *)cell).activityIndicator startAnimating];
        else
            [((SongCell *)cell).activityIndicator stopAnimating];
    }
    if (indexPath.row == _searchResults.allKeys.count && _currentSearchPage < _totalSearchPages) {
        [self requestData];
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        MainViewController *mainVC = ((AppDelegate *)[UIApplication sharedApplication].delegate).mainViewControllerIpad;
        mainVC.internetSong = _searchResults[_searchResultsDictionaryKeys[tableView.indexPathForSelectedRow.row]];
        [mainVC loadInternetSong];
    }
    else {
        [self performSegueWithIdentifier:@"SongSegue" sender:self];
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"SongSegue"]) {
        MainViewController *vc = segue.destinationViewController;
        vc.internetSong = _searchResults[_searchResultsDictionaryKeys[self.tableView.indexPathForSelectedRow.row]];
    }
}


@end
