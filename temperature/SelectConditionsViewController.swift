//
//  SelectConditionsViewController.swift
//  temperature
//
//  Created by 藤原 達郎 on 2017/08/24.
//  Copyright © 2017年 Tatsuo Fujiwara. All rights reserved.
//

import UIKit
import GoogleMobileAds
import RealmSwift

class SelectConditionsViewController: CommonAdsViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableView: UITableView!
    
    var conditionList: Results<Condition>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        conditionList = Condition.getConditionList()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.setEditing(true, animated: false)
        
        makeGadBannerView(withTab: false)
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
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "selectconditioncell")
        cell.textLabel?.text = conditionList[indexPath.row].condition
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conditionList.count
    }
    
    @IBAction func okButton(_ sender: Any) {
        var conditionIds:[Int] = []
        
        if let indexPaths = tableView.indexPathsForSelectedRows {
            for indexPath in indexPaths {
                conditionIds.append(indexPath.row)
            }
        }
        // 選択した症状を上から並び替え
        conditionIds = conditionIds.sorted { $0 < $1 }
        
        let retConditionList = List<TemperatureCondition>()
        conditionIds.forEach {
            let temperatureCondition = TemperatureCondition()
            temperatureCondition.id = conditionList[$0].id
            temperatureCondition.langage = conditionList[$0].langage
            temperatureCondition.condition = conditionList[$0].condition
            retConditionList.append(temperatureCondition)
        }
        
        let inputView: InputRecordViewController = self.presentingViewController as! InputRecordViewController
        inputView.conditionList = retConditionList
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        // TableViewの初期選択状態を設定
        let inputView: InputRecordViewController = self.presentingViewController as! InputRecordViewController
        
        for selectCondition in inputView.conditionList {
            for (index, condition) in conditionList.enumerated() {
                if(selectCondition.id == condition.id){
                    let indexPath: IndexPath = IndexPath(row: index, section: 0)
                    tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
