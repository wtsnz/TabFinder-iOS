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

@interface RatingPromptViewController ()

@property (weak, nonatomic) IBOutlet UILabel *tabsCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UIButton *rateButton;

@end

@implementation RatingPromptViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _rateButton.layer.cornerRadius = 6;
    _messageLabel.text = [NSString stringWithFormat:@"This is your %ith tab! If you're enjoying TabFinder, would you take a few seconds to rate it?",Favorites.tabCount];
    _tabsCountLabel.text = [NSString stringWithFormat:@"%i tabs!",Favorites.tabCount];
}

- (IBAction)didPressRateButton:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://itunes.com/apps/tabfinderguitartabssearchengine"]];
}

- (IBAction)didPressRemindLaterButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

@end
