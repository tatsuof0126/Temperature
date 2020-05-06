//
//  ConfigViewController.swift
//  temperature
//
//  Created by 藤原 達郎 on 2017/08/19.
//  Copyright © 2017年 Tatsuo Fujiwara. All rights reserved.
//

import UIKit
import GoogleMobileAds

class ConfigViewController: CommonAdsViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    @IBOutlet var scrollView: UIScrollView!
    
    @IBOutlet var configTableView: UITableView!
    
    @IBOutlet var toAddressText: UITextField!
    
    @IBOutlet var useFahrenheitSwitch: UISwitch!
    
    @IBOutlet var versionLabel: UILabel!
    
    @IBOutlet var appStoreLabel: UILabel!
    
    static let menu = ["goremoveads"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        toAddressText.text = ConfigManager.getToAddress()
        
        if Utility.isJapaneseLocale() {
            toAddressText.placeholder = "メールアドレスを入力"
        }
        
        useFahrenheitSwitch.isOn = ConfigManager.isUseFahrenheit()
        
        // アプリ名とバージョンの表示
        let version: String? = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
        versionLabel.text = NSLocalizedString("appname", comment: "") + " ver" + version!
        
        // 他のアプリへのリンク
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onLinkTap))
        appStoreLabel.addGestureRecognizer(tapGestureRecognizer)
        
        makeGadBannerView(withTab: true)
    }
 
    override func adViewDidReceiveAd(_ bannerView: GADBannerView){
        if gadLoaded == false && ConfigManager.isShowAds() == true {
            scrollView.frame = CGRect(origin: scrollView.frame.origin,
                                  size: CGSize(width: scrollView.frame.size.width, height: scrollView.frame.size.height-gadBannerView.frame.size.height))
            self.view.addSubview(gadBannerView)
            gadLoaded = true
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "configcell")
        
        if ConfigManager.isShowAds() == true {
            cell.textLabel?.text = NSLocalizedString(ConfigViewController.menu[indexPath.row], comment: "")
        } else {
            cell.textLabel?.text = NSLocalizedString("gopurchase", comment: "")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ConfigViewController.menu.count
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath:IndexPath) {
        performSegue(withIdentifier: "inapppurchase", sender: nil)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == toAddressText {
            ConfigManager.setToAddress(toAddress: toAddressText.text!)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        // Returnキーで編集を終わらせる
        self.view.endEditing(true)
        return true
    }
    
    @IBAction func switchChanged(_ sender: Any) {
        ConfigManager.setUseFahrenheit(useFahrenheit: useFahrenheitSwitch.isOn)
    }
    
    @IBAction func onTap(_ sender: Any) {
        // 無関係の場所をタップされたら編集を終わらせる
        self.view.endEditing(true)
    }
    
    @objc func onLinkTap(gestureRecognizer: UITapGestureRecognizer) {
        let itunesURL:String = "itms-apps://itunes.apple.com/developer/tatsuo-fujiwara/id578136106"
        let url = URL(string:itunesURL)
        let app:UIApplication = UIApplication.shared
        app.openURL(url!)
    }
        
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if (configTableView.indexPathForSelectedRow != nil) {
            configTableView.deselectRow(at: configTableView.indexPathForSelectedRow!, animated: true)
        }
        configTableView.reloadData()
        
        if gadLoaded == true && ConfigManager.isShowAds() == false {
            scrollView.frame = CGRect(origin: scrollView.frame.origin,
                                      size: CGSize(width: scrollView.frame.size.width, height: scrollView.frame.size.height+gadBannerView.frame.size.height))
            gadBannerView.removeFromSuperview()
            gadLoaded = false
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
