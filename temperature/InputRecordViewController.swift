//
//  InputRecordViewController.swift
//  temperature
//
//  Created by 藤原 達郎 on 2017/08/20.
//  Copyright © 2017年 Tatsuo Fujiwara. All rights reserved.
//

import UIKit
import GoogleMobileAds

class InputRecordViewController: CommonAdsViewController, UITextFieldDelegate, UITextViewDelegate {
    
    @IBOutlet var scrollView: UIScrollView!
    
    @IBOutlet var timeLabel: UILabel!
    
    @IBOutlet var temperatureText: UITextField!
    
    @IBOutlet var conditionText: UITextView!
    
    @IBOutlet var memoTitle: UILabel!
    
    @IBOutlet var memoText: UITextView!
    
    @IBOutlet var conditionClearBtn: UIButton!
    
    var temperature: Temperature!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if temperature == nil {
            temperature = Temperature()
        }
        
        /*
        // テストデータ
        temperature.temperature = 36.9
        temperature.memo = "こんにちは"
        temperature.conditionList = [
            Condition(id: 1, condition: "鼻水"),
            Condition(id: 2, condition: "鼻づまり")
        ]
         */

    
        // 画面の初期値を設定
        var timeString: String = ""
        let dateFormatter = DateFormatter()
        if(Utility.isJapaneseLocale()){
            dateFormatter.dateFormat = "M月d日(E) H:mm" // 日付フォーマットの設定
        } else {
            dateFormatter.dateFormat = "E, MMM d h:mm a" // 日付フォーマットの設定
        }
        timeString = dateFormatter.string(from: temperature.date)
        timeLabel.text = timeString
        
        if temperature.temperature != 0.0 {
            temperatureText.text = temperature.temperature.description
        }
        
        setConditionString()
        
        memoText.text = temperature.memo
        
        
        // デフォルトで体温にフォーカス
        // TODO 既存データの更新だったらフォーカス当てない
        temperatureText.becomeFirstResponder()
        
        // メモTextViewを整形
        memoText.layer.borderWidth = 1
        memoText.layer.borderColor = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1.0).cgColor
        memoText.layer.cornerRadius = 8
        
        scrollView.contentSize = CGSize(width: 320, height: 680)
        
        makeGadBannerView(withTab: false)
    }
    
    override func adViewDidReceiveAd(_ bannerView: GADBannerView){
        if(gadLoaded == false){
            scrollView.frame = CGRect(origin: scrollView.frame.origin,
                                 size: CGSize(width: scrollView.frame.size.width, height: scrollView.frame.size.height-gadBannerView.frame.size.height))
        
            self.view.addSubview(gadBannerView)
            gadLoaded = true
        }
    }
    
    @IBAction func timeChangeButton(_ sender: Any) {
        
        
    }
    
    
    @IBAction func conditionClearButton(_ sender: Any) {
        temperature.conditionList = []
        setConditionString()
    }
    
    @IBAction func saveButton(_ sender: Any) {
        let retString = checkInput()
        if retString != "" {
            print("Error : \(retString)")
            
            // TODO ダイアログ表示
            return
        }
        
        let temperatureDouble: Double = NSString(string: temperatureText.text!).doubleValue
        temperature.temperature = temperatureDouble
        temperature.memo = memoText.text
        
        
        
        
        
        
        let delegate = UIApplication.shared.delegate as! AppDelegate
        delegate.showInterstitial(self)
    }
    
    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func checkInput() -> String {
        var retString = ""
        
        // 空チェック
        if (temperatureText.text == "" && temperature.conditionList.count == 0 &&
            memoText.text == "") {
            // TODO 多言語化
            retString.append("入力がありません。")
        }
        
        // 体温が数値かどうかチェック
        let temperatureDouble: Double = NSString(string: temperatureText.text!).doubleValue
        print("temperatureDouble : \(temperatureDouble)")
        if temperatureDouble == 0.0 {
            // TODO 多言語化
            retString.append("体温の入力が不正です。")
        }
        
        return retString
    }
    
    /*
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if (textField == temperatureText){
            textField.placeholder = textField.text
            textField.text = ""
        }
        return true
    }
    */
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if (textView == memoText){
            var adjustHeight:CGFloat = 20.0
            if(temperature.conditionList.count != 0){
                adjustHeight = conditionText.frame.size.height
            }
            scrollView.setContentOffset(CGPoint(x: 0, y: 125+adjustHeight), animated: true)
        }
        
        // ピッカーを閉じる
        
        
        // 編集済みにする
        // edited = YES;

    }
    
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if (textView == memoText){
            scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        }
    }
    
    @IBAction func onTap(_ sender: Any) {
        self.view.endEditing(true)
        // TODO ピッカーも閉じる
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setConditionString()
    }

    func setConditionString() {
        var conditionStr = ""
        
        for (index, condition) in temperature.conditionList.enumerated() {
            if index != 0 {
                conditionStr.append(", ")
            }
            conditionStr.append(condition.condition)
        }
        
        conditionText.text = conditionStr
        
        if temperature.conditionList.count == 0 {
            conditionClearBtn.isHidden = true
        } else {
            conditionClearBtn.isHidden = false
        }
        
        adjustLayout()
    }
    
    func adjustLayout() {
        // conditionTextのサイズ調整
        let size:CGSize = conditionText.sizeThatFits(conditionText.frame.size)
        conditionText.frame.size.height = size.height
        
        // Memoの場所を調整
        var adjustHeight:CGFloat = 0.0
        if(temperature.conditionList.count == 0){
            adjustHeight = 20
            conditionText.isHidden = true
        } else {
            adjustHeight = conditionText.frame.size.height
            conditionText.isHidden = false
        }
        
        memoTitle.frame.origin = CGPoint(x: 20, y: 155+adjustHeight-20)
        memoText.frame.origin = CGPoint(x: 20, y: 180+adjustHeight-20)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
