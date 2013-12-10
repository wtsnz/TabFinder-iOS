//
//  iPadMasterViewController.h
//  TabFinder
//
//  Created by Luiz Gustavo Faria on 17/11/13.
//  Copyright (c) 2013 PDM Systems. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IIViewDeckController.h"
#import "SearchViewController.h"
#import "iPadMainViewController.h"
#import "NavController.h"

@interface iPadMasterViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIView *mainContainerView;
@property (weak, nonatomic) IBOutlet UIView *sideMenuContainerView;
@property (strong, nonatomic) IIViewDeckController *viewDeckController;
@property (strong, nonatomic) SearchViewController *searchViewController;
@property (strong, nonatomic) UIViewController *chordsViewController;
@property (strong, nonatomic) UIViewController *favoritesViewController;
@property (strong, nonatomic) UIViewController *historyViewController;
@property (strong, nonatomic) iPadMainViewController *iPadMainViewController;
@property (strong, nonatomic) NavController *leftSideNavController;
@property (strong, nonatomic) NavController *rightSideNavController;

@property (weak, nonatomic) IBOutlet UIButton *searchMenuButton;
@property (weak, nonatomic) IBOutlet UIButton *favoritesMenuButton;
@property (weak, nonatomic) IBOutlet UIButton *historyMenuButton;
@property (weak, nonatomic) IBOutlet UIButton *chordsDictMenuButton;
@property (weak, nonatomic) IBOutlet UIButton *icloudMenuButton;
@property (weak, nonatomic) IBOutlet UIButton *facebookMenuButton;
@property (weak, nonatomic) IBOutlet UIButton *feedbackMenuButton;
@property (weak, nonatomic) IBOutlet UIButton *tellFriendsMenuButton;
@property (weak, nonatomic) IBOutlet UIButton *proButton;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *menuTitles;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *menuArrowTopSpaceToContainerConstraint;

+(iPadMasterViewController *)instance;

@end
