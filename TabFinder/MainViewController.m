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
#import "AppDelegate.h"
#import "Api.h"
#import <Social/Social.h>
#import "iRate.h"
#import <MessageUI/MessageUI.h>
#import "InAppPurchaseManager.h"
#import "CoreDataHelper.h"
#import "UpgradePromptViewController.h"
#import "AlertPopupView.h"

@interface MainViewController () <MFMailComposeViewControllerDelegate>

@property NSDictionary *chords;

@end

@implementation MainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _autoScrollingTitleLabel.font = [UIFont proximaNovaSemiBoldSize:_autoScrollingTitleLabel.font.pointSize];
    _autoScrollingSpeedLabel.font = [UIFont proximaNovaLightSize:_autoScrollingSpeedLabel.font.pointSize];
    _autoScrollingPopupView.alpha = 0;
    _autoScrollingPopupView.backgroundColor = [UIColor blackColor];
    [self autoScroll];
    _autoScrollSlider.value = 0;
    _autoScrollSlider.userInteractionEnabled = NO;
    _actionButton.enabled = NO;
    _versionsButton.enabled = NO;
    _webView.hidden = YES;
    _isPromptingUserWithUpgradeOrRating = NO;
}

-(void)webViewDidStartLoad:(UIWebView *)webView {
    _webView.scrollView.userInteractionEnabled = NO;
    _autoScrollSlider.userInteractionEnabled = NO;
    self.navigationItem.rightBarButtonItem.enabled = NO;
    _actionButton.enabled = NO;
    _chords = nil;
}

-(void)webViewDidFinishLoad:(UIWebView *)webView {
    _webView.hidden = NO;
    [_popupView dismiss];
    _webView.scrollView.userInteractionEnabled = YES;
    _autoScrollSlider.userInteractionEnabled = YES;
    self.navigationItem.rightBarButtonItem.enabled = YES;
    _versionsButton.enabled = YES;
    _actionButton.enabled = YES;
    [self showPopupsIfNecessary];
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
        _autoScrollingPopupView.alpha = 0.9;
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
    if (!_versionsSheet) {
        NSString *searchTerm = [NSString stringWithFormat:@"%@ %@",_currentSong.artist, _currentSong.name];
        _versionsButton.enabled = NO;
        if (_popupView && _popupView.superview) [_popupView dismiss];
        _popupView = [AlertPopupView showInView:self.view withMessage:@"Loading..." autodismiss:NO];
        [Api tabSearch:searchTerm page:1 success:^(id parsedResponse) {
            id resultsObject = [parsedResponse objectForKey:@"result"];
            NSMutableArray *allSongs;
            if ([resultsObject respondsToSelector:@selector(objectAtIndex:)]) {
                allSongs = [parsedResponse objectForKey:@"result"];
            } else {
                allSongs = [NSMutableArray arrayWithObject:resultsObject];
            }
            NSMutableDictionary *parsedSong;
            for (NSDictionary *song in allSongs) {
                if (!parsedSong) {
                    parsedSong = [NSMutableDictionary dictionaryWithDictionary:
                                  @{@"name": song.name,
                                    @"artist": song.artist,
                                    @"versions": [NSMutableArray array]}];
                }
                [parsedSong.versions addObject:song];
                if (song.versionNumber.integerValue == _currentSong.version.integerValue && [song.type isEqualToString:_currentSong.type] && [song.type2 isEqualToString:_currentSong.type2]) {
                    _currentVersionIndex = [parsedSong.versions indexOfObject:song];
                }
                _internetSong = parsedSong;
            }
            _versionsSheet = [parsedSong versionsActionSheetWithCurrentVersionIndex:_currentVersionIndex];
            _versionsSheet.delegate = self;
            [_versionsSheet showFromBarButtonItem:sender animated:YES];
            [Api addArtistToCache:_currentSong];
            _versionsButton.enabled = YES;
            [_popupView dismiss];
        } failure:^{
            [_popupView dismiss];
            _versionsButton.enabled = YES;
            [[[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Unable to retrieve more versions for this song. Make sure you have internet access!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
        }];
        return;
    }
    if ([_versionsSheet isVisible]) {
        [_versionsSheet dismissWithClickedButtonIndex:_versionsSheet.cancelButtonIndex animated:YES];
    } else {
        [_versionsSheet showFromBarButtonItem:sender animated:YES];
    }
}

- (void)configureFavoritesButton {
    [_favoritesButtonItem setImage:[UIImage imageNamed:_currentSong.isFavorite.boolValue ? @"favorites" : @"not_favorites"]];
}

- (IBAction)didPressFavoritesButton:(id)sender {
    if (!_currentSong) return;
    if (!_currentSong.managedObjectContext) return;
    _currentSong.isFavorite = @(!_currentSong.isFavorite.boolValue);
    [self configureFavoritesButton];
    [FavoritesAlertView showFavoritesAlertForSong:_currentSong inView:self.webView];
    [CoreDataHelper.get saveContext];
}

-(void)viewDidDisappear:(BOOL)animated {
    if (self.navigationController) return; //don't do anything if still in the nav stack!
    //otherwise release everything
    _webView.delegate = nil;
    [_webView stopLoading];
    [_webView removeFromSuperview];
    _webView = nil;
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
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
    [self presentCurrentSong];
}

-(void)changeVersion:(NSInteger)versionIndex {
    _currentVersionIndex = versionIndex;
    NSDictionary *version = _internetSong.versions[_currentVersionIndex];
    _versionsSheet = [_internetSong versionsActionSheetWithCurrentVersionIndex:_currentVersionIndex];
    _versionsSheet.delegate = self;
    if ([Favorites findByUgid:version[@"id"]]) {
        _currentSong = [Favorites findByUgid:version[@"id"]];
        [self presentCurrentSong];
        return;
    }
    if (_popupView && _popupView.superview) {
        [_popupView removeFromSuperview];
    }
    _popupView = [AlertPopupView showInView:self.view withMessage:@"Loading.." autodismiss:NO];
    [Api fetchTabContentForVersion:version success:^(NSString *html) {
        _currentSong = [Song addToDatabase:version withContent:html];
        [self presentCurrentSong];
        [self showPopupsIfNecessary];
    } failure:^{
        [_popupView dismiss];
        [[[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Something went wrong!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    }];
}

-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (actionSheet == _shareSheet) _shareSheet = nil;
    if (buttonIndex == actionSheet.cancelButtonIndex) return;
    if (actionSheet == _versionsSheet) {
        [self changeVersion:buttonIndex < _currentVersionIndex ? buttonIndex : buttonIndex + 1];
        return;
    }
    if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Print"]) {
        [self print];
        return;
    }
    [self shareThisTab:[actionSheet buttonTitleAtIndex:buttonIndex]];
}

-(void)presentCurrentSong {
    [_webView loadHTMLString:_currentSong.tab baseURL:_currentSong.version.integerValue == 0 ? nil : BASE_URL];
    [self configureFavoritesButton];
}

-(void)showPopupsIfNecessary {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    UIViewController *vcToPresent;
    [[iRate sharedInstance] logEvent:NO];
    if (![iRate sharedInstance].ratedThisVersion && [iRate sharedInstance].eventCount % 25 == 0) {
        vcToPresent = [sb instantiateViewControllerWithIdentifier:@"RatingPromptViewController"];
    } else if ([iRate sharedInstance].eventCount % 11 == 0
        && ![InAppPurchaseManager sharedInstance].userHasFullApp
        && [InAppPurchaseManager sharedInstance].proUpgradeProduct
               && [InAppPurchaseManager sharedInstance].proUpgradeProduct.localizedDescription) {
        vcToPresent = [sb instantiateViewControllerWithIdentifier:@"UpgradePromptViewController"];
    }
    if (!vcToPresent) return;
    _isPromptingUserWithUpgradeOrRating = YES;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [self presentViewController:vcToPresent animated:YES completion:nil];
    } else {
        [[Engine.instance viewDeckController] presentViewController:vcToPresent animated:YES completion:nil];
    }
}

- (IBAction)didPressActionButton:(id)sender {
    if (_shareSheet) {
        [_shareSheet dismissWithClickedButtonIndex:_shareSheet.cancelButtonIndex animated:YES];
        _shareSheet = nil;
        return;
    }
    _shareSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Facebook",@"Twitter",@"Email",@"Print", nil];
    [_shareSheet showFromBarButtonItem:_actionButtonItem animated:YES];
}

-(void)shareThisTab:(NSString *)via {
    if ([via isEqualToString:@"Facebook"]) {
        [self shareUsing:SLServiceTypeFacebook];
    }
    if ([via isEqualToString:@"Twitter"]) {
        [self shareUsing:SLServiceTypeTwitter];
    }
    if ([via isEqualToString:@"Email"]) {
        MFMailComposeViewController *vc = [[MFMailComposeViewController alloc] init];
        vc.mailComposeDelegate = self;
        vc.toRecipients = @[];
        vc.subject = [NSString stringWithFormat:@"%@ for song: %@ (by %@)",[_currentSong.type capitalizedString],_currentSong.name, _currentSong.artist];
        vc.navigationBar.translucent = NO;
        [vc setMessageBody:[NSString stringWithFormat:@"http://tabfinder.herokuapp.com/share/%@",_currentSong.ugid] isHTML:NO];
        [self presentViewController:vc animated:YES completion:nil];
    }
}

-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [controller dismissViewControllerAnimated:YES completion:nil];
}

-(void)shareUsing:(NSString *)serviceType {
    NSString *message;
    message= [[NSString alloc] initWithFormat:@"Learn how to play \"%@\" by %@ using TabFinder: http://tabfinder.herokuapp.com/share/%@",_currentSong.name,_currentSong.artist,_currentSong.ugid];
    if([SLComposeViewController isAvailableForServiceType:serviceType]) {
        SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:serviceType];
        [controller setInitialText:message];
        [self presentViewController:controller animated:YES completion:Nil];
        
        SLComposeViewControllerCompletionHandler myBlock = ^(SLComposeViewControllerResult result){
            [controller dismissViewControllerAnimated:YES completion:Nil];
        };
        controller.completionHandler = myBlock;
    } else {
        NSString *message = @"This service is not available! You can enable it on from your device settings.";
        [[[UIAlertView alloc] initWithTitle:@"Oops!" message:message delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    }
}

-(void)print {
    if (![[InAppPurchaseManager sharedInstance] fullAppCheck:@"The print function allows you to easily print any guitar tab using your Air Printer!"]) return;
    UIPrintInteractionController *pic = [UIPrintInteractionController sharedPrintController];
    UIPrintInfo *printInfo = [UIPrintInfo printInfo];
    printInfo.outputType = UIPrintInfoOutputGeneral;
    printInfo.orientation = UIPrintInfoOrientationPortrait;
    printInfo.jobName = _currentSong.name;
    pic.printInfo = printInfo;
    pic.printFormatter = [_webView viewPrintFormatter];
    pic.showsPageRange = YES;
    void (^completionHandler)(UIPrintInteractionController *, BOOL, NSError *) =
    ^(UIPrintInteractionController *printController, BOOL completed, NSError *error)
    {
        if (!completed && error)
        {
            NSLog(@"Printing could not complete because of error: %@", error);
        }
    };
    [pic presentAnimated:YES completionHandler:completionHandler];
}

@end
