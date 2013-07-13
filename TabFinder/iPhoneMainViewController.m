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
    self.webView.scrollView.delegate = self;
    if (self.internetSong) {
        [self loadInternetSong];
    } else if (self.currentSong) {
        [self loadFavoritesSong];
    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.y <= 0 && scrollView.isDecelerating && self.navigationController.navigationBar.frame.origin.y < 0) {
        [self showControlBarsAnimated:YES];
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
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}


@end
