//
//  InAppPurchaseManager.h
//  TabFinder
//
//  Created by Luiz Gustavo Faria on 2/10/13.
//  Copyright (c) 2013 PDM Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
#import "Api.h"

#define kInAppPurchaseManagerProductsFetchedNotification @"kInAppPurchaseManagerProductsFetchedNotification"
#define kInAppPurchaseManagerTransactionFailedNotification @"kInAppPurchaseManagerTransactionFailedNotification"
#define kInAppPurchaseManagerTransactionSucceededNotification @"kInAppPurchaseManagerTransactionSucceededNotification"
#define kInAppPurchaseProUpgradeProductId @"protabfinder"

@interface InAppPurchaseManager : NSObject <SKProductsRequestDelegate, SKPaymentTransactionObserver, UIAlertViewDelegate>

@property (strong, nonatomic) SKProduct *proUpgradeProduct;
@property (strong, nonatomic) SKProductsRequest *productsRequest;

+(InAppPurchaseManager *)sharedInstance;
- (void)requestProUpgradeProductData;
- (void)loadStore;
- (BOOL)canMakePurchases;
- (void)purchaseProUpgrade;
-(BOOL)fullAppCheck:(NSString *)featureMessage;
-(BOOL)userHasFullApp;

@end
