//
//  iPhoneMainViewController.m
//  TabFinder
//
//  Created by Luiz Gustavo Faria on 11/07/13.
//  Copyright (c) 2013 PDM Systems. All rights reserved.
//

#import "iPhoneMainViewController.h"


@interface iPhoneMainViewController ()

@end

@implementation iPhoneMainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self.webView setBackgroundColor:[UIColor clearColor]];
    [Engine.instance disableLeftMenu];
    self.webView.scrollView.delegate = self;
    if (self.internetSong) {
        [self loadInternetSong];
    } else if (self.currentSong) {
        [self loadFavoritesSong];
    }
    _tabHeaderView.hidden = YES;
    _bannerView.delegate = self;
    [self fixBannerHeightOrHideIt];
}

-(void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error {
    _bannerView.hidden = YES;
}

-(void)bannerViewWillLoadAd:(ADBannerView *)banner {
    _bannerView.hidden = [InAppPurchaseManager sharedInstance].userHasFullApp;
}

-(void)fixBannerHeightOrHideIt {
    _bannerHeight.constant = UIInterfaceOrientationIsPortrait(self.interfaceOrientation) ? 50 : 32;
    _bannerView.hidden = [InAppPurchaseManager sharedInstance].userHasFullApp;
}

-(UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void) viewDidDisappear:(BOOL)animated {
    if (!self.navigationController) {
        [Engine.instance enableLeftMenu];
        [_bannerView cancelBannerViewAction];
        [_bannerView removeFromSuperview];
        _bannerView = nil;
    }
    [super viewDidDisappear:animated];
}

-(void)webViewDidFinishLoad:(UIWebView *)webView {
    [super webViewDidFinishLoad:webView];
    [_tabHeaderView configureForSong:self.currentSong];
    _tabHeaderView.hidden = NO;
    [self.webView.scrollView setContentInset:UIEdgeInsetsMake(_tabHeaderView.frame.size.height + 10, 0, 44, 0)];
    [self.webView.scrollView setContentOffset:CGPointMake(0, -_tabHeaderView.frame.size.height - 10)];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.y <= 0 && scrollView.isDecelerating && self.navigationController.navigationBar.frame.origin.y < 0) {
        [self showControlBarsAnimated:YES];
    }
    if (scrollView.contentOffset.y > -_tabHeaderView.frame.size.height && scrollView.contentOffset.y < 0) {
        CGFloat offset = _tabHeaderView.frame.size.height - fabsf(scrollView.contentOffset.y);
        _tabHeaderView.frame = CGRectMake(0, 0 - offset*0.3, _tabHeaderView.frame.size.width, _tabHeaderView.frame.size.height);
    }
    if (scrollView.isDragging) {
        for (UIView *view in self.view.subviews) {
            if ([view isMemberOfClass:[ChordsContainerView class]]) {
                [(ChordsContainerView *)view closeButtonPressed:self];
            }
        }
    }
}

-(void)showControlBarsAnimated:(BOOL)animated {
    self.toolBarBottomSpaceToContainer.constant = 0;
    [self.view setNeedsUpdateConstraints];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [UIView animateWithDuration:0.35f animations:^{
        [self.view layoutIfNeeded];
    } completion:nil];
}

-(void)scrollViewDidScrollToTop:(UIScrollView *)scrollView {
    [self showControlBarsAnimated:YES];
}

-(void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    if (scrollView.contentOffset.y < 0 || scrollView.contentOffset.y + scrollView.frame.size.height > scrollView.contentSize.height || scrollView.isZooming) return;
    if (velocity.y > 0.7 && self.toolBarBottomSpaceToContainer.constant == 0) {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        self.toolBarBottomSpaceToContainer.constant = 44;
    } else if (velocity.y < -0.7 && self.toolBarBottomSpaceToContainer.constant == 44) {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        self.toolBarBottomSpaceToContainer.constant = 0;
    }
    [self.view setNeedsUpdateConstraints];
    [UIView animateWithDuration:0.35f animations:^{
        [self.view layoutIfNeeded];
    } completion:nil];
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
        int numberOfViews = 0;
        CGPoint firstCenter = CGPointMake(self.view.center.x-30, self.view.center.y-15);
        for (UIView *view in self.view.subviews) {
            if ([view isMemberOfClass:[ChordsContainerView class]]) {
                view.center = CGPointMake(firstCenter.x + numberOfViews*15,firstCenter.y + numberOfViews*20);
                numberOfViews++;
            }
        }
    [self fixBannerHeightOrHideIt];
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

@end
