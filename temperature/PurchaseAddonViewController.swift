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
    
    @IBOutlet var tableView: UITableView!
    
    var doingPurchase = false
    
    var indicatorView: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        indicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        indicatorView.hidesWhenStopped = true
        indicatorView.center = self.view.center
        self.view.addSubview(indicatorView)
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
                labelText = NSLocalizedString("removeads", comment: "")
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
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                // 広告を削除
                if ConfigManager.isShowAds() == true {
                    startPurchase(productIdentifier: "com.tatsuo.temperature.removeads")
                }
            }
        } else if indexPath.section == 1 {
            if indexPath.row == 0 {
                // 購入済みアドオンをリストア
                startRestore()
            }
        }

        tableView.deselectRow(at: tableView.indexPathForSelectedRow!, animated: false)
    }
    
    // 購入処理
    func startPurchase(productIdentifier: String) {
        print("購入処理開始")
        
        // tableView.deselectRow(at: tableView.indexPathForSelectedRow!, animated: false)
        
        if doingPurchase == true {
            return
        }
        doingPurchase = true
        
        // インジケーター
        indicatorView.startAnimating()
        
        // 購入処理を開始
        let purchaseManager = InAppPurchaseManager.getPurchaseManager()
        purchaseManager.delegate = self
        purchaseManager.purchase(productIdentifier: productIdentifier)
    }
    
    // リストア
    func startRestore() {
        print("リストア処理開始")
        
        // tableView.deselectRow(at: tableView.indexPathForSelectedRow!, animated: false)
        
        if doingPurchase == true {
            return
        }
        doingPurchase = true
        
        // インジケーター
        indicatorView.startAnimating()
        
        // リストア処理を開始
        let purchaseManager = InAppPurchaseManager.getPurchaseManager()
        purchaseManager.delegate = self
        purchaseManager.restore()
    }
    
    // 購入成功
    func purchaseSuccess(productIdentifier: String) {
        print("PurchaseSuccess : \(productIdentifier)")
        
        if productIdentifier == "com.tatsuo.temperature.removeads" {
            ConfigManager.setShowAds(showAds: false)
            
            Utility.showAlert(controller: self, title: NSLocalizedString("completepurchase", comment: ""),
                              message: NSLocalizedString("removedads", comment: ""))
        }
        doingPurchase = false
        indicatorView.stopAnimating()
        tableView.reloadData()
    }
    
    // 購入失敗
    func purchaseFail(message: String) {
        print("PurchaseFail : \(message)")
        
        Utility.showAlert(controller: self, title: "", message: message)
        doingPurchase = false
        indicatorView.stopAnimating()
        tableView.reloadData()
    }
    
    // リストア成功（復元した購入を反映）
    func restorePurchase(productIdentifier: String) {
        print("RestorePurchase : \(productIdentifier)")
        
        if productIdentifier == "com.tatsuo.temperature.removeads" &&
            ConfigManager.isShowAds() == true {
            ConfigManager.setShowAds(showAds: false)
            
            Utility.showAlert(controller: self, title: NSLocalizedString("donerestore", comment: ""),
                              message: NSLocalizedString("removedads", comment: ""))
        }
    }
    
    // リストア完了
    func restoreSuccess() {
        print("RestoreSuccess")
        
        Utility.showAlert(controller: self, title: "", message: NSLocalizedString("completerestore", comment: ""))
        doingPurchase = false
        indicatorView.stopAnimating()
        tableView.reloadData()
    }
    
    // リストア失敗
    func restoreFail(message: String) {
        print("RestoreFail")
        
        Utility.showAlert(controller: self, title: "", message: message)
        doingPurchase = false
        indicatorView.stopAnimating()
        tableView.reloadData()
    }
    
    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
