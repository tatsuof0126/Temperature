//
//  ConfigViewController.swift
//  temperature
//
//  Created by 藤原 達郎 on 2017/08/19.
//  Copyright © 2017年 Tatsuo Fujiwara. All rights reserved.
//

import UIKit
import GoogleMobileAds

class ConfigViewController: CommonAdsViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var scrollView: UIScrollView!
    
    @IBOutlet var configTableView: UITableView!
    
    @IBOutlet var useFahrenheitSwitch: UISwitch!
    
    @IBOutlet var versionLabel: UILabel!
    
    static let menu = ["removeads"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        useFahrenheitSwitch.isOn = ConfigManager.isUseFahrenheit()
        
        // アプリ名とバージョンの表示
        let version: String? = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
        versionLabel.text = NSLocalizedString("appname", comment: "") + " ver" + version!
        
        
        
        
        
        
        makeGadBannerView(withTab: true)
    }
 
    override func adViewDidReceiveAd(_ bannerView: GADBannerView){
        if(gadLoaded == false){
            scrollView.frame = CGRect(origin: scrollView.frame.origin,
                                  size: CGSize(width: scrollView.frame.size.width, height: scrollView.frame.size.height-gadBannerView.frame.size.height))
            self.view.addSubview(gadBannerView)
            gadLoaded = true
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "configcell")
        
        cell.textLabel?.text = NSLocalizedString(ConfigViewController.menu[indexPath.row], comment: "")
        
        if indexPath.row == 0 {
            // 広告削除アドオンを購入済みなら購入済みと表示
            cell.detailTextLabel?.text = ConfigManager.isShowAds() ? "" : NSLocalizedString("purchased", comment: "")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ConfigViewController.menu.count
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath:IndexPath) {
        performSegue(withIdentifier: "inapppurchase", sender: nil)
    }
    
    @IBAction func switchChanged(_ sender: Any) {
        ConfigManager.setUseFahrenheit(useFahrenheit: useFahrenheitSwitch.isOn)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if (configTableView.indexPathForSelectedRow != nil) {
            configTableView.deselectRow(at: configTableView.indexPathForSelectedRow!, animated: true)
        }
        configTableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
