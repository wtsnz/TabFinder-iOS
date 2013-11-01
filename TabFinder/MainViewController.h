//
//  TabFromSearchViewController.h
//  TabFinder
//
//  Created by Luiz Gustavo Faria on 12/06/13.
//  Copyright (c) 2013 PDM Systems. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSDictionary+Song.h"
#import "SearchViewController.h"
#import "SwipeView.h"
#import "Song.h"
#import "FavoritesAlertView.h"
#import "ChordsContainerView.h"

@interface MainViewController : UIViewController <UIActionSheetDelegate, UIScrollViewDelegate, UIWebViewDelegate, UISplitViewControllerDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *toolBarBottomSpaceToContainer;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicatorView;
@property (weak, nonatomic) IBOutlet UIToolbar *bottomToolbar;
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UISlider *autoScrollSlider;
@property (weak, nonatomic) IBOutlet UILabel *autoScrollingSpeedLabel;
@property (weak, nonatomic) IBOutlet UIView *autoScrollingPopupView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *versionsButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *favoritesButtonItem;
@property (weak, nonatomic) IBOutlet UIButton *actionButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *actionButtonItem;
@property (weak, nonatomic) IBOutlet UILabel *autoScrollingTitleLabel;

- (IBAction)didPressActionButton:(id)sender;

- (IBAction)didPressVersionsButton:(id)sender;
- (IBAction)didPressFavoritesButton:(id)sender;

-(void)loadFavoritesSong;
-(void)loadInternetSong;

//internet song attributes
@property (nonatomic) NSInteger currentVersionIndex;
@property (strong, nonatomic) UIActionSheet *versionsSheet;
@property (strong, nonatomic) UIActionSheet *shareSheet;
@property (strong, nonatomic) NSDictionary *internetSong;

@property (strong, nonatomic) Song *currentSong;

@end
