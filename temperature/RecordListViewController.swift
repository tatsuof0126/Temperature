//
//  RecordListViewController.swift
//  temperature
//
//  Created by 藤原 達郎 on 2017/08/20.
//  Copyright © 2017年 Tatsuo Fujiwara. All rights reserved.
//

import UIKit
import MessageUI
import GoogleMobileAds
import RealmSwift

class RecordListViewController: CommonAdsViewController, UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate {
    
    @IBOutlet var segmentedControl: UISegmentedControl!
    
    @IBOutlet var tableView: UITableView!
    
    @IBOutlet var baseView: UIView!
    
    @IBOutlet var infoLabel1: UILabel!
    @IBOutlet var infoLabel2: UILabel!
    
    var temperatureList: Results<Temperature>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        segmentedControl.selectedSegmentIndex = ConfigManager.getRecordListType()
        
        // Personが空だったら作る
        let personList = Person.getPersonList()
        if personList.count == 0 {
            Person.makeDefaultPerson()
        }
        
        // TODO ヘッダーに名前を出す
        
        
        
        
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
        if gadLoaded == false && ConfigManager.isShowAds() == true {
            baseView.frame = CGRect(origin: baseView.frame.origin,
                                     size: CGSize(width: baseView.frame.size.width, height: baseView.frame.size.height-gadBannerView.frame.size.height))
            
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
        showInfoLabel()
        tableView.reloadData()
    }
    
    func showInfoLabel() {
        if temperatureList.count == 0 {
            infoLabel1.isHidden = false;
            infoLabel2.isHidden = false;
        } else {
            infoLabel1.isHidden = true;
            infoLabel2.isHidden = true;
        }
    }
    
    @IBAction func sendButton(_ sender: Any) {
        let alert = UIAlertController(title: NSLocalizedString("sendrecord", comment: ""),
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
        // LINEに送る画像を取得（TableViewの内容）
        let image = baseView.getScreenShot()
        
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
            mail.setSubject(NSLocalizedString("recordmailsubject", comment: ""))
            mail.setMessageBody(NSLocalizedString("recordmailbody", comment: ""), isHTML: false)
            
            let image = baseView.getScreenShot()
            let imageData = UIImageJPEGRepresentation(image, 1.0)!
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMdd"
            let mmdd = dateFormatter.string(from: Date())
            let filename = "temperaturerecord"+mmdd+".png"
            
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
        
        if gadLoaded == true && ConfigManager.isShowAds() == false {
            baseView.frame = CGRect(origin: baseView.frame.origin,
                                     size: CGSize(width: baseView.frame.size.width,
                                                  height: baseView.frame.size.height+gadBannerView.frame.size.height))
            tableView.frame = CGRect(origin: tableView.frame.origin,
                                      size: CGSize(width: tableView.frame.size.width,
                                                   height: tableView.frame.size.height+gadBannerView.frame.size.height))
            gadBannerView.removeFromSuperview()
            gadLoaded = false
        }
        
        if (tableView.indexPathForSelectedRow != nil) {
            tableView.deselectRow(at: tableView.indexPathForSelectedRow!, animated: true)
        }
        
        loadTemperatureData()
        showInfoLabel()
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
