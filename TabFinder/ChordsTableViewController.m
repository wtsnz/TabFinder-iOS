//
//  ChordsTableViewController.m
//  TabFinder
//
//  Created by Luiz Gustavo Faria on 07/08/12.
//
//

#import "ChordsTableViewController.h"
#import "ChordRequest.h"
#import "ChordsPresentationViewController.h"
#import "ChordCell.h"

@interface ChordsTableViewController () <UISearchBarDelegate>

@property (strong, nonatomic) NSString *selectedChordName;
@property (strong, nonatomic) UITapGestureRecognizer *tapTheScreenToBeginEditing;

@end

@implementation ChordsTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.contentSizeForViewInPopover = CGSizeMake(320, 480);
    _searchBar.delegate = self;
    [_searchBar makeItFlat];
    _tapTheScreenToBeginEditing = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(beginSearch)];
    [self.tableView addGestureRecognizer:_tapTheScreenToBeginEditing];
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [_searchBar makeItFlat];
}

- (void)viewDidUnload
{
    [self setSearchBar:nil];
    [super viewDidUnload];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [_searchBar resignFirstResponder];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _chords.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ChordCell";
    ChordCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell.chordNameLabel.text = [_chords objectAtIndex:indexPath.row];
    if ([cell.textLabel.text hasPrefix:@"No chords"]) {
        [cell setUserInteractionEnabled:NO];
    } else {
        [cell setUserInteractionEnabled:YES];
    }
    return cell;
}

#pragma mark - Table view delegate

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [cell drawRect:cell.frame];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        _selectedChord = [ChordRequest chordRequest:[_chords objectAtIndex:indexPath.row]];
        _selectedChordName = [_chords objectAtIndex:indexPath.row];
        [self performSegueWithIdentifier:@"ChordSegue" sender:self];
    });
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    ChordsPresentationViewController *chordsPresentationViewController = (ChordsPresentationViewController *)[segue destinationViewController];
    chordsPresentationViewController.chords = _selectedChord;
    chordsPresentationViewController.title = _selectedChordName;
}

-(void)clearTableView {
    _chords = [[NSMutableArray alloc] initWithObjects:nil];
    [self.tableView reloadData];
    [self.tableView addGestureRecognizer:_tapTheScreenToBeginEditing];
}

-(BOOL)textFieldShouldClear:(UITextField *)textField {
    [self clearTableView];
    return YES;
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
    if (_chords.count == 0) {
        [self clearTableView];
    }
}

-(void)beginSearch {
    if ([_searchBar isFirstResponder]) {
        [_searchBar resignFirstResponder];
    } else {
        [_searchBar becomeFirstResponder];
    }
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [_searchBar resignFirstResponder];
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchText.length == 0) {
        [self clearTableView];
        return;
    }
    [self.tableView removeGestureRecognizer:_tapTheScreenToBeginEditing];
    UIActivityIndicatorView *loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    loadingIndicator.center = CGPointMake(_searchBar.frame.size.width - 50, _searchBar.frame.size.height/2);
    [_searchBar addSubview:loadingIndicator];
    [loadingIndicator startAnimating];
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [loadingIndicator removeFromSuperview];
        _chords = [ChordRequest chordSuggestionForString:searchText];//: [[NSMutableArray alloc] initWithObjects:@"No internet connection.",nil];
        [self.tableView reloadData];
    });    
}

@end
