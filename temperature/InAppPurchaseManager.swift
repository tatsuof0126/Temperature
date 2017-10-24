//
//  InAppPurchaseManager.swift
//  temperature
//
//  Created by 藤原 達郎 on 2017/09/22.
//  Copyright © 2017年 Tatsuo Fujiwara. All rights reserved.
//

import Foundation
import StoreKit


class InAppPurchaseManager : NSObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {

    // シングルトン
    static let purchaseManager = InAppPurchaseManager()
    class func getPurchaseManager() -> InAppPurchaseManager {
        return purchaseManager;
    }
    
    var delegate : PurchaseManagerDelegate?
    
    func purchase(productIdentifier: String) {
        if SKPaymentQueue.canMakePayments() == false {
            delegate?.restoreFail(message: NSLocalizedString("notallowedpurchase", comment: ""))
        }

        // まずプロダクト情報を取得
        let productsRequest = SKProductsRequest(productIdentifiers: Set([productIdentifier]))
        productsRequest.delegate = self
        productsRequest.start()
    }

    // 商品情報取得に成功した場合
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        if response.products.count > 0 {
            // 購入処理に進む
            doPurchase(response.products[0])
        } else {
            delegate?.purchaseFail(message: NSLocalizedString("failpurchase", comment: ""))
        }
    }
    
    // 商品情報取得に失敗した場合
    func request(_ request: SKRequest, didFailWithError error: Error) {
        delegate?.purchaseFail(message: NSLocalizedString("failpurchase", comment: ""))
        print("Error : \(String(describing: error.localizedDescription))")
    }
    
    private func doPurchase(_ product : SKProduct) {
        // 課金処理開始
        SKPaymentQueue.default().add(self)
        SKPaymentQueue.default().add(SKPayment(product: product))
    }
    
    func restore() {
        // リストア開始
        SKPaymentQueue.default().add(self)
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    // 課金処理のステータス更新
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in queue.transactions {
            switch transaction.transactionState {
            case .purchased:
                // 成功処理
                delegate?.purchaseSuccess(productIdentifier: transaction.payment.productIdentifier)
                queue.finishTransaction(transaction)
            case .restored:
                // リストア成功
                delegate?.restorePurchase(productIdentifier: transaction.payment.productIdentifier)
                queue.finishTransaction(transaction)
            case .deferred:
                // ファミリー共有待機処理
                delegate?.purchaseFail(message: NSLocalizedString("failpurchase", comment: ""))
                print("Error : \(String(describing: transaction.error?.localizedDescription))")
                queue.finishTransaction(transaction)
            case .failed:
                // 処理失敗
                delegate?.purchaseFail(message: NSLocalizedString("failpurchase", comment: ""))
                print("Error : \(String(describing: transaction.error?.localizedDescription))")
                queue.finishTransaction(transaction)
            case .purchasing:
                // 処理中
                break
            }
        }
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        delegate?.restoreSuccess()
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        delegate?.restoreFail(message: NSLocalizedString("failrestore", comment: ""))
        print("Error : \(String(describing: error.localizedDescription))")
    }
    
}

protocol PurchaseManagerDelegate {
    // 購入成功
    func purchaseSuccess(productIdentifier: String)
    // 購入失敗
    func purchaseFail(message: String)
    // リストア成功
    func restorePurchase(productIdentifier: String)
    // リストア成功
    func restoreSuccess()
    // リストア失敗
    func restoreFail(message: String)
}
