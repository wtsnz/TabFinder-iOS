//
//  SKProduct+LocalizedPrice.h
//  TabFinder
//
//  Created by Luiz Gustavo Faria on 2/10/13.
//  Copyright (c) 2013 PDM Systems. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

@interface SKProduct (LocalizedPrice)

@property (nonatomic, readonly) NSString *localizedPrice;

@end
