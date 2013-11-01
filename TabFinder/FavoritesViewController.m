//
//  FavoritesViewController.m
//  TabFinder
//
//  Created by Luiz Gustavo Faria on 24/06/13.
//  Copyright (c) 2013 PDM Systems. All rights reserved.
//

#import "FavoritesViewController.h"

@interface FavoritesViewController () <UIActionSheetDelegate>

@property Song *selectedSong;

@end

@implementation FavoritesViewController

static FavoritesViewController *_currentInstance;

+(FavoritesViewController *)currentInstance {
    return _currentInstance;
}

- (void)viewDidLoad
{
    _sorting = @"name";
    [super viewDidLoad];
    _currentInstance = self;
    self.tableView.sectionIndexMinimumDisplayRowCount = 25;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"sort_by_artist"] style:UIBarButtonItemStylePlain target:self action:@selector(changeSorting:)];
}

-(NSFetchedResultsController *)fetchedResultsControllerForTableView:(UITableView *)tableView {
    return tableView == self.tableView ? [self fetchedResultsControllerGetter] : [self searchFetchedResultsControllerGetter];
}

-(NSFetchedResultsController *)fetchedResultsControllerGetter {
    if (self.fetchedResultsController) {
        return self.fetchedResultsController;
    }
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Song" inManagedObjectContext:CoreDataHelper.get.managedObjectContext];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:_sorting ascending:YES];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"self.isFavorite == %@",@(YES)]];
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:CoreDataHelper.get.managedObjectContext sectionNameKeyPath:@"favoritesSectionTitle" cacheName:@"FavoritesCache"];
    self.fetchedResultsController.delegate = self;
    return self.fetchedResultsController;
}

-(NSFetchedResultsController *)searchFetchedResultsControllerGetter {
    if (self.searchFetchedResultsController) {
        return self.searchFetchedResultsController;
    }
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Song" inManagedObjectContext:CoreDataHelper.get.managedObjectContext];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:_sorting ascending:YES];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"self.isFavorite == %@",@(YES)]];
    self.searchFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:CoreDataHelper.get.managedObjectContext sectionNameKeyPath:nil cacheName:@"FavoritesSearchCache"];
    self.searchFetchedResultsController.delegate = self;
    return self.searchFetchedResultsController;
}

-(void)changeSorting:(UIBarButtonItem *)sender {
    [self.navigationItem.rightBarButtonItem setImage:[UIImage imageNamed:[@"sort_by_" stringByAppendingString:_sorting]]];
    _sorting = [_sorting isEqualToString:@"name"] ? @"artist" : @"name";
    NSString *message = [@"Sorting tabs by " stringByAppendingString:[_sorting isEqualToString:@"artist"] ? @"artist name" : @"song title"];
    [AlertPopupView showInView:self.navigationController.view withMessage:message];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:_sorting ascending:YES];
    [self.fetchedResultsController.fetchRequest setSortDescriptors:@[sortDescriptor]];
    NSError *error;
    if (![[self fetchedResultsControllerGetter] performFetch:&error]) {
        NSLog(@"error!");
    }
    [self.tableView reloadData];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Song *song = [[self fetchedResultsControllerForTableView:tableView] objectAtIndexPath:indexPath];
        if (song.dateOfCreation) {
            song.isFavorite = @(NO);
        } else {
            [[CoreDataHelper.get managedObjectContext] deleteObject:song];
        }
        [CoreDataHelper.get saveContext];
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (![[InAppPurchaseManager sharedInstance] fullAppCheck:@"Bookmark as many tabs as you want and get access to them when you're offline!"]) return;
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    self.selectedSong.dateOfCreation = [NSDate date];
    [CoreDataHelper.get saveContext];
}

#pragma mark - Search Display Controller

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.isFavorite == %@ AND (self.name beginswith[c] %@ OR self.artist beginswith[c] %@)", @(YES),searchString, searchString];
    [NSFetchedResultsController deleteCacheWithName:@"FavoritesSearchCache"];
    [[[self searchFetchedResultsControllerGetter] fetchRequest] setPredicate:predicate];
    return [super searchDisplayController:controller shouldReloadTableForSearchString:searchString];
}


@end
