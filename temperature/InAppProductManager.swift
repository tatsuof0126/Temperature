//
//  InAppProductManager.swift
//  temperature
//
//  Created by 藤原 達郎 on 2017/09/22.
//  Copyright © 2017年 Tatsuo Fujiwara. All rights reserved.
//

import Foundation
import StoreKit

private var productManagers : Set<InAppProductManager> = Set()

class InAppProductManager : NSObject, SKProductsRequestDelegate {
    
    private var completionForProductidentifiers : (([SKProduct]?, NSError?) -> Void)?
    
    /// 課金アイテム情報を取得
    class func productsWithProductIdentifiers(productIdentifiers : [String]!,
                                              completion:(([SKProduct]?,NSError?) -> Void)?){
        
        print("productsWithProductIdentifiers start : \(productIdentifiers)")
        
        let productManager = InAppProductManager()
        productManager.completionForProductidentifiers = completion
        
        let productRequest = SKProductsRequest(productIdentifiers: Set(productIdentifiers))
        productRequest.delegate = productManager
        productRequest.start()
        productManagers.insert(productManager)
    }
    
    // MARK: - SKProducts Request Delegate
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        print("productsRequest didReceive")
        
        var error : NSError? = nil
        if response.products.count == 0 {
            error = NSError(domain: "ProductsRequestErrorDomain", code: 0, userInfo: [NSLocalizedDescriptionKey:"プロダクトを取得できませんでした。"])
        }
        completionForProductidentifiers?(response.products, error)
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        print("request didFailWithError")
        
        let error = NSError(domain: "ProductsRequestErrorDomain", code: 0, userInfo: [NSLocalizedDescriptionKey:"プロダクトを取得できませんでした。"])
        completionForProductidentifiers?(nil,error)
        productManagers.remove(self)
    }
    
    func requestDidFinish(_ request: SKRequest) {
        print("request requestDidFinish")
        
        productManagers.remove(self)
    }
    
    // MARK: - Utility
    // 価格情報を抽出
    class func priceStringFromProduct(product: SKProduct!) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.formatterBehavior = .behavior10_4
        numberFormatter.numberStyle = .currency
        numberFormatter.locale = product.priceLocale
        return numberFormatter.string(from: product.price)!
    }
    
}
