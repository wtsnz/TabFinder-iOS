//
//  RatingPromptViewController.m
//  TabFinder
//
//  Created by Luiz Gustavo Faria on 28/10/13.
//  Copyright (c) 2013 PDM Systems. All rights reserved.
//

#import "RatingPromptViewController.h"
#import "iRate.h"
#import "Favorites.h"
#import "MainViewController.h"

@interface RatingPromptViewController () <iRateDelegate>

@property (weak, nonatomic) IBOutlet UILabel *tabsCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UIButton *rateButton;

@end

@implementation RatingPromptViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _rateButton.layer.cornerRadius = 6;
    _messageLabel.text = [NSString stringWithFormat:@"This is your %ith tab! If you're enjoying TabFinder, would you take a few seconds to rate it?",[iRate sharedInstance].eventCount];
    _tabsCountLabel.text = [NSString stringWithFormat:@"%i tabs!",[iRate sharedInstance].eventCount];
    [iRate sharedInstance].delegate = self;
}

- (IBAction)didPressRateButton:(id)sender {
    [[iRate sharedInstance] setRatedThisVersion:YES];
    [self dismissViewControllerAnimated:YES completion:^{
        [[iRate sharedInstance] openRatingsPageInAppStore];
    }];
}

- (IBAction)didPressRemindLaterButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)iRateCouldNotConnectToAppStore:(NSError *)error {
    [[[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Failed to connect to the app store. Try again later!" delegate:nil cancelButtonTitle:@"Ok"otherButtonTitles:nil] show];
    [[iRate sharedInstance] setRatedThisVersion:NO];
}

@end
