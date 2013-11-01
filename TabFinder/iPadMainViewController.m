//
//  iPadMainViewController.m
//  TabFinder
//
//  Created by Luiz Gustavo Faria on 11/07/13.
//  Copyright (c) 2013 PDM Systems. All rights reserved.
//
#import <iAd/iAd.h>

#import "iPadMainViewController.h"

@interface iPadMainViewController () <UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet ADBannerView *bannerView;
@property (strong, nonatomic) UIPopoverController *popoverReference;

@end

@implementation iPadMainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.webView.scrollView.delegate = self;
    _bannerView.hidden = YES;
    _bannerView.delegate = self;
}


-(void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error {
    _bannerView.hidden = YES;
}

-(void)bannerViewWillLoadAd:(ADBannerView *)banner {
    _bannerView.hidden = YES;//[InAppPurchaseManager sharedInstance].userHasFullApp;
}

-(void)webViewDidFinishLoad:(UIWebView *)webView {
    [super webViewDidFinishLoad:webView];
    _bannerView.hidden = YES; //[InAppPurchaseManager sharedInstance].userHasFullApp;
    [_tabHeaderView configureForSong:self.currentSong];
    _tabHeaderView.hidden = NO;
    [self.webView.scrollView setContentInset:UIEdgeInsetsMake(_tabHeaderView.frame.size.height + 10, 0, 44, 0)];
    [self.webView.scrollView setContentOffset:CGPointMake(0, -_tabHeaderView.frame.size.height - 10)];
}

-(void)loadFavoritesSong {
    [super loadFavoritesSong];
    [_popoverReference dismissPopoverAnimated:YES];
}

-(void)loadInternetSong {
    [super loadInternetSong];
    [_popoverReference dismissPopoverAnimated:YES];
}

-(IBAction)didPressFavoritesButton:(id)sender {
    [super didPressFavoritesButton:sender];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.y > -_tabHeaderView.frame.size.height && scrollView.contentOffset.y < 0) {
        CGFloat offset = _tabHeaderView.frame.size.height - fabsf(scrollView.contentOffset.y);
        _tabHeaderView.frame = CGRectMake(0, 0 - offset*0.3, _tabHeaderView.frame.size.width, _tabHeaderView.frame.size.height);
    }
}

-(void)splitViewController:(UISplitViewController *)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem {
    self.navigationItem.leftBarButtonItem = nil;
    _popoverReference = nil;
}

-(void)splitViewController:(UISplitViewController *)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)pc {
    barButtonItem.title = @"Menu";
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    _popoverReference = pc;
}


@end
