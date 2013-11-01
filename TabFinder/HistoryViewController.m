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
#import "InAppPurchaseManager.h"

@interface HistoryViewController () <UIActionSheetDelegate>

@property (strong, nonatomic) Song *selectedSong;

@end

@implementation HistoryViewController

static HistoryViewController *_instance;

+(HistoryViewController *)currentInstance {
    return _instance;
}

- (void)viewDidLoad
{
    [NSFetchedResultsController deleteCacheWithName:@"HistoryCache"];
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"trash"] style:UIBarButtonItemStylePlain target:self action:@selector(changeSettings:)];
    _instance = self;
    self.tableView.sectionIndexMinimumDisplayRowCount = 9999;
    self.searchDisplayController.searchResultsTableView.sectionIndexMinimumDisplayRowCount = 9999;
}

-(NSFetchedResultsController *)fetchedResultsControllerGetter {
    if (self.fetchedResultsController) {
        return self.fetchedResultsController;
    }
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Song" inManagedObjectContext:CoreDataHelper.get.managedObjectContext];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"self.dateOfCreation != nil"]];
    [fetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"dateOfCreation" ascending:NO]]];
    [fetchRequest setEntity:entity];
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:CoreDataHelper.get.managedObjectContext sectionNameKeyPath:@"historySectionTitle" cacheName:@"HistoryCache"];
    self.fetchedResultsController.delegate = self;
    return self.fetchedResultsController;
}

-(NSFetchedResultsController *)searchFetchedResultsControllerGetter {
    if (self.searchFetchedResultsController) {
        return self.searchFetchedResultsController;
    }
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Song" inManagedObjectContext:CoreDataHelper.get.managedObjectContext];
    [fetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"dateOfCreation" ascending:NO]]];
    [fetchRequest setEntity:entity];
    self.searchFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:CoreDataHelper.get.managedObjectContext sectionNameKeyPath:@"historySectionTitle" cacheName:@"HistorySearchCache"];
    self.searchFetchedResultsController.delegate = self;
    return self.searchFetchedResultsController;
}

-(void)changeSettings:(UIBarButtonItem *)sender {
    [[[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete all" otherButtonTitles:@"Delete older than 2 days", @"Delete older than 7 days", @"Delete older than 30 days", nil] showFromBarButtonItem:sender animated:YES];
}

-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (actionSheet.cancelButtonIndex == buttonIndex) {
        return;
    };
    NSInteger numberOfDays;
    switch (buttonIndex) {
        case 0:
            numberOfDays = 0;
            break;
        case 1:
            numberOfDays = 2;
            break;
        case 2:
            numberOfDays = 7;
            break;
        default:
            numberOfDays = 30;
            break;
    }
    [Song removeOlderThanDays:numberOfDays];
}

#pragma mark - Table view delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (![[InAppPurchaseManager sharedInstance] fullAppCheck:@"History shows all tabs you've searched and lets you access them offline!"]) return;
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Song *song = [[self fetchedResultsControllerForTableView:tableView] objectAtIndexPath:indexPath];
        if (song.isFavorite.boolValue) {
            song.dateOfCreation = nil;
        } else {
            [[CoreDataHelper.get managedObjectContext] deleteObject:song];
        }
        [CoreDataHelper.get saveContext];
    }
}

#pragma mark Search Display Controller

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.dateOfCreation != nil AND (self.name beginswith[c] %@ OR self.artist beginswith[c] %@)",searchString, searchString];
    [NSFetchedResultsController deleteCacheWithName:@"HistorySearchCache"];
    [[[self searchFetchedResultsControllerGetter] fetchRequest] setPredicate:predicate];
    return [super searchDisplayController:controller shouldReloadTableForSearchString:searchString];
}

@end
