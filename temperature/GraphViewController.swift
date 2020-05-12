//
//  GraphViewController.swift
//  temperature
//
//  Created by 藤原 達郎 on 2017/08/20.
//  Copyright © 2017年 Tatsuo Fujiwara. All rights reserved.
//

import UIKit
import MessageUI
import GoogleMobileAds

class GraphViewController: CommonAdsViewController, MFMailComposeViewControllerDelegate {
    
    @IBOutlet var scrollView: UIScrollView!
    
    @IBOutlet var baseDateBtn: UIButton!
    
    @IBOutlet var graphView: TemperatureGraphView!
    
    @IBOutlet var segmentedControl: UISegmentedControl!
    
    @IBOutlet var pickerBaseView: UIView!
    
    @IBOutlet var datePicker: UIDatePicker!
    
    @IBOutlet var naviItem: UINavigationItem!
    
    var baseDate = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        segmentedControl.selectedSegmentIndex = ConfigManager.getGraphRangeType()
        
        baseDate = Date()
        baseDateBtn.setTitle(GraphViewController.getDateString(date: baseDate), for: .normal)
        
        // 画面タイトルに名前を表示
        showNaviItem()
        
        // グラフを描画
        showGraphView()
        
        // ピッカーの初期化（非表示にして画面下に配置）
        closePicker()
        
        // 画面のスワイプ設定
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(RecordListViewController.didSwipe(sender:)))
        rightSwipe.direction = .right
        scrollView.addGestureRecognizer(rightSwipe)
        
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(RecordListViewController.didSwipe(sender:)))
        leftSwipe.direction = .left
        scrollView.addGestureRecognizer(leftSwipe)
        
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
    
    func showNaviItem(){
        let personList = Person.getPersonList()
        if personList.count >= 2 || (personList.first?.name != Person.DEFAULT_NAME_GLOBAL && personList.first?.name !=  Person.DEFAULT_NAME_JAPAN ) {
            let person = Person.getPerson(personId: ConfigManager.getTargetPersonId())
            if Utility.isJapaneseLocale() && person.name != Person.DEFAULT_NAME_JAPAN {
                naviItem.title = person.name + "さん"
            } else {
                naviItem.title = person.name
            }
        } else {
            naviItem.title = NSLocalizedString("graph", comment: "")
        }
    }
    
    @objc func didSwipe(sender: UISwipeGestureRecognizer) {
        let personList = Person.getPersonList()
        let targetPersonId = ConfigManager.getTargetPersonId()
        var targetPersonIndex = -99
        
        for (i, person) in personList.enumerated() {
            if person.id == targetPersonId {
                targetPersonIndex = i
            }
        }
        
        if personList.count <= 1 || targetPersonIndex == -99 {
            return
        }
        
        var changed = false
        if sender.direction == .left {
            if targetPersonIndex < (personList.count-1) {
                targetPersonIndex += 1
                changed = true
            }
        } else if sender.direction == .right {
            if targetPersonIndex > 0 {
                targetPersonIndex -= 1
                changed = true
            }
        }
        
        if changed == true {
            ConfigManager.setTargetPersonId(personId: personList[targetPersonIndex].id)
            showNaviItem()
            showGraphView()
        }
        
    }
    
    @IBAction func sendButton(_ sender: Any) {
        let alert = UIAlertController(title: NSLocalizedString("sendgraph", comment: ""),
                                      message: NSLocalizedString("selectmethod", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
        
        let action1 = UIAlertAction(title: NSLocalizedString("sendbyline", comment: ""), style: UIAlertActionStyle.default, handler: {
            (action: UIAlertAction!) in
            self.sendToLine()
        })
        
        let action2 = UIAlertAction(title: NSLocalizedString("sendbymail", comment: ""), style: UIAlertActionStyle.default, handler: {
            (action: UIAlertAction!) in
            self.sendToMail()
        })
        
        let cancel = UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: UIAlertActionStyle.cancel, handler: nil)
        
        alert.addAction(action1)
        alert.addAction(action2)
        alert.addAction(cancel)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func sendToLine(){
        // LINEに送る画像を取得（GraphViewの内容）
        let image = graphView.getScreenShot()
        
        let pasteBoard = UIPasteboard.general
        pasteBoard.image = image
        
        let lineSchemeImage = "line://msg/image/%@"
        let scheme = String(format: lineSchemeImage, pasteBoard.name as CVarArg)
        let sendURL: URL! = URL(string: scheme)
        
        if UIApplication.shared.canOpenURL(sendURL) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(sendURL, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(sendURL)
            }
        } else {
            Utility.showAlert(controller: self, title: "",
                              message: NSLocalizedString("sendfailline", comment: ""))
        }
    }
    
    func sendToMail() {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            
            mail.setToRecipients([ConfigManager.getToAddress()])
            mail.setSubject(NSLocalizedString("graphmailsubject", comment: ""))
            mail.setMessageBody(NSLocalizedString("graphmailbody", comment: ""), isHTML: false)
            
            let image = graphView.getScreenShot()
            let imageData = UIImageJPEGRepresentation(image, 1.0)!
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMdd"
            let mmdd = dateFormatter.string(from: Date())
            let filename = "temperaturegraph"+mmdd+".png"
            
            mail.addAttachmentData(imageData, mimeType: "image/png", fileName: filename)
            
            present(mail, animated: true, completion: nil)
        } else {
            Utility.showAlert(controller: self, title: "",
                              message: NSLocalizedString("sendfailmail", comment: ""))
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController,
                               didFinishWith result: MFMailComposeResult, error: Error?) {
        dismiss(animated: true, completion: nil)

        if result == .sent {
            Utility.showAlert(controller: self, title: "",
                              message: NSLocalizedString("sendcomplete", comment: ""))
        }
    }
    
    @IBAction func dateBackButton(_ sender: Any) {
        baseDate = Date(timeInterval: 60*60*24*(-1), since: baseDate)
        baseDateBtn.setTitle(GraphViewController.getDateString(date: baseDate), for: .normal)

        showGraphView()
    }
    
    @IBAction func dateForwardButton(_ sender: Any) {
        baseDate = Date(timeInterval: 60*60*24*(1), since: baseDate)
        baseDateBtn.setTitle(GraphViewController.getDateString(date: baseDate), for: .normal)

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
        showGraphView()
    }
    
    func showGraphView() {
        // グラフビューに値をセット
        graphView.endDate = baseDate
        graphView.rangeType = ConfigManager.getGraphRangeType()
        graphView.range = ConfigManager.getGraphRange()
        
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
        
        if gadLoaded == true && ConfigManager.isShowAds() == false {
            scrollView.frame = CGRect(origin: scrollView.frame.origin,
                                      size: CGSize(width: scrollView.frame.size.width, height: scrollView.frame.size.height+gadBannerView.frame.size.height))
            gadBannerView.removeFromSuperview()
            gadLoaded = false
        }
        
        showNaviItem()
        showGraphView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
