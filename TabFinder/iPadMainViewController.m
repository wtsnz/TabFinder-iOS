//
//  iPadMainViewController.m
//  TabFinder
//
//  Created by Luiz Gustavo Faria on 11/07/13.
//  Copyright (c) 2013 PDM Systems. All rights reserved.
//
#import <iAd/iAd.h>

#import "iPadMainViewController.h"
#import "iPadMasterViewController.h"
#import "ChordView.h"

@interface iPadMainViewController () <UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet ADBannerView *bannerView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *titleButtonItem;
@property UIPopoverController *chordsPopover;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *dictButtonItem;

@end

@implementation iPadMainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.webView.scrollView.delegate = self;
    _bannerView.hidden = YES;
    _bannerView.delegate = self;
    _tabHeaderView.hidden = YES;
    _titleButtonItem.title = @"";
    [iPadMasterViewController instance].viewDeckController.panningGestureDelegate = self;
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    UIView *hitTest = [self.view hitTest:[gestureRecognizer locationInView:self.view] withEvent:nil];
    if ([hitTest isMemberOfClass:[ChordsContainerView class]] || [hitTest isMemberOfClass:[ChordView class]]) {
        return NO;
    }
    if (self.webView.scrollView.contentOffset.x == 0) {
        return YES;
    }
    return NO;
}

-(void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error {
    _bannerView.hidden = YES;
}

-(void)bannerViewWillLoadAd:(ADBannerView *)banner {
    _bannerView.hidden = [InAppPurchaseManager sharedInstance].userHasFullApp;
}

-(void)webViewDidFinishLoad:(UIWebView *)webView {
    _logoImageView.hidden = YES;
    [super webViewDidFinishLoad:webView];
    [_tabHeaderView configureForSong:self.currentSong];
    _tabHeaderView.hidden = NO;
    [self.webView stringByEvaluatingJavaScriptFromString:@"$('body').css('margin-left', 25);"];
    [self.webView.scrollView setContentInset:UIEdgeInsetsMake(_tabHeaderView.frame.size.height + 10, 0, 0, 0)];
    [self.webView.scrollView setContentOffset:CGPointMake(0, -_tabHeaderView.frame.size.height - 10)];
    //in case the user has just purchased Pro
    if (!_bannerView.hidden && [InAppPurchaseManager sharedInstance].userHasFullApp) _bannerView.hidden = YES;
}

-(void)loadFavoritesSong {
    [self toggleLeftViewIfNeeded];
    [super loadFavoritesSong];
}

-(void)loadInternetSong {
    [self toggleLeftViewIfNeeded];
    [super loadInternetSong];
}

-(void)toggleLeftViewIfNeeded {
    if ([iPadMasterViewController instance].viewDeckController.isAnySideOpen) {
        [[iPadMasterViewController instance].viewDeckController toggleLeftViewAnimated:YES];
    }
}

-(IBAction)didPressFavoritesButton:(id)sender {
    [super didPressFavoritesButton:sender];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.y > -_tabHeaderView.frame.size.height && scrollView.contentOffset.y < 0) {
        CGFloat offset = _tabHeaderView.frame.size.height - fabsf(scrollView.contentOffset.y);
        _tabHeaderView.frame = CGRectMake(0, 44 - offset*0.3, _tabHeaderView.frame.size.width, _tabHeaderView.frame.size.height);
    }
}


- (IBAction)didPressChordDictionary:(id)sender {
    if (_chordsPopover && [_chordsPopover isPopoverVisible]) {
        [_chordsPopover dismissPopoverAnimated:YES];
        return;
    }
    _chordsPopover = [[UIPopoverController alloc] initWithContentViewController:[iPadMasterViewController instance].chordsViewController];
    _chordsPopover.backgroundColor = [iPadMasterViewController instance].chordsViewController.view.backgroundColor;
    [_chordsPopover presentPopoverFromBarButtonItem:_dictButtonItem permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
}
@end
