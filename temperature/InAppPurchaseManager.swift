//
//  InAppPurchaseManager.swift
//  temperature
//
//  Created by 藤原 達郎 on 2017/09/22.
//  Copyright © 2017年 Tatsuo Fujiwara. All rights reserved.
//

import Foundation
import StoreKit

private let purchaseManager = InAppPurchaseManager()

class InAppPurchaseManager : NSObject, SKPaymentTransactionObserver {
    
    var delegate : PurchaseManagerDelegate?
    fileprivate var productIdentifier : String?
    fileprivate var isRestore : Bool = false

    // シングルトン
    class func getPurchaseManager() -> InAppPurchaseManager {
        return purchaseManager;
    }
    
    // 課金開始
    func startWithProduct(_ product : SKProduct){
        print("startWithProduct : \(product.localizedTitle)")
        
        var errorCount = 0
        var errorMessage = ""
        
        if SKPaymentQueue.canMakePayments() == false {
            errorCount += 1
            errorMessage = "設定で購入が無効になっています。"
        }
        if self.productIdentifier != nil {
            errorCount += 10
            errorMessage = "課金処理中です。"
        }
        if self.isRestore == true {
            errorCount += 100
            errorMessage = "リストア中です。"
        }
        
        //エラーがあれば終了
        if errorCount > 0 {
            let error = NSError(domain: "PurchaseErrorDomain", code: errorCount, userInfo: [NSLocalizedDescriptionKey:errorMessage + "((errorCount))"])
            self.delegate?.purchaseManager?(self, didFailWithError: error)
            return
        }
        
        print("startWithProduct do : \(product.localizedTitle)")
        
        //未処理のトランザクションがあればそれを利用
        let transactions = SKPaymentQueue.default().transactions
        if transactions.count > 0 {
            for transaction in transactions {
                if transaction.transactionState != .purchased {
                    continue
                }
                if transaction.payment.productIdentifier == product.productIdentifier {
                    if let window = UIApplication.shared.delegate?.window {
                        let ac = UIAlertController(title: nil, message: "(product.localizedTitle)は購入処理が中断されていました。このまま無料でダウンロードできます。", preferredStyle: .alert)
                        let action = UIAlertAction(title: "続行", style: UIAlertActionStyle.default, handler: {[weak self] (action : UIAlertAction!) -> Void in
                            if let weakSelf = self {
                                weakSelf.productIdentifier = product.productIdentifier
                                weakSelf.completeTransaction(transaction)
                            }
                        })
                        ac.addAction(action)
                        window!.rootViewController?.present(ac, animated: true, completion: nil)
                        return
                    }
                }
            }
        }
        
        print("startWithProduct do2 : \(product.localizedTitle)")

        //課金処理開始
        let payment = SKMutablePayment(product: product)
        SKPaymentQueue.default().add(payment)
        self.productIdentifier = product.productIdentifier
    }
    
    // リストア開始
    func startRestore(){
        print("startRestore")
        
        if self.isRestore == false {
            print("self.isRestore == false")
            self.isRestore = true
            SKPaymentQueue.default().add(self)
            SKPaymentQueue.default().restoreCompletedTransactions()
        } else {
            let error = NSError(domain: "PurchaseErrorDomain", code: 0, userInfo: [NSLocalizedDescriptionKey:"リストア処理中です。"])
            self.delegate?.purchaseManager?(self, didFailWithError: error)
            print("error : \(error.description)")
        }
    }
    
    // MARK: - SKPaymentTransactionObserver
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        print("paymentQueue : \(transactions.description)")
        
        //課金状態が更新されるたびに呼ばれる
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchasing :
                //課金中
                break
            case .purchased :
                //課金完了
                self.completeTransaction(transaction)
                break
            case .failed :
                //課金失敗
                self.failedTransaction(transaction)
                break
            case .restored :
                //リストア
                self.restoreTransaction(transaction)
                break
            case .deferred :
                //承認待ち
                self.deferredTransaction(transaction)
                break
            }
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        print("paymentQueue restoreCompletedTransactionsFailedWithError")
        
        //リストア失敗時に呼ばれる
        self.delegate?.purchaseManager?(self, didFailWithError: error as NSError!)
        self.isRestore = false
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        print("paymentQueueRestoreCompletedTransactionsFinished")
        
        //リストア完了時に呼ばれる
        self.delegate?.purchaseManagerDidFinishRestore?(self)
        self.isRestore = false
    }
    
    // MARK: - SKPaymentTransaction process
    fileprivate func completeTransaction(_ transaction : SKPaymentTransaction) {
        print("completeTransaction")
        
        if transaction.payment.productIdentifier == self.productIdentifier {
            //課金終了
            self.delegate?.purchaseManager?(self, didFinishPurchaseWithTransaction: transaction, decisionHandler: { (complete) -> Void in
                if complete == true {
                    //トランザクション終了
                    SKPaymentQueue.default().finishTransaction(transaction)
                }
            })
            self.productIdentifier = nil
        } else {
            //課金終了(以前中断された課金処理)
            self.delegate?.purchaseManager?(self, didFinishUntreatedPurchaseWithTransaction: transaction,
                                            decisionHandler: { (complete) -> Void in
                if complete == true {
                    //トランザクション終了
                    SKPaymentQueue.default().finishTransaction(transaction)
                }
            })
        }
    }
    
    fileprivate func failedTransaction(_ transaction : SKPaymentTransaction) {
        print("failedTransaction")
        
        //課金失敗
        self.delegate?.purchaseManager?(self, didFailWithError: transaction.error as NSError!)
        self.productIdentifier = nil
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    fileprivate func restoreTransaction(_ transaction : SKPaymentTransaction) {
        print("restoreTransaction")
        
        //リストア(originalTransactionをdidFinishPurchaseWithTransactionで通知)　※設計に応じて変更
        self.delegate?.purchaseManager?(self, didFinishPurchaseWithTransaction: transaction.original, decisionHandler: { (complete) -> Void in
            if complete == true {
                //トランザクション終了
                SKPaymentQueue.default().finishTransaction(transaction)
            }
        })
    }
    
    fileprivate func deferredTransaction(_ transaction : SKPaymentTransaction) {
        print("deferredTransaction")
        
        //承認待ち
        self.delegate?.purchaseManagerDidDeferred?(self)
        self.productIdentifier = nil
    }
}

@objc protocol PurchaseManagerDelegate {
    //課金完了
    @objc optional func purchaseManager(_ purchaseManager: InAppPurchaseManager!,
                                        didFinishPurchaseWithTransaction transaction: SKPaymentTransaction!,
                                        decisionHandler: ((_ complete : Bool) -> Void)!)
    //課金完了(中断していたもの)
    @objc optional func purchaseManager(_ purchaseManager: InAppPurchaseManager!,
                                        didFinishUntreatedPurchaseWithTransaction transaction: SKPaymentTransaction!,
                                        decisionHandler: ((_ complete : Bool) -> Void)!)
    //リストア完了
    @objc optional func purchaseManagerDidFinishRestore(_ purchaseManager: InAppPurchaseManager!)
    //課金失敗
    @objc optional func purchaseManager(_ purchaseManager: InAppPurchaseManager!, didFailWithError error: NSError!)
    //承認待ち(ファミリー共有)
    @objc optional func purchaseManagerDidDeferred(_ purchaseManager: InAppPurchaseManager!)
}
