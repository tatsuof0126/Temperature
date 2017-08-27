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
    
    @IBOutlet var versionLabel: UILabel!
    
    static let menu = ["removeads"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "configcell")
        cell.textLabel?.text = NSLocalizedString(ConfigViewController.menu[indexPath.row], comment: "")
        cell.detailTextLabel?.text = NSLocalizedString("purchased", comment: "")
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ConfigViewController.menu.count
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath:IndexPath) {
        performSegue(withIdentifier: "inapppurchase", sender: nil)
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
