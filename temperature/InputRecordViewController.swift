//
//  InputRecordViewController.swift
//  temperature
//
//  Created by 藤原 達郎 on 2017/08/20.
//  Copyright © 2017年 Tatsuo Fujiwara. All rights reserved.
//

import UIKit
import GoogleMobileAds
import RealmSwift

class InputRecordViewController: CommonAdsViewController, UITextFieldDelegate, UITextViewDelegate {
    
    @IBOutlet var scrollView: UIScrollView!
    
    @IBOutlet var timeLabel: UILabel!
    
    @IBOutlet var temperatureText: UITextField!
    
    @IBOutlet var unitsLabel: UILabel!
    
    @IBOutlet var conditionText: UITextView!
    
    @IBOutlet var memoTitle: UILabel!
    
    @IBOutlet var memoText: UITextView!
    
    @IBOutlet var conditionChangeBtn: UIButton!
    @IBOutlet var conditionClearBtn: UIButton!
    @IBOutlet var deleteBtn: UIButton!
    
    @IBOutlet var pickerBaseView: UIView!
    @IBOutlet var datePicker: UIDatePicker!
    
    var temperature: Temperature!
    var temperatureDate: Date!
    var conditionList: List<TemperatureCondition>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if temperature == nil {
            temperature = Temperature()
            temperature.personId = ConfigManager.getTargetPersonId()
            
            // 直近３日に記録があれば、症状を引き継ぐ
            let personId = ConfigManager.getTargetPersonId()
            let date3 = NSDate(timeInterval: 60*60*24*(-3), since: Date())
            let recent3List = Temperature.getDateFilteredTemperature(
                personId: personId, startDate: date3, endDate: NSDate(), ascending: false)
            if let recent3 = recent3List.first {
                for condition in recent3.conditionList {
                    temperature.conditionList.append(condition)
                }
            }
        }
        
        temperatureDate = temperature.date
        
        conditionList = List<TemperatureCondition>()
        for condition in temperature.conditionList {
            conditionList.append(condition)
        }
        
        
        // 画面の初期値を設定
        // 日時
        setTemperatureDate()
        
        // 体温
        if temperature.temperature != 0.0 {
            temperatureText.text = temperature.getTemperatureString(withUnit: false)
        }
        
        if ConfigManager.isUseFahrenheit() {
            unitsLabel.text = "°F"
        } else {
            unitsLabel.text = "°C"
        }
        
        // 症状
        showCondition()
        
        // メモ
        memoText.text = temperature.memo
        
        // メモTextViewを整形
        memoText.layer.borderWidth = 1
        memoText.layer.borderColor = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1.0).cgColor
        memoText.layer.cornerRadius = 8
        
        // 日本語と英語で場所を微調整
        if Utility.isJapaneseLocale() {
            temperatureText.frame = CGRect(x: 95, y: 61, width: 70, height: 30)
            unitsLabel.frame = CGRect(x: 171, y: 66, width: 20, height: 21)
            conditionChangeBtn.frame = CGRect(x: 90, y: 105, width: 60, height: 30)
            conditionClearBtn.frame = CGRect(x: 160, y: 105, width: 60, height: 30)
        } else {
            temperatureText.frame = CGRect(x: 135, y: 61, width: 70, height: 30)
            unitsLabel.frame = CGRect(x: 211, y: 66, width: 20, height: 21)
            conditionChangeBtn.frame = CGRect(x: 110, y: 105, width: 60, height: 30)
            conditionClearBtn.frame = CGRect(x: 180, y: 105, width: 60, height: 30)
        }
        
        scrollView.contentSize = CGSize(width: 320, height: 680)
        
        // 新規の場合はデフォルトで体温にフォーカス
        if temperature.id == "" {
            temperatureText.becomeFirstResponder()
            deleteBtn.isHidden = true
        }
        
        // ピッカーの初期化（非表示にして画面下に配置）
        closePicker()
        
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
        showDatePicker()
    }
    
    @IBAction func conditionClearButton(_ sender: Any) {
        conditionList = List<TemperatureCondition>()
        showCondition()
    }
    
    @IBAction func saveButton(_ sender: Any) {
        let retString = checkInput()
        if retString != "" {
            Utility.showAlert(controller: self, title: "", message: retString)
            return
        }
        
        // カンマはピリオドに変換
        let temperatureDouble: Double = NSString(string: Utility.commaToPeriod(orgString: temperatureText.text!)).doubleValue
        
        // let temperatureDouble: Double = NSString(string: temperatureText.text!).doubleValue
        
        let realm = try! Realm()
        try! realm.write {
            temperature.date = temperatureDate
            temperature.temperature = temperatureDouble

            temperature.conditionList.removeAll()
            for condition in conditionList {
                temperature.conditionList.append(condition)
            }
            
            temperature.memo = memoText.text
            temperature.useFahrenheit = ConfigManager.isUseFahrenheit()
            temperature.setId()
            realm.add(temperature, update: true)
        }
        
        let delegate = UIApplication.shared.delegate as! AppDelegate
        delegate.showInterstitialFlag = true
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func deleteButton(_ sender: Any) {
        let handler = {(action: UIAlertAction) -> Void in
            self.deleteTemperature()
        }
        Utility.showConfirmDialog(controller: self, title: "", message: NSLocalizedString("deleteconfirm", comment: ""), handler: handler)
    }
    
    func deleteTemperature() {
        let realm = try! Realm()
        try! realm.write {
            realm.delete(temperature)
        }
        
        let delegate = UIApplication.shared.delegate as! AppDelegate
        delegate.showInterstitialFlag = true
        
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func endEditing() {
        self.view.endEditing(true)
    }
    
    func showDatePicker() {
        // 現在の編集を終わらせる
        endEditing()
        closePicker()
        
        // 広告ビューを隠す
        if gadBannerView != nil {
            gadBannerView.isHidden = true
        }
        
        datePicker.date = temperatureDate
        
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
        temperatureDate = datePicker.date
        
        setTemperatureDate()

        closePicker()
    }
    
    @IBAction func pickerCancelButton(_ sender: Any) {
        closePicker()
    }
    
    func checkInput() -> String {
        var retString = ""
        
        // 空チェック
        if (temperatureText.text == "" && conditionList.count == 0 &&
            memoText.text == "") {
            retString.append(NSLocalizedString("noinput", comment: ""))
        }
        
        // 体温が数値かどうかチェック（カンマはピリオドに変換）
        let temperatureDouble: Double = NSString(string: Utility.commaToPeriod(orgString: temperatureText.text!)).doubleValue
        
        // let temperatureDouble: Double = NSString(string: temperatureText.text!).doubleValue
        
        if temperatureText.text != "" && temperatureDouble == 0.0 {
            retString.append(NSLocalizedString("invalidtemperature", comment: ""))
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

    func textFieldDidBeginEditing(_ textField: UITextField) {
        // ピッカーを閉じる
        closePicker()
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if (textView == memoText){
            var adjustHeight:CGFloat = 20.0
            if(conditionList.count != 0){
                adjustHeight = conditionText.frame.size.height
            }
            scrollView.setContentOffset(CGPoint(x: 0, y: 125+adjustHeight), animated: true)
        }
        
        // ピッカーを閉じる
        closePicker()
        
        // 編集済みにする
        // edited = YES;
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if (textView == memoText){
            scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        }
    }
    
    @IBAction func onTap(_ sender: Any) {
        // Picker起動中は処理しない
        if(pickerBaseView.isHidden == false){
            return
        }
        
        // 無関係の場所をタップされたら編集を終わらせ、ピッカーも閉じる
        endEditing()
        closePicker()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        showCondition()
    }

    func setTemperatureDate(){
        timeLabel.text = Temperature.getTemperatureDateString(date: temperatureDate)
    }
    
    func showCondition() {
        conditionText.text = Temperature.getConditionString(conditionList: conditionList)
        
        if conditionList.count == 0 {
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
        if(conditionList.count == 0){
            adjustHeight = 20
            conditionText.isHidden = true
        } else {
            adjustHeight = conditionText.frame.size.height
            conditionText.isHidden = false
        }
        
        memoTitle.frame.origin = CGPoint(x: 20, y: 155+adjustHeight-20)
        memoText.frame.origin = CGPoint(x: 20, y: 180+adjustHeight-20)
        
        // Deleteボタンの場所を調整
        deleteBtn.frame.origin = CGPoint(x: 245, y: 300+adjustHeight-20)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
