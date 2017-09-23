//
//  PurchaseAddonViewController.swift
//  temperature
//
//  Created by 藤原 達郎 on 2017/08/26.
//  Copyright © 2017年 Tatsuo Fujiwara. All rights reserved.
//

import UIKit
import GoogleMobileAds

class PurchaseAddonViewController: CommonAdsViewController, UITableViewDelegate, UITableViewDataSource, PurchaseManagerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // fetchProductInformationForIds(["com.tatsuo.temperature.removeads"])
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return NSLocalizedString("purchaseaddon", comment: "")
        } else if section == 1 {
            return NSLocalizedString("purchaseduser", comment: "")
        }
        return ""
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else if section == 1 {
            return 1
        }
        return 2
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "purchasecell")
        
        var labelText = ""
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                labelText = NSLocalizedString("removeads2", comment: "")
            }
        } else if indexPath.section == 1 {
            if indexPath.row == 0 {
                labelText = NSLocalizedString("restoreaddon", comment: "")
            }
        }
        
        cell.textLabel?.text = labelText
        
        if indexPath.section == 0 && indexPath.row == 0 {
            // 広告削除アドオンを購入済みなら購入済みと表示
            cell.detailTextLabel?.text = ConfigManager.isShowAds() ? "" : NSLocalizedString("purchased", comment: "")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath:IndexPath) {
        print("Selected : \(indexPath.section)-\(indexPath.row)")
        
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                // 広告を削除
                startPurchase(productIdentifier: "com.tatsuo.temperature.removeads")
            }
        } else if indexPath.section == 1 {
            if indexPath.row == 0 {
                // 購入済みアドオンをリストア
                startRestore()
            }
        }
    }
    
    // 購入処理開始
    func startPurchase(productIdentifier: String) {
        print("購入処理開始!!")
        
        let purchaseManager = InAppPurchaseManager.getPurchaseManager()
        purchaseManager.delegate = self
        
        // プロダクト情報を取得
        InAppProductManager.productsWithProductIdentifiers(productIdentifiers: [productIdentifier],
                                                            completion: { (products, error) -> Void in
            
            print("productsWithProductIdentifiers completion")
            if (products?.count)! > 0 {
                //課金処理開始
                print("products?[0] : \(String(describing: products?[0].localizedTitle))")
                purchaseManager.startWithProduct((products?[0])!)
            }
            if (error != nil) {
                print("Error : \(String(describing: error?.description))")
            }
        })
    }
    
    // リストア開始
    func startRestore() {
        print("リストア処理開始!!")
        
        let purchaseManager = InAppPurchaseManager.getPurchaseManager()
        purchaseManager.delegate = self
        purchaseManager.startRestore()
    }
    
    //------------------------------------
    // MARK: - PurchaseManager Delegate
    //------------------------------------
    //課金終了時に呼び出される
    func purchaseManager(_ purchaseManager: InAppPurchaseManager!, didFinishPurchaseWithTransaction transaction: SKPaymentTransaction!, decisionHandler: ((_ complete: Bool) -> Void)!) {
        print("課金終了！！")
        //---------------------------
        // コンテンツ解放処理
        //---------------------------
        // TODO UserDefault更新
        //コンテンツ解放が終了したら、この処理を実行(true: 課金処理全部完了, false 課金処理中断)
        decisionHandler(true)
    }
    
    //課金終了時に呼び出される(startPurchaseで指定したプロダクトID以外のものが課金された時。)
    func purchaseManager(_ purchaseManager: InAppPurchaseManager!, didFinishUntreatedPurchaseWithTransaction transaction: SKPaymentTransaction!, decisionHandler: ((_ complete: Bool) -> Void)!) {
        print("課金終了（指定プロダクトID以外）！！")
        //---------------------------
        // コンテンツ解放処理
        //---------------------------
        //コンテンツ解放が終了したら、この処理を実行(true: 課金処理全部完了, false 課金処理中断)
        decisionHandler(true)
    }
    
    // 課金失敗時に呼び出される
    func purchaseManager(_ purchaseManager: InAppPurchaseManager!, didFailWithError error: NSError!) {
        print("課金失敗！！")
        // TODO errorを使ってアラート表示
    }
    
    // リストア終了時に呼び出される(個々のトランザクションは”課金終了”で処理)
    func purchaseManagerDidFinishRestore(_ purchaseManager: InAppPurchaseManager!) {
        print("リストア終了！！")
        // TODO インジケータなどを表示していたら非表示に
    }
    
    // 承認待ち状態時に呼び出される(ファミリー共有)
    func purchaseManagerDidDeferred(_ purchaseManager: InAppPurchaseManager!) {
        print("承認待ち！！")
        // TODO インジケータなどを表示していたら非表示に
    }
    
    /*
    // プロダクト情報取得
    fileprivate func fetchProductInformationForIds(_ productIds:[String]) {
        InAppProductManager.productsWithProductIdentifiers(productIdentifiers: productIds,completion: {[weak self] (products : [SKProduct]?, error : NSError?) -> Void in
            if error != nil {
                return
            }
            for product in products! {
                let priceString = InAppProductManager.priceStringFromProduct(product: product)
                if self != nil {
                    print(product.localizedTitle + ":\(priceString)")
                    // self?.priceLabel.text = product.localizedTitle + ":(priceString)"
                }
                print(product.localizedTitle + ":\(priceString)" )
            }
        })
    }
    */
    
    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
