//
//  IapHelper.swift
//  RaceRunner
//
//  Created by Joshua Adams on 2/14/16.
//  Copyright © 2016 Josh Adams. All rights reserved.
//

import StoreKit

/// Notification that is generated when a product is purchased.
public let IapHelperProductPurchasedNotification = "IAPHelperProductPurchasedNotification"

/// Product identifiers are unique strings registered on the app store.
public typealias ProductIdentifier = String

/// Completion handler called when products are fetched.
public typealias RequestProductsCompletionHandler = (success: Bool, products: [SKProduct]) -> ()

/// A Helper class for In-App-Purchases. It can fetch products, tell you if a product has been purchased,
/// purchase products, and restore purchases.  Uses NSUserDefaults to cache if a product has been purchased.
public class IapHelper : NSObject  {
  /// MARK: - Private Properties
  
  // Used to keep track of the possible products and which ones have been purchased.
  private let productIdentifiers: Set<ProductIdentifier>
  private var purchasedProductIdentifiers = Set<ProductIdentifier>()
  
  // Used by SKProductsRequestDelegate
  private var productsRequest: SKProductsRequest?
  private var completionHandler: RequestProductsCompletionHandler?
  
  /// MARK: - User-facing API
  
  /// Initialize the helper.  Pass in the set of ProductIdentifiers supported by the app.
  public init(productIdentifiers: Set<ProductIdentifier>) {
    self.productIdentifiers = productIdentifiers
    for productIdentifier in productIdentifiers {
      let purchased = NSUserDefaults.standardUserDefaults().boolForKey(productIdentifier)
      if purchased {
        purchasedProductIdentifiers.insert(productIdentifier)
        print("Previously purchased: \(productIdentifier)")
      } else {
        print("Not purchased: \(productIdentifier)")
      }
    }
    super.init()
    SKPaymentQueue.defaultQueue().addTransactionObserver(self)
  }
  
  /// Gets the list of SKProducts from the Apple server; calls the handler with the list of products.
  public func requestProductsWithCompletionHandler(handler: RequestProductsCompletionHandler) {
    completionHandler = handler
    productsRequest = SKProductsRequest(productIdentifiers: productIdentifiers)
    productsRequest?.delegate = self
    productsRequest?.start()
  }
  /// Initiates purchase of a product.
  public func purchaseProduct(product: SKProduct) {
    print("Buying \(product.productIdentifier)...")
    let payment = SKPayment(product: product)
    SKPaymentQueue.defaultQueue().addPayment(payment)
  }
  /// Given the product identifier, returns true if that product has been purchased.
  public func isProductPurchased(productIdentifier: ProductIdentifier) -> Bool {
    return purchasedProductIdentifiers.contains(productIdentifier)
  }
  
  /// If the state of whether purchases have been made is lost  (e.g. the
  /// user deletes and reinstalls the app) this will recover the purchases.
  public func restoreCompletedTransactions() {
    SKPaymentQueue.defaultQueue().restoreCompletedTransactions()
  }
  
  public class func canMakePayments() -> Bool {
    return SKPaymentQueue.canMakePayments()
  }
}

// MARK: - SKProductsRequestDelegate

extension IapHelper: SKProductsRequestDelegate {
  public func productsRequest(request: SKProductsRequest, didReceiveResponse response: SKProductsResponse) {
//    print("Loaded list of products...")
    let products = response.products 
    completionHandler?(success: true, products: products)
    clearRequest()
    
    // debug printing
    for p in products {
      print("Found product: \(p.productIdentifier) \(p.localizedTitle) \(p.price.floatValue)")
    }
  }
  
  public func request(request: SKRequest, didFailWithError error: NSError) {
    print("Failed to load list of products.")
    print("Error: \(error)")
    clearRequest()
  }
  
  private func clearRequest() {
    productsRequest = nil
    completionHandler = nil
  }
}

extension IapHelper: SKPaymentTransactionObserver {
  /// This is a function called by the payment queue, not to be called directly.
  /// For each transaction act accordingly, save in the purchased cache, issue notifications,
  /// mark the transaction as complete.
  public func paymentQueue(queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
    for transaction in transactions {
      switch (transaction.transactionState) {
      case .Purchased:
        completeTransaction(transaction)
        break
      case .Failed:
        failedTransaction(transaction)
        break
      case .Restored:
        restoreTransaction(transaction)
        break
      case .Deferred:
        break
      case .Purchasing:
        break
      }
    }
  }
  
  private func completeTransaction(transaction: SKPaymentTransaction) {
    print("completeTransaction...")
    provideContentForProductIdentifier(transaction.payment.productIdentifier)
    SKPaymentQueue.defaultQueue().finishTransaction(transaction)
  }
  
  private func restoreTransaction(transaction: SKPaymentTransaction) {
    let productIdentifier = transaction.originalTransaction!.payment.productIdentifier
    print("restoreTransaction... \(productIdentifier)")
    provideContentForProductIdentifier(productIdentifier)
    SKPaymentQueue.defaultQueue().finishTransaction(transaction)
  }
  
  // Helper: Saves the fact that the product has been purchased and posts a notification.
  private func provideContentForProductIdentifier(productIdentifier: String) {
    purchasedProductIdentifiers.insert(productIdentifier)
    NSUserDefaults.standardUserDefaults().setBool(true, forKey: productIdentifier)
    NSUserDefaults.standardUserDefaults().synchronize()
    NSNotificationCenter.defaultCenter().postNotificationName(IapHelperProductPurchasedNotification, object: productIdentifier)
  }
  
  func fakeIapPurchases() {
    for productIdentifier in productIdentifiers {
      provideContentForProductIdentifier(productIdentifier)
    }
  }
  
  private func failedTransaction(transaction: SKPaymentTransaction) {
    print("failedTransaction...")
    if transaction.error!.code != SKErrorPaymentCancelled {
      print("Transaction error: \(transaction.error!.localizedDescription)")
    }
    SKPaymentQueue.defaultQueue().finishTransaction(transaction)
  }
}