//
//  PeopleListViewController.swift
//  temperature
//
//  Created by 藤原 達郎 on 2018/02/18.
//  Copyright © 2018年 Tatsuo Fujiwara. All rights reserved.
//

import UIKit
import GoogleMobileAds
import RealmSwift

class PeopleListViewController: CommonAdsViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var editBtn: UIBarButtonItem!
    @IBOutlet var addBtn: UIBarButtonItem!
    
    @IBOutlet var infoLabel1: UILabel!
    @IBOutlet var infoLabel2: UILabel!
    
    var personList: [Person]!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        personList = Person.getPersonList()
        // Personがなければ作る（念のため）
        if personList.count == 0 {
            Person.makeDefaultPerson()
            personList = Person.getPersonList()
        }
        
        makeGadBannerView(withTab: true)
    }

    override func adViewDidReceiveAd(_ bannerView: GADBannerView){
        if gadLoaded == false && ConfigManager.isShowAds() == true {
            tableView.frame = CGRect(origin: tableView.frame.origin,
                                     size: CGSize(width: tableView.frame.size.width, height: tableView.frame.size.height-gadBannerView.frame.size.height))
            
            self.view.addSubview(gadBannerView)
            gadLoaded = true
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return personList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "peoplecell")
        
        cell.textLabel?.text = personList[indexPath.row].name
        
        let targetPersonId = ConfigManager.getTargetPersonId()
        if personList[indexPath.row].id == targetPersonId {
            cell.accessoryType = .checkmark
            cell.editingAccessoryType = .checkmark
        } else {
            cell.accessoryType = .none
            cell.editingAccessoryType = .none
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath:IndexPath) {
        if tableView.isEditing == true {
            let alert = UIAlertController(title:NSLocalizedString("editperson", comment: ""), message:NSLocalizedString("editpersonbody", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
            alert.addTextField(configurationHandler: {(textField: UITextField!) -> Void in
                textField.text = self.personList[indexPath.row].name
                textField.font = UIFont.systemFont(ofSize: 18.0)
                textField.textAlignment = .center
            })
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("ok", comment: ""),
                style: UIAlertActionStyle.default, handler: {(action: UIAlertAction) -> Void in
                    let textField: UITextField = alert.textFields!.first!
                    let name = textField.text!
                    if name != "" {
                        let person = self.personList[indexPath.row]
                        let realm = try! Realm()
                        try! realm.write {
                            person.name = textField.text!
                            realm.add(person, update: true)
                        }
                        self.updateTableView()
                    }
            }))
            alert.addAction(UIAlertAction(title: NSLocalizedString("cancel", comment: ""),
                                          style: UIAlertActionStyle.cancel))
            
            self.present(alert, animated: true, completion: nil)
        } else {
            let targetPersonId = personList[indexPath.row].id
            ConfigManager.setTargetPersonId(personId: targetPersonId)
            updateTableView()
        }
        
        if (tableView.indexPathForSelectedRow != nil) {
            tableView.deselectRow(at: tableView.indexPathForSelectedRow!, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let targetPersonId = ConfigManager.getTargetPersonId()
        if personList[indexPath.row].id == targetPersonId {
            return false
        }
        
        return true
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        if tableView.isEditing {
            return .delete
        }
        return .none
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        let targetPerson = personList[indexPath.row]
        let message = String(format: NSLocalizedString("deletepersonbody", comment: ""), targetPerson.name)
        
        Utility.showConfirmDialog(controller: self, title: "", message: message,
                                  handler: {(action: UIAlertAction) -> Void in
            self.deletePerson(targetRow: indexPath.row)
        })
    }
    
    func deletePerson(targetRow: Int) {
        // Personを削除
        let targetPerson = personList[targetRow]
        let targetPersonId = targetPerson.id
        let realm = try! Realm()
        try! realm.write {
            realm.delete(targetPerson)
        }
        
        // ひもづく体温データも削除
        let temperatureList = Temperature.getAllTemperature(personId: targetPersonId, ascending: true)
        for temperature in temperatureList {
            for condition in temperature.conditionList {
                let realm = try! Realm()
                try! realm.write {
                    realm.delete(condition)
                }
            }
            
            let realm = try! Realm()
            try! realm.write {
                realm.delete(temperature)
            }
        }
        
        personList = Person.getPersonList()
        updateTableView()
    }

    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath,
                   to destinationIndexPath: IndexPath) {
        let targetPerson = personList[sourceIndexPath.row]
        if let index = personList.index(of: targetPerson) {
            personList.remove(at: index)
            personList.insert(targetPerson, at: destinationIndexPath.row)
        }
        
        // orderを採番しなおして保存
        var order = 1
        for person in personList {
            let realm = try! Realm()
            try! realm.write {
                person.order = order
                realm.add(person, update: true)
            }
            order += 1
        }
        
        updateTableView()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func editButton(_ sender: Any) {
        if tableView.isEditing == true {
            tableView.isEditing = false
            editBtn.title = NSLocalizedString("edit", comment: "")
        } else {
            tableView.isEditing = true
            editBtn.title = NSLocalizedString("done", comment: "")
        }
    }
    
    @IBAction func addButton(_ sender: Any) {
        if tableView.isEditing == true {
            return
        }
        
        let alert = UIAlertController(title:NSLocalizedString("addperson", comment: ""), message:NSLocalizedString("addpersonbody", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
        alert.addTextField(configurationHandler: {(textField: UITextField!) -> Void in
            textField.font = UIFont.systemFont(ofSize: 18.0)
            textField.textAlignment = .center
        })
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("ok", comment: ""),
            style: UIAlertActionStyle.default, handler: {(action: UIAlertAction) -> Void in
                let textField: UITextField = alert.textFields!.first!
                self.addPerson(name: textField.text!)
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("cancel", comment: ""),
                                      style: UIAlertActionStyle.cancel))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func addPerson(name: String) {
        if name == "" {
            return
        }
        
        let personList = Person.getPersonList()
        var maxId = 0
        var maxOrder = 0
        for person in personList {
            if person.id > maxId {
                maxId = person.id
            }
            if person.order > maxOrder {
                maxOrder = person.order
            }
        }
        
        let person = Person(id: maxId+1, name: name, order: maxOrder+1)
        let realm = try! Realm()
        try! realm.write {
            realm.add(person, update: true)
        }
        
        self.personList = Person.getPersonList()
        updateTableView()
    }

    func updateTableView(){
        tableView.reloadData()
        if personList.count >= 6 {
            infoLabel1.isHidden = true
            infoLabel2.isHidden = true
        } else {
            infoLabel1.isHidden = false
            infoLabel2.isHidden = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if gadLoaded == true && ConfigManager.isShowAds() == false {
            tableView.frame = CGRect(origin: tableView.frame.origin,
                                     size: CGSize(width: tableView.frame.size.width,
                                                  height: tableView.frame.size.height+gadBannerView.frame.size.height))
            gadBannerView.removeFromSuperview()
            gadLoaded = false
        }
        
        if (tableView.indexPathForSelectedRow != nil) {
            tableView.deselectRow(at: tableView.indexPathForSelectedRow!, animated: true)
        }
        
        updateTableView()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        // 編集モードから抜ける
        tableView.isEditing = false
        editBtn.title = NSLocalizedString("edit", comment: "")
    }
    
}
