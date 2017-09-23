//
//  GraphViewController.swift
//  temperature
//
//  Created by 藤原 達郎 on 2017/08/20.
//  Copyright © 2017年 Tatsuo Fujiwara. All rights reserved.
//

import UIKit
import GoogleMobileAds

class GraphViewController: CommonAdsViewController {
    
    @IBOutlet var scrollView: UIScrollView!
    
    @IBOutlet var baseDateBtn: UIButton!
    
    @IBOutlet var graphView: TemperatureGraphView!
    
    @IBOutlet var segmentedControl: UISegmentedControl!
    
    @IBOutlet var pickerBaseView: UIView!
    
    @IBOutlet var datePicker: UIDatePicker!
    
    var baseDate = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // テストコード
        // scrollView.backgroundColor = UIColor.cyan
        
        segmentedControl.selectedSegmentIndex = ConfigManager.getGraphRangeType()
        
        baseDate = Date()
        baseDateBtn.setTitle(GraphViewController.getDateString(date: baseDate), for: .normal)
        
        // グラフを描画
        showGraphView()
        
        // ピッカーの初期化（非表示にして画面下に配置）
        closePicker()
        
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
    
    
    @IBAction func dateBackButton(_ sender: Any) {
        baseDate = Date(timeInterval: 60*60*24*(-1), since: baseDate)
        baseDateBtn.setTitle(GraphViewController.getDateString(date: baseDate), for: .normal)

        print("dateBackButton : \(baseDate.description)")
        
        showGraphView()
    }
    
    @IBAction func dateForwardButton(_ sender: Any) {
        baseDate = Date(timeInterval: 60*60*24*(1), since: baseDate)
        baseDateBtn.setTitle(GraphViewController.getDateString(date: baseDate), for: .normal)

        print("dateForwardButton : \(baseDate.description)")
        
        showGraphView()
    }
    
    @IBAction func specifyDateButton(_ sender: Any) {
        showDatePicker()
    }
    
    func showDatePicker() {
        // 現在の編集を終わらせる
        // endEditing()
        closePicker()
        
        // 広告ビューを隠す
        if gadBannerView != nil {
            gadBannerView.isHidden = true
        }
        
        datePicker.date = baseDate
        
        // TODO ピッカーに現在日に合わせる機能をつける
        
        // ピッカーをアニメーションで表示
        pickerBaseView.isHidden = false
        UIView.animate(withDuration: 0.3, delay: 0.0, options: [], animations: {
            self.pickerBaseView.frame = CGRect(x: self.pickerBaseView.frame.origin.x,
                                               y: self.pickerBaseView.frame.origin.y-self.pickerBaseView.frame.size.height,
                                               width: self.pickerBaseView.frame.size.width,
                                               height: self.pickerBaseView.frame.size.height)
        }, completion: nil)
        
    }

    func closePicker() {
        pickerBaseView.isHidden = true
        pickerBaseView.frame = CGRect(x: self.pickerBaseView.frame.origin.x,
                                      y: self.view.frame.size.height,
                                      width: self.pickerBaseView.frame.size.width,
                                      height: self.pickerBaseView.frame.size.height)
        
        // 広告ビューを復活
        if gadBannerView != nil {
            gadBannerView.isHidden = false
        }
    }
    

    
    
    
    @IBAction func pickerDoneButton(_ sender: Any) {
        baseDate = datePicker.date
        baseDateBtn.setTitle(GraphViewController.getDateString(date: baseDate), for: .normal)
        
        showGraphView()
        
        closePicker()
    }
    
    @IBAction func pickerCancelButton(_ sender: Any) {
        closePicker()
    }
    
    @IBAction func segmentedControlChanged(_ sender: Any) {
        ConfigManager.setGraphRangeType(graphRangeType: segmentedControl.selectedSegmentIndex)
        
        print("segmentedControlChanged")

        showGraphView()
    }
    
    func showGraphView() {
        // グラフビューに値をセット
        graphView.endDate = baseDate
        graphView.range = ConfigManager.getGraphRangeType() == 0 ? 3 : 7
        
        // グラフを再描画
        graphView.setNeedsDisplay()
    }
    
    static func getDateString(date: Date) -> String {
        let dateFormatter = DateFormatter()
        if(Utility.isJapaneseLocale()){
            dateFormatter.dateFormat = "M月d日(E)" // 日付フォーマットの設定
        } else {
            dateFormatter.dateFormat = "E, MMM d" // 日付フォーマットの設定
        }
        return dateFormatter.string(from: date)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        showGraphView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
