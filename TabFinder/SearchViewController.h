//
//  SearchViewController.h
//  TabFinder
//
//  Created by Luiz Gustavo Faria on 12/06/13.
//  Copyright (c) 2013 PDM Systems. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SongCell.h"

@interface SearchViewController : UITableViewController <UISearchBarDelegate>

@property (strong, nonatomic)  UISearchBar *searchBar;

@end
