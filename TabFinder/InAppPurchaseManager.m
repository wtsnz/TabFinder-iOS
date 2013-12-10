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

@interface InAppPurchaseManager ()

@property AlertPopupView *popupView;

@end

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

-(id)init {
    self = [super init];
    // register to observe notifications from the store
    [[NSNotificationCenter defaultCenter]
     addObserver: self
     selector: @selector (storeDidChange:)
     name: NSUbiquitousKeyValueStoreDidChangeExternallyNotification
     object: [NSUbiquitousKeyValueStore defaultStore]];
    // get changes that might have happened while this
    // instance of your app wasn't running
    [[NSUbiquitousKeyValueStore defaultStore] synchronize];
    return self;
}

-(void)storeDidChange:(NSNotification *)notification {
    [[MenuViewController instance].tableView reloadData];
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
        [[NSUserDefaults standardUserDefaults] setValue:transaction.transactionIdentifier forKey:@"proUpgradeTransactionReceipt" ];
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
        [Api reportPurchase];
        [self.class writeUserFile:YES];
        [[NSUbiquitousKeyValueStore defaultStore] setBool:YES forKey:@"has_full_app"];
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
            case SKPaymentTransactionStatePurchasing:
                _popupView = [AlertPopupView showInView:[UIApplication sharedApplication].keyWindow withMessage:@"Upgrading to TabFinder Pro..." autodismiss:NO];
                break;
            case SKPaymentTransactionStatePurchased:
                if (_popupView) [_popupView dismiss];
                [AlertPopupView showInView:[UIApplication sharedApplication].keyWindow withMessage:@"Thanks for purchasing TabFinder Pro!" autodismiss:YES];
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                if (_popupView) [_popupView dismiss];
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                if (_popupView) [_popupView dismiss];
                [AlertPopupView showInView:[UIApplication sharedApplication].keyWindow withMessage:@"Thanks for reactivating TabFinder Pro!" autodismiss:YES];
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

+(NSString *)userFilePath {
    return [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"user.plist"];
}

+(void)writeUserFile:(BOOL)hasFullApp {
    [@{@"has_full_app": @(hasFullApp)} writeToFile:[self userFilePath] atomically:YES];
}

+(BOOL)userHasFullApp {
    if ([[NSUbiquitousKeyValueStore defaultStore] objectForKey:@"has_full_app"] == nil) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:[self userFilePath]]) {
            BOOL hasFullApp = [[[[NSDictionary alloc] initWithContentsOfFile:[self userFilePath]] valueForKey:@"has_full_app"] boolValue];
            if (hasFullApp) {
                [[NSUbiquitousKeyValueStore defaultStore] setBool:hasFullApp forKey:@"has_full_app"];
                return YES;
            } else {
                [[NSUbiquitousKeyValueStore defaultStore] synchronize];
                return NO;
            }
        } else {
            [self writeUserFile:[Favorites tabCount] > 0];
            return [self userHasFullApp];
        }
    }
    return [[NSUbiquitousKeyValueStore defaultStore] boolForKey:@"has_full_app"];
}


@end
