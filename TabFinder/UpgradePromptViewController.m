//
//  UpgradePromptViewController.m
//  TabFinder
//
//  Created by Luiz Gustavo Faria on 29/10/13.
//  Copyright (c) 2013 PDM Systems. All rights reserved.
//

#import "UpgradePromptViewController.h"
#import "InAppPurchaseManager.h"
#import "SKProduct+LocalizedPrice.h"

@implementation UpgradePromptViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _buyButton.layer.cornerRadius = 4;
    if (![InAppPurchaseManager sharedInstance].proUpgradeProduct || ![InAppPurchaseManager sharedInstance].proUpgradeProduct.localizedPrice) {
        _messageLabel.text = @"Purchase TabFinder Pro to disable ads and enable awesome features such as Favorites, History, Chords Dictionary and Printing.";
        [[InAppPurchaseManager sharedInstance] loadStore];
    } else {
        _messageLabel.text = [NSString stringWithFormat:@"Purchase TabFinder Pro for only %@ to disable ads and enable awesome features such as Favorites, History, Chords Dictionary and Printing.",[InAppPurchaseManager sharedInstance].proUpgradeProduct.localizedPrice];
    }
}

- (IBAction)didPressBuyButton:(id)sender {
    if ([InAppPurchaseManager sharedInstance].proUpgradeProduct && [InAppPurchaseManager sharedInstance].proUpgradeProduct.localizedDescription) {
        [[InAppPurchaseManager sharedInstance] purchaseProUpgrade];
        [self dismiss];
    } else {
        [[[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Unable to connect to the App Store. Make sure you have internet access and try again in a few moments! Thanks" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
        [[InAppPurchaseManager sharedInstance] loadStore];
    }
}

- (IBAction)didPressCancelButton:(id)sender {
    [self dismiss];
}

-(void)dismiss {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
