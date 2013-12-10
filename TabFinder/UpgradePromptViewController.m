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
#import "Engine.h"

@implementation UpgradePromptViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _buyButton.layer.cornerRadius = 4;
    if (![InAppPurchaseManager sharedInstance].proUpgradeProduct || ![InAppPurchaseManager sharedInstance].proUpgradeProduct.localizedPrice) {
        _messageLabel.text = @"Purchase TabFinder Pro to disable ads and enable awesome features such as Favorites, History, Chords Dictionary and Printing.";
        [[InAppPurchaseManager sharedInstance] loadStore];
    } else {
        _messageLabel.text = [NSString stringWithFormat:@"✓ Enable all our awesome features!\n\n✓ Get rid of the ads, including this\n\n✓ It's only %@! That's 2 guitar picks or half a coffee.\n\n✓ It shows how much you love the app and helps improving it!",[InAppPurchaseManager sharedInstance].proUpgradeProduct.localizedPrice];
    }
}

- (IBAction)didPressBuyButton:(id)sender {
    if ([InAppPurchaseManager sharedInstance].proUpgradeProduct && [InAppPurchaseManager sharedInstance].proUpgradeProduct.localizedDescription) {
        [[InAppPurchaseManager sharedInstance] purchaseProUpgrade];
        [self dismiss];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            if ([Engine.instance.viewDeckController isAnySideOpen]) {
                [Engine.instance.viewDeckController closeLeftViewAnimated:YES];
            }
        }
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
