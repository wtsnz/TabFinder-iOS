//
//  InAppPurchaseManager.m
//  TabFinder
//
//  Created by Luiz Gustavo Faria on 2/10/13.
//  Copyright (c) 2013 PDM Systems. All rights reserved.
//

#import "InAppPurchaseManager.h"
#import "Favorites.h"
#import "SKProduct+LocalizedPrice.h"
#import "Engine.h"
#import "AppDelegate.h"

@implementation InAppPurchaseManager

static InAppPurchaseManager *_instance;

+(InAppPurchaseManager *)sharedInstance {
    if (!_instance) _instance = [[InAppPurchaseManager alloc] init];
    [self.class userHasFullApp];
    return _instance;
}

-(BOOL)userHasFullApp {
    return [self.class userHasFullApp];
}

- (void)requestProUpgradeProductData
{
    NSSet *productIdentifiers = [NSSet setWithObject:@"protabfinder" ];
    _productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:productIdentifiers];
    _productsRequest.delegate = self;
    [_productsRequest start];
}

#pragma mark -
#pragma mark SKProductsRequestDelegate methods

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    NSArray *products = response.products;
    _proUpgradeProduct = [products count] == 1 ? [products firstObject] : nil;
    if (_productsRequest)
    {
        NSLog(@"Product title: %@" , _proUpgradeProduct.localizedTitle);
        NSLog(@"Product description: %@" , _proUpgradeProduct.localizedDescription);
        NSLog(@"Product price: %@" , _proUpgradeProduct.price);
        NSLog(@"Product id: %@" , _proUpgradeProduct.productIdentifier);
    }
    
    for (NSString *invalidProductId in response.invalidProductIdentifiers)
    {
        NSLog(@"Invalid product id: %@" , invalidProductId);
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kInAppPurchaseManagerProductsFetchedNotification object:self userInfo:nil];
}

//
// call this method once on startup
//
- (void)loadStore
{
    // restarts any purchases if they were interrupted last time the app was open
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    // get the product description (defined in early sections)
    [self requestProUpgradeProductData];
}

//
// call this before making a purchase
//
- (BOOL)canMakePurchases
{
    return [SKPaymentQueue canMakePayments];
}

//
// kick off the upgrade transaction
//
- (void)purchaseProUpgrade
{
    //SKPayment *payment = [SKPayment paymentWithProductIdentifier:kInAppPurchaseProUpgradeProductId];
    SKPayment *payment = [SKPayment paymentWithProduct:_proUpgradeProduct];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

#pragma -
#pragma Purchase helpers

//
// saves a record of the transaction by storing the receipt to disk
//
- (void)recordTransaction:(SKPaymentTransaction *)transaction
{
    if ([transaction.payment.productIdentifier isEqualToString:kInAppPurchaseProUpgradeProductId])
    {
        // save the transaction receipt to disk
        [[NSUserDefaults standardUserDefaults] setValue:transaction.transactionReceipt forKey:@"proUpgradeTransactionReceipt" ];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

//
// enable pro features
//
- (void)provideContent:(NSString *)productId
{
    if ([productId isEqualToString:kInAppPurchaseProUpgradeProductId])
    {
        [self.class writeUserFile:YES];
        [[MenuViewController instance].tableView reloadData];
    }
}

//
// removes the transaction from the queue and posts a notification with the transaction result
//
- (void)finishTransaction:(SKPaymentTransaction *)transaction wasSuccessful:(BOOL)wasSuccessful
{
    // remove the transaction from the payment queue.
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:transaction, @"transaction" , nil];
    if (wasSuccessful)
    {
        // send out a notification that we’ve finished the transaction
        [[NSNotificationCenter defaultCenter] postNotificationName:kInAppPurchaseManagerTransactionSucceededNotification object:self userInfo:userInfo];
    }
    else
    {
        // send out a notification for the failed transaction
        [[NSNotificationCenter defaultCenter] postNotificationName:kInAppPurchaseManagerTransactionFailedNotification object:self userInfo:userInfo];
    }
}

//
// called when the transaction was successful
//
- (void)completeTransaction:(SKPaymentTransaction *)transaction
{
    [self recordTransaction:transaction];
    [self provideContent:transaction.payment.productIdentifier];
    [self finishTransaction:transaction wasSuccessful:YES];
}

//
// called when a transaction has been restored and and successfully completed
//
- (void)restoreTransaction:(SKPaymentTransaction *)transaction
{
    [self recordTransaction:transaction.originalTransaction];
    [self provideContent:transaction.originalTransaction.payment.productIdentifier];
    [self finishTransaction:transaction wasSuccessful:YES];
}

//
// called when a transaction has failed
//
- (void)failedTransaction:(SKPaymentTransaction *)transaction
{
    if (transaction.error.code != SKErrorPaymentCancelled)
    {
        // error!
        [self finishTransaction:transaction wasSuccessful:NO];
    }
    else
    {
        // this is fine, the user just cancelled, so don’t notify
        [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    }
}

#pragma mark -
#pragma mark SKPaymentTransactionObserver methods

//
// called when the transaction status is updated
//
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
                break;
            default:
                break;
        }
    }
}

-(BOOL)fullAppCheck:(NSString *)featureMessage {
    if ([self.class userHasFullApp]) return YES;
    NSString *message;
    if (!_proUpgradeProduct || !_proUpgradeProduct.localizedDescription) {
        message = [NSString stringWithFormat:@"%@ Upgrade to TabFinder Pro to unlock this feature and many others.", featureMessage];
        [self loadStore];
    } else {
        message = [NSString stringWithFormat:@"%@ Upgrade to TabFinder Pro for %@ to unlock this feature and many others.", featureMessage, _proUpgradeProduct.localizedPrice];
    }
    [[[UIAlertView alloc] initWithTitle:@"Locked feature!" message:message delegate:self cancelButtonTitle:@"No, thanks!" otherButtonTitles:@"Yes please!", nil] show];
    return NO;
}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (alertView.cancelButtonIndex == buttonIndex) return;
    [self purchaseProUpgrade];
}

+(void)writeUserFile:(BOOL)hasFullApp {
  [@{@"has_full_app": @(hasFullApp)} writeToFile:[self userFilePath] atomically:YES];
}

+(NSString *)userFilePath {
    return [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"user.plist"];
}

+(BOOL)userHasFullApp {
    //if file exists, read from file
    if ([[NSFileManager defaultManager] fileExistsAtPath:[self userFilePath]]) {
        return [[[[NSDictionary alloc] initWithContentsOfFile:[self userFilePath]] valueForKey:@"has_full_app"] boolValue];
    }
    //otherwise check how many songs in history, if > 0 then grant access and write to file
    [self writeUserFile:[Favorites history].count > 0];
    return [self userHasFullApp];
}


@end
