//
//  RecordListViewController.swift
//  temperature
//
//  Created by 藤原 達郎 on 2017/08/20.
//  Copyright © 2017年 Tatsuo Fujiwara. All rights reserved.
//

import UIKit
import GoogleMobileAds
import RealmSwift

class RecordListViewController: CommonAdsViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var segmentedControl: UISegmentedControl!
    
    @IBOutlet var tableView: UITableView!
    
    var temperatureList: Results<Temperature>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        segmentedControl.selectedSegmentIndex = ConfigManager.getRecordListType()
        
        // TODO 複数人対応？
        
        // loadTemperatureData()
        
        makeGadBannerView(withTab: true)
    }
    
    func loadTemperatureData(){
        if segmentedControl.selectedSegmentIndex == 0 {
            let date7 = NSDate(timeInterval: 60*60*24*(-7), since: Date())
            temperatureList = Temperature.getDateFilteredTemperature(date: date7, ascending: false)
        } else if segmentedControl.selectedSegmentIndex == 1 {
            let date30 = NSDate(timeInterval: 60*60*24*(-30), since: Date())
            temperatureList = Temperature.getDateFilteredTemperature(date: date30, ascending: false)
        } else if segmentedControl.selectedSegmentIndex == 2 {
            temperatureList = Temperature.getAllTemperature(ascending: false)
        }
    }
    
    override func adViewDidReceiveAd(_ bannerView: GADBannerView){
        if(gadLoaded == false){
            tableView.frame = CGRect(origin: tableView.frame.origin,
                                  size: CGSize(width: tableView.frame.size.width, height: tableView.frame.size.height-gadBannerView.frame.size.height))
        
            self.view.addSubview(gadBannerView)
            gadLoaded = true
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "recordlistcell")
        
        let temperature = temperatureList[indexPath.row]
        
        let labelStr = NSMutableAttributedString()
        labelStr.append(temperature.getTemperatureDateNSAttributedString())
        labelStr.append(NSAttributedString(string: "  "))
        if temperature.temperature != 0.0 {
            labelStr.append(temperature.getTemperatureNSAttributedString())
        }
        
        cell.textLabel?.attributedText = labelStr
        
        let detailLabelStr = NSMutableString()
        if temperature.conditionList.count > 0 {
            detailLabelStr.append(" ")
            detailLabelStr.append(temperature.getConditionString())
        }
        if temperature.memo != "" {
            detailLabelStr.append(" ")
            detailLabelStr.append(NSLocalizedString("withmemo", comment: ""))
        }
        
        cell.detailTextLabel?.text = detailLabelStr as String
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return temperatureList.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath:IndexPath) {
        performSegue(withIdentifier: "updaterecord", sender: nil)
    }
    
    @IBAction func segmentedControlChanged(_ sender: Any) {
        ConfigManager.setRecordListType(recordListType: segmentedControl.selectedSegmentIndex)
        loadTemperatureData()
        tableView.reloadData()
    }
    
    @IBAction func addButton(_ sender: Any) {
        performSegue(withIdentifier: "addrecord", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "addrecord") {
            let inputController = segue.destination as? InputRecordViewController
            inputController?.temperature = nil
        } else if segue.identifier == "updaterecord" {
            let row = tableView.indexPathForSelectedRow!.row
            let temperature = temperatureList[row]
            
            let inputController = segue.destination as? InputRecordViewController
            inputController?.temperature = temperature
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (tableView.indexPathForSelectedRow != nil) {
            tableView.deselectRow(at: tableView.indexPathForSelectedRow!, animated: true)
        }
        
        loadTemperatureData()
        tableView.reloadData()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let delegate = UIApplication.shared.delegate as! AppDelegate
        if delegate.showInterstitialFlag {
            delegate.showInterstitial(self)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
