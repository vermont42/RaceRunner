//
//  IapHelper.swift
//  RaceRunner
//
//  Adapted by Joshua Adams on 2/14/16.
//  Copyright © 2016 Ray Wenderlich. All rights reserved.
//

import StoreKit

// Note: I ordinarily don't comment as heavily, but most of this code is from a tutorial,
// and I thought it would be helpful to keep the comments as a reminder of how the code
// works.

/// Notification that is generated when a product is purchased.
public let IapHelperProductPurchasedNotification = "IAPHelperProductPurchasedNotification"

/// Product identifiers are unique strings registered on the app store.
public typealias ProductIdentifier = String

/// Completion handler called when products are fetched.
public typealias RequestProductsCompletionHandler = (_ success: Bool, _ products: [SKProduct]) -> ()

/// A Helper class for In-App-Purchases. It can fetch products, tell you if a product has been purchased,
/// purchase products, and restore purchases.  Uses NSUserDefaults to cache if a product has been purchased.
open class IapHelper: NSObject  {
  // Used to keep track of the possible products and which ones have been purchased.
  private let productIdentifiers: Set<ProductIdentifier>
  private var purchasedProductIdentifiers = Set<ProductIdentifier>()
  
  // Used by SKProductsRequestDelegate
  private var productsRequest: SKProductsRequest?
  private var completionHandler: RequestProductsCompletionHandler?
  
  /// Initialize the helper.  Pass in the set of ProductIdentifiers supported by the app.
  public init(productIdentifiers: Set<ProductIdentifier>) {
    self.productIdentifiers = productIdentifiers
    for productIdentifier in productIdentifiers {
      let purchased = UserDefaults.standard.bool(forKey: productIdentifier)
      if purchased {
        purchasedProductIdentifiers.insert(productIdentifier)
        //print("Previously purchased: \(productIdentifier)")
      } else {
        //print("Not purchased: \(productIdentifier)")
      }
    }
    super.init()
    SKPaymentQueue.default().add(self)
  }
  
  /// Gets the list of SKProducts from the Apple server; calls the handler with the list of products.
  open func requestProductsWithCompletionHandler(_ handler: @escaping RequestProductsCompletionHandler) {
    completionHandler = handler
    productsRequest = SKProductsRequest(productIdentifiers: productIdentifiers)
    productsRequest?.delegate = self
    productsRequest?.start()
  }

  /// Initiates purchase of a product.
  open func purchaseProduct(_ product: SKProduct) {
    print("Buying \(product.productIdentifier)...")
    let payment = SKPayment(product: product)
    SKPaymentQueue.default().add(payment)
  }

  /// Given the product identifier, returns true if that product has been purchased.
  open func isProductPurchased(_ productIdentifier: ProductIdentifier) -> Bool {
    return purchasedProductIdentifiers.contains(productIdentifier)
  }
  
  /// If the state of whether purchases have been made is lost  (e.g. the
  /// user deletes and reinstalls the app) this will recover the purchases.
  open func restoreCompletedTransactions() {
    SKPaymentQueue.default().restoreCompletedTransactions()
  }
  
  open class func canMakePayments() -> Bool {
    return SKPaymentQueue.canMakePayments()
  }
}

extension IapHelper: SKProductsRequestDelegate {
  public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
//    print("Loaded list of products...")
    let products = response.products 
    completionHandler?(true, products)
    clearRequest()
    
    // debug printing
//    for p in products {
//      print("Found product: \(p.productIdentifier) \(p.localizedTitle) \(p.price.floatValue)")
//    }
  }
  
  public func request(_ request: SKRequest, didFailWithError error: Error) {
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
  /// This is a function called by the payment queue, not to be called directly. For
  /// each transaction act accordingly, save in the purchased cache, issue notifications,
  /// and mark the transaction as complete.
  public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
    transactions.forEach {
      switch $0.transactionState {
      case .purchased:
        completeTransaction($0)
        break
      case .failed:
        failedTransaction($0)
        break
      case .restored:
        restoreTransaction($0)
        break
      case .deferred:
        break
      case .purchasing:
        break
      }
    }
  }
  
  private func completeTransaction(_ transaction: SKPaymentTransaction) {
    //print("completeTransaction...")
    provideContentForProductIdentifier(transaction.payment.productIdentifier)
    SKPaymentQueue.default().finishTransaction(transaction)
  }
  
  private func restoreTransaction(_ transaction: SKPaymentTransaction) {
    if let productIdentifier = transaction.original?.payment.productIdentifier {
      //print("restoreTransaction... \(productIdentifier)")
      provideContentForProductIdentifier(productIdentifier)
      SKPaymentQueue.default().finishTransaction(transaction)
    }
  }
  
  // Helper: Saves the fact that the product has been purchased and posts a notification.
  private func provideContentForProductIdentifier(_ productIdentifier: String) {
    purchasedProductIdentifiers.insert(productIdentifier)
    UserDefaults.standard.set(true, forKey: productIdentifier)
    UserDefaults.standard.synchronize()
    NotificationCenter.default.post(name: Notification.Name(rawValue: IapHelperProductPurchasedNotification), object: productIdentifier)
  }
  
  func fakeIapPurchases() {
    for productIdentifier in productIdentifiers {
      provideContentForProductIdentifier(productIdentifier)
    }
  }
  
  private func failedTransaction(_ transaction: SKPaymentTransaction) {
    //print("failedTransaction...")
    if let error = transaction.error, (error as NSError).code != SKError.paymentCancelled.rawValue {
      //print("Transaction error: \(error.localizedDescription)")
    }
    SKPaymentQueue.default().finishTransaction(transaction)
  }
}
