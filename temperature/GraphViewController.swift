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
        if gadLoaded == false && ConfigManager.isShowAds() == true {
            scrollView.frame = CGRect(origin: scrollView.frame.origin,
                                  size: CGSize(width: scrollView.frame.size.width, height: scrollView.frame.size.height-gadBannerView.frame.size.height))
        
            self.view.addSubview(gadBannerView)
            gadLoaded = true
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
        
        if gadLoaded == true && ConfigManager.isShowAds() == false {
            scrollView.frame = CGRect(origin: scrollView.frame.origin,
                                      size: CGSize(width: scrollView.frame.size.width, height: scrollView.frame.size.height+gadBannerView.frame.size.height))
            gadBannerView.removeFromSuperview()
            gadLoaded = false
        }
        
        showGraphView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
