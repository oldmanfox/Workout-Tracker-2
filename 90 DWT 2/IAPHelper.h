//
//  IAPHelper.h
//  90 DWT 1
//
//  Created by Grant, Jared on 5/10/13.
//  Copyright (c) 2013 Grant, Jared. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

UIKIT_EXTERN NSString *const IAPHelperProductPurchasedNotification;

typedef void (^RequestProductsCompletionHandler) (BOOL success, NSArray * products);

@interface IAPHelper : NSObject

//@property (nonatomic, strong) NSMutableDictionary * products;

- (id)initWithProductIdentifiers:(NSSet *)productIdentifiers;
- (void)requestProductsWithCompletionHandler:(RequestProductsCompletionHandler)completionHandler;
- (void)buyProduct:(SKProduct *)product;
- (BOOL)productPurchased:(NSString *)productIdentifier;
- (void)restoreCompletedTransactions;

@end
