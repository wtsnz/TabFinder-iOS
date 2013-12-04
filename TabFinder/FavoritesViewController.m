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

- (void)viewDidLoad
{
    if (![[NSUserDefaults standardUserDefaults] valueForKey:@"favorites_sorting"]) {
        [[NSUserDefaults standardUserDefaults] setValue:@"name" forKey:@"favorites_sorting"];
    }
    [super viewDidLoad];
    self.tableView.sectionIndexMinimumDisplayRowCount = 25;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"sort_by_artist"] style:UIBarButtonItemStylePlain target:self action:@selector(changeSorting:)];
    [self configSortingButton];
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
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:[[NSUserDefaults standardUserDefaults] valueForKey:@"favorites_sorting"] ascending:YES];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"self.isFavorite == %@",@(YES)]];
    [NSFetchedResultsController deleteCacheWithName:@"FavoritesCache"];
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
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:[[NSUserDefaults standardUserDefaults] valueForKey:@"favorites_sorting"] ascending:YES];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"self.isFavorite == %@",@(YES)]];
    self.searchFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:CoreDataHelper.get.managedObjectContext sectionNameKeyPath:nil cacheName:@"FavoritesSearchCache"];
    self.searchFetchedResultsController.delegate = self;
    return self.searchFetchedResultsController;
}

-(void)changeSorting:(UIBarButtonItem *)sender {
    NSString *currentSorting = [[NSUserDefaults standardUserDefaults] valueForKey:@"favorites_sorting"];
    NSString *newSorting = [currentSorting isEqualToString:@"name"] ? @"artist" : @"name";
    NSString *message = [@"Sorting tabs by " stringByAppendingString:[newSorting isEqualToString:@"artist"] ? @"artist name" : @"song title"];
    [[NSUserDefaults standardUserDefaults] setValue:newSorting forKey:@"favorites_sorting"];
    [self configSortingButton];
    [AlertPopupView showInView:self.navigationController.view withMessage:message autodismiss:YES];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:newSorting ascending:YES];
    [[[self fetchedResultsControllerGetter] fetchRequest] setSortDescriptors:@[sortDescriptor]];
    NSError *error;
    if (![[self fetchedResultsControllerGetter] performFetch:&error]) {
        NSLog(@"error!");
    }
    [self.tableView reloadData];
}

-(void)configSortingButton {
    [self.navigationItem.rightBarButtonItem setImage:[UIImage imageNamed:[@"sort_by_" stringByAppendingString:[[NSUserDefaults standardUserDefaults] valueForKey:@"favorites_sorting"]]]];
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
    if (![[InAppPurchaseManager sharedInstance] fullAppCheck:@"Take your favorites with you, all the time! They're available offline and synched on all your devices."]) return;
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
