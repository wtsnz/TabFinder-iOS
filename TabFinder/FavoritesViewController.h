//
//  FavoritesViewController.h
//  TabFinder
//
//  Created by Luiz Gustavo Faria on 24/06/13.
//  Copyright (c) 2013 PDM Systems. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FavoritesViewController : UITableViewController <UISearchDisplayDelegate>

-(void)reloadFavorites;
+(FavoritesViewController *)currentInstance;

@end
