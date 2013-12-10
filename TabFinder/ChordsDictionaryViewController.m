//
//  ChordsDictionaryViewController.m
//  TabFinder
//
//  Created by Luiz Gustavo Faria on 25/11/13.
//  Copyright (c) 2013 PDM Systems. All rights reserved.
//

#import "ChordsDictionaryViewController.h"

@interface ChordsDictionaryViewController () <UISearchBarDelegate>

@property (strong, nonatomic) NSDictionary *chords;
@property (strong, nonatomic) NSArray *filteredChords;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@end

@implementation ChordsDictionaryViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _searchBar.delegate = self;
    self.tableView.tableHeaderView = _searchBar;
    NSError *error;
    NSBundle *thisBundle = [NSBundle bundleForClass:[self class]];
    NSString *filePath = nil;
    filePath = [thisBundle pathForResource:@"chords" ofType:@"txt" inDirectory:@""];
    NSString *string = [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    _chords = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
    _filteredChords = @[];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _filteredChords.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ChordCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.textLabel.text = _filteredChords[indexPath.row];
    return cell;
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchText.length == 0) return;
    NSString *baseChord = [[searchText substringToIndex:1] uppercaseString];
    NSDictionary *chords = [_chords objectForKey:baseChord];
    NSArray *keys = [chords allKeys];
    _filteredChords = [keys filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF beginswith[c] %@",searchText]];
    _filteredChords = [_filteredChords sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSString *c1 = obj1;
        NSString *c2 = obj2;
        return c1.length > c2.length ? NSOrderedDescending : NSOrderedAscending;
    }];
    [self.tableView reloadData];
}

@end
