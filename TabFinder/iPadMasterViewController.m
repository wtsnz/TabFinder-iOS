//
//  iPadMasterViewController.m
//  TabFinder
//
//  Created by Luiz Gustavo Faria on 17/11/13.
//  Copyright (c) 2013 PDM Systems. All rights reserved.
//

#import "iPadMasterViewController.h"
#import "IISideController.h"
#import "Engine.h"

@interface iPadMasterViewController () <IIViewDeckControllerDelegate, UIActionSheetDelegate>

@property NSArray *menuButtons;
@property UIPopoverController *popover;

@end

@implementation iPadMasterViewController

static iPadMasterViewController *_instance;

- (void)viewDidLoad
{
    [super viewDidLoad];
    _instance = self;
    [[UIToolbar appearanceWhenContainedIn:[iPadMainViewController class], nil] setBarTintColor:[UIColor defaultColor]];
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    _searchViewController = [sb instantiateViewControllerWithIdentifier:@"SearchViewController"];
    _favoritesViewController = [sb instantiateViewControllerWithIdentifier:@"FavoritesViewController"];
    _chordsViewController = [sb instantiateViewControllerWithIdentifier:@"ChordsViewController"];
    _chordsViewController.preferredContentSize = CGSizeMake(320, 568);
    _historyViewController = [sb instantiateViewControllerWithIdentifier:@"HistoryViewController"];
    _iPadMainViewController = [[UIStoryboard storyboardWithName:@"iPad" bundle:nil] instantiateViewControllerWithIdentifier:@"iPadMainViewController"];
    _leftSideNavController = [[NavController alloc] initWithRootViewController:_searchViewController];
    _viewDeckController = [[IIViewDeckController alloc] init];
    _viewDeckController.leftController = [[IISideController alloc] initWithViewController:_leftSideNavController constrained:320];
    _viewDeckController.centerController = _iPadMainViewController;
    _viewDeckController.centerhiddenInteractivity = IIViewDeckCenterHiddenNotUserInteractiveWithTapToClose;
    [self addChildViewController:_viewDeckController];
    [_mainContainerView addSubview:_viewDeckController.view];
    _viewDeckController.view.frame = CGRectMake(0, 0, _mainContainerView.frame.size.width, _mainContainerView.frame.size.height);
    _viewDeckController.delegate = self;
    _viewDeckController.view.layer.cornerRadius = 4;
    _viewDeckController.view.layer.masksToBounds = YES;
    _menuButtons = @[_searchMenuButton, _favoritesMenuButton, _historyMenuButton, _chordsDictMenuButton, _icloudMenuButton,  _facebookMenuButton, _feedbackMenuButton, _tellFriendsMenuButton, _proButton];
    for (UIButton *button in _menuButtons) {
        [button addTarget:self action:@selector(didPressMenuButton:) forControlEvents:UIControlEventTouchUpInside];
        [button setBackgroundImage:[UIImage imageNamed:@"selected_button"] forState:UIControlStateSelected];
        [button setImage:[[button imageForState:UIControlStateNormal] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        [button setImage:[[button imageForState:UIControlStateNormal] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateSelected];
        [button setTintColor:[UIColor colorWithWhite:0.9 alpha:1]];
        button.imageEdgeInsets = _searchMenuButton.imageEdgeInsets;
        button.titleEdgeInsets = _searchMenuButton.titleEdgeInsets;
        button.titleLabel.font = [UIFont proximaNovaSemiBoldSize:10];
        [button setTitleColor:[UIColor colorWithWhite:0.9 alpha:1] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor defaultColor] forState:UIControlStateSelected];
    }
    [_searchMenuButton setSelected:YES];
    ((UILabel *)_menuTitles[0]).textColor = [UIColor defaultColor];
    _searchMenuButton.tintColor = [UIColor defaultColor];
}

-(void)viewDidAppear:(BOOL)animated {
    _viewDeckController.leftSize = _mainContainerView.frame.size.width - 320;
    [self applyShadows];
    if (!_iPadMainViewController.currentSong) {
        if (!_viewDeckController.isAnySideOpen) {
            [_viewDeckController toggleLeftViewAnimated:YES];
        }
    }
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    _viewDeckController.leftSize = _mainContainerView.frame.size.width - 320;
}

-(void)viewDeckController:(IIViewDeckController *)viewDeckController applyShadow:(CALayer *)shadowLayer withBounds:(CGRect)rect {
    UIBezierPath* newShadowPath = [UIBezierPath bezierPathWithRect:rect];
    shadowLayer.masksToBounds = NO;
    shadowLayer.shadowRadius = 10;
    shadowLayer.shadowOpacity = 0.5;
    shadowLayer.shadowColor = [[UIColor blackColor] CGColor];
    shadowLayer.shadowOffset = CGSizeZero;
    shadowLayer.shadowPath = [newShadowPath CGPath];
}

-(void)didPressMenuButton:(id)sender {
    if ([InAppPurchaseManager sharedInstance].userHasFullApp) {
        _proButton.hidden = YES;
        [_menuTitles[8] setHidden:YES];
    }
    int menuButtonIndex = [_menuButtons indexOfObject:sender];
    if (!_viewDeckController.isAnySideOpen && menuButtonIndex <= 2) {
        [_viewDeckController toggleLeftView];
    }
    for (UIButton *button in _menuButtons) {
        if (button != sender) {
            [button setSelected:NO];
            button.tintColor = [UIColor colorWithWhite:0.9 alpha:0.9];
        }
    }
    for (UILabel *menuLabel in _menuTitles) {
        menuLabel.textColor = [UIColor colorWithWhite:0.9 alpha:0.9];
    }
    ((UILabel *)_menuTitles[menuButtonIndex]).textColor = [UIColor defaultColor];
    [((UIButton *)sender) setSelected:YES];
    [((UIButton *)sender) setTintColor:[UIColor defaultColor]];
    if (menuButtonIndex == 0) {
        [_leftSideNavController setViewControllers:@[_searchViewController]];
    }
    if (menuButtonIndex == 1) {
        [_leftSideNavController setViewControllers:@[_favoritesViewController]];
    }
    if (menuButtonIndex == 2) {
        [_leftSideNavController setViewControllers:@[_historyViewController]];
    }
    if (menuButtonIndex == 3) {
        if (_viewDeckController.isAnySideOpen) {
            [_viewDeckController toggleLeftViewAnimated:YES completion:^(IIViewDeckController *controller, BOOL success) {
                [_iPadMainViewController didPressChordDictionary:sender];
            }];
        } else {
            [_iPadMainViewController didPressChordDictionary:sender];
        }
    }
    if (menuButtonIndex <= 2) {
        _menuArrowTopSpaceToContainerConstraint.constant = 66 + 64*menuButtonIndex;
        [UIView animateWithDuration:0.2 animations:^{
            [self.view layoutIfNeeded];
        }];
    }
    if (menuButtonIndex == 4) {
        NSString *status;
        NSString *action;
        NSString *destructive;
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"enable_iCloud"]) {
            status = @"iCloud is enabled.";
            destructive = @"Disable iCloud";
            action = nil;
        } else {
            status = @"iCloud is disabled";
            action = @"Enable iCloud";
            destructive = nil;
        }
        [[[UIActionSheet alloc] initWithTitle:status delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:destructive otherButtonTitles:action, nil] showFromRect:CGRectMake(-10, 66 + 64 * 4, 1, 1) inView:_mainContainerView animated:YES];
    }
    if (menuButtonIndex == 5) {
        [Engine.instance likeOnFb];
        return;
    }
    if (menuButtonIndex == 6) {
        [Engine.instance sendFeedback];
        return;
    }
    if (menuButtonIndex == 7) {
        [Engine.instance tellFriends];
    }
    if (menuButtonIndex == 8) {
        [self presentViewController:[[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"UpgradePromptViewController"] animated:YES completion:nil];
    }
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Enable iCloud"]) {
        [Engine enableiCloud:YES];
    }
    if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Disable iCloud"]) {
        [Engine enableiCloud:NO];
    }
}

-(void)applyShadowsToView:(UIView *)view {
    UIBezierPath* newShadowPath = [UIBezierPath bezierPathWithRect:view.bounds];
    view.layer.masksToBounds = NO;
    view.layer.cornerRadius = 4;
    view.layer.shadowRadius = 10;
    view.layer.shadowOpacity = 0.7;
    view.layer.shadowColor = [[UIColor blackColor] CGColor];
    view.layer.shadowOffset = CGSizeZero;
    view.layer.shadowPath = [newShadowPath CGPath];
}

-(void)applyShadows {
    [self applyShadowsToView:_mainContainerView];
}

-(UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

+(iPadMasterViewController *)instance {
    return _instance;
}

@end
