//
//  TabFromSearchViewController.m
//  TabFinder
//
//  Created by Luiz Gustavo Faria on 12/06/13.
//  Copyright (c) 2013 PDM Systems. All rights reserved.
//

#import "MainViewController.h"
#import <CoreImage/CoreImage.h>
#import "ChordView.h"
#import "Favorites.h"
#import "ChordsContainerView.h"
#import <MessageUI/MessageUI.h>
#import "AppDelegate.h"
#import "Api.h"

@interface MainViewController () <MFMailComposeViewControllerDelegate>

@property NSDictionary *chords;

@end

@implementation MainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _autoScrollingPopupView.alpha = 0;
    [self autoScroll];
    _autoScrollSlider.value = 0;
    _autoScrollSlider.userInteractionEnabled = NO;
    _webView.scrollView.contentInset = UIEdgeInsetsMake(0, 0, 44, 0);
}

-(void)webViewDidStartLoad:(UIWebView *)webView {
    _webView.scrollView.userInteractionEnabled = NO;
    [_loadingIndicatorView startAnimating];
    _autoScrollSlider.userInteractionEnabled = NO;
    self.navigationItem.rightBarButtonItem.enabled = NO;
}

-(void)webViewDidFinishLoad:(UIWebView *)webView {
    [_loadingIndicatorView stopAnimating];
    _webView.scrollView.userInteractionEnabled = YES;
    _autoScrollSlider.userInteractionEnabled = YES;
    self.navigationItem.rightBarButtonItem.enabled = YES;
    _versionsButton.enabled = _versionsSheet != nil;
    [self configureFavoritesButton];
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if ([[[request.URL.absoluteString componentsSeparatedByString:@":"] objectAtIndex:0] isEqualToString:@"chord"]) {
        if (!_chords || _chords.count == 0) {
            NSString *chords = [webView stringByEvaluatingJavaScriptFromString:@"$('#chords').text()"];
            if (!chords || chords.length < 10) return NO;
            _chords = [NSJSONSerialization JSONObjectWithData:[chords dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:nil];
        }
        NSString *chordName = [[[request.URL.absoluteString componentsSeparatedByString:@":"] lastObject] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        if (!_chords[chordName]) return NO;
        [ChordsContainerView addChordViewWithName:chordName variations:_chords[chordName] toView:self.view];
        return NO;
    }
    return YES;
}

- (IBAction)didBeginChangingSlider:(id)sender {
    [UIView animateWithDuration:0.5 animations:^{
        _autoScrollingPopupView.alpha = 1;
    }];
}

- (IBAction)didEndEditingAutoScroll:(id)sender {
    [UIView animateWithDuration:0.5 animations:^{
        _autoScrollingPopupView.alpha = 0;
    }];
}

- (IBAction)didChangeAutoScroll:(id)sender {
    _autoScrollingSpeedLabel.text = [NSString stringWithFormat:@"%.1fx",_autoScrollSlider.value * 10];
}

-(void)autoScroll {
    if (!_webView.scrollView.isDragging
        && !_webView.scrollView.isDecelerating
        && (_webView.scrollView.contentOffset.y + _webView.frame.size.height < _webView.scrollView.contentSize.height)) {
        CGFloat percentage = _autoScrollSlider.value * 100;
        NSTimeInterval scrollingInterval = 1;
        CGFloat offset = 0;
        if (percentage < 5) { scrollingInterval = 1; offset = percentage/5;
        } else if (percentage < 10) { scrollingInterval = 0.5; offset = percentage/10;
        } else if (percentage < 25) { scrollingInterval = 0.1; offset = percentage/50;
        } else if (percentage < 50) { offset = percentage / 100; scrollingInterval = 0.05;
        } else if (percentage < 91) { offset = percentage / 200; scrollingInterval = 0.025; }
        else { offset = percentage / 500; scrollingInterval = 0.01; }
        offset *= 1.4; //speed modifier
        [_webView.scrollView setContentOffset:CGPointMake(_webView.scrollView.contentOffset.x, _webView.scrollView.contentOffset.y + offset)];
        [self performSelector:@selector(autoScroll) withObject:nil afterDelay:scrollingInterval];
    } else {
        [self performSelector:@selector(autoScroll) withObject:nil afterDelay:1];
    }
}

- (IBAction)didPressVersionsButton:(id)sender {
    if ([_versionsSheet isVisible]) {
        [_versionsSheet dismissWithClickedButtonIndex:_versionsSheet.cancelButtonIndex animated:YES];
    } else {
        [_versionsSheet showFromBarButtonItem:sender animated:YES];
    }
}

- (void)configureFavoritesButton {
    [_favoritesButtonItem setImage:[[UIImage imageNamed:_currentSong.isFavorite.boolValue ? @"estrelinha" : @"estrelinha_cinzinha"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
}

- (IBAction)didPressFavoritesButton:(id)sender {
    if (!_currentSong) return;
    if (_currentSong.isFavorite.boolValue) {
        [Favorites removeFromFavorites:_currentSong];
    } else {
        [Favorites addToFavorites:_currentSong];
    }
    [self configureFavoritesButton];
    [FavoritesAlertView showFavoritesAlertForSong:_currentSong inView:self.view];
}

-(void)viewDidDisappear:(BOOL)animated {
    _webView.delegate = nil;
    [_webView stopLoading];
    [_webView removeFromSuperview];
    [_webView loadHTMLString:@"" baseURL:nil];
    _webView = nil;
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    for (UIScrollView *scroll in [_webView subviews]) {
        if ([scroll respondsToSelector:@selector(setZoomScale:)])
            [scroll setZoomScale:UIInterfaceOrientationIsLandscape(self.interfaceOrientation) ? _webView.frame.size.height/_webView.frame.size.width : 1 animated:NO];
    }
}

//////// internet tab

-(void)loadInternetSong {
    _currentSong = nil;
    self.navigationItem.title = _internetSong.name;
    [self changeVersion:[_internetSong.versions indexOfObject:_internetSong.bestVersion]];
}

-(void)loadFavoritesSong {
    _internetSong = nil;
    _versionsSheet = nil;
    self.navigationItem.title = _currentSong.name;
    _versionsButton.title = _currentSong.shortVersionTitle;
    [self presentCurrentSong];
}

-(void)changeVersion:(NSInteger)versionIndex {
    _currentVersionIndex = versionIndex;
    NSDictionary *version = _internetSong.versions[_currentVersionIndex];
    self.versionsButton.title = version.shortVersionTitle;
    _versionsSheet = [_internetSong versionsActionSheetWithCurrentVersionIndex:_currentVersionIndex];
    _versionsSheet.delegate = self;
    if ([Favorites findByUgid:version[@"id"]]) {
        _currentSong = [Favorites findByUgid:version[@"id"]];
        [self presentCurrentSong];
        return;
    }
    [_loadingIndicatorView startAnimating];
    [Api fetchTabContentForVersion:version success:^(NSString *html) {
        _currentSong = [Favorites addToDatabase:version withContent:html];
        [_loadingIndicatorView stopAnimating];
        [self presentCurrentSong];
    } failure:^{
        [_loadingIndicatorView stopAnimating];
        [[[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Something went wrong!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    }];
}

-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == actionSheet.cancelButtonIndex) return;
    [self changeVersion:buttonIndex < _currentVersionIndex ? buttonIndex : buttonIndex + 1];
}

-(void)presentCurrentSong {
    [_webView loadHTMLString:_currentSong.tab baseURL:[NSURL URLWithString:_currentSong.version.integerValue == 0 ? nil : @"http://tabfinder.herokuapp.com"]];
}

@end
