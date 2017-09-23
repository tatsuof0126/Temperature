//
//  Temperature.swift
//  temperature
//
//  Created by 藤原 達郎 on 2017/08/24.
//  Copyright © 2017年 Tatsuo Fujiwara. All rights reserved.
//

import Foundation
import RealmSwift

class Temperature: Object {
    
    dynamic var id: String = ""
    
    dynamic var date: Date = Date()
    
    dynamic var temperature: Double = 0.0
    
    dynamic var useFahrenheit: Bool = false
    
    var conditionList = List<TemperatureCondition>()
    
    dynamic var memo: String = ""
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    static func getAllTemperature(ascending: Bool) -> Results<Temperature> {
        let realm = try! Realm()
        
        let retList = realm.objects(Temperature.self).sorted(byKeyPath: "date", ascending: ascending)
        
        return retList
    }
    
    static func getDateFilteredTemperature(date: NSDate, ascending: Bool) -> Results<Temperature> {
        print("StartDate : \(date.description)")
        
        let realm = try! Realm()
        
        let retList = realm.objects(Temperature.self)
            .filter("date >= %@", date)
            .sorted(byKeyPath: "date", ascending: ascending)
        
        return retList
    }
    
    static func getDateFilteredTemperature(
        startDate: NSDate, endDate: NSDate, ascending: Bool) -> Results<Temperature> {
        print("StartDate : \(startDate.description)")
        print("EndDate : \(endDate.description)")
        
        let realm = try! Realm()
        
        let retList = realm.objects(Temperature.self)
            .filter("date >= %@", startDate)
            .filter("date <= %@", endDate)
            .sorted(byKeyPath: "date", ascending: ascending)
        
        return retList
    }
    
    func setId(){
        if id == "" {
            id = NSUUID().uuidString
        }
    }
    
    func getTemperatureDateString() -> String {
        return Temperature.getTemperatureDateString(date: date)
        /*
        let dateFormatter = DateFormatter()
        if(Utility.isJapaneseLocale()){
            dateFormatter.dateFormat = "M月d日(E) H:mm" // 日付フォーマットの設定
        } else {
            dateFormatter.dateFormat = "E, MMM d h:mm a" // 日付フォーマットの設定
        }
        return dateFormatter.string(from: date)
 */
    }
    
    func getTemperatureDateNSAttributedString() -> NSAttributedString {
        // TODO 土日は青赤にする
        return NSAttributedString(string: getTemperatureDateString())
    }
    
    func getTemperatureDouble() -> Double {
        let displayFahrenheit = ConfigManager.isUseFahrenheit()
        
        var retTemperature = temperature
        
        if displayFahrenheit == true && useFahrenheit == false {
            retTemperature = temperature * 9 / 5 + 32
        } else if displayFahrenheit == false && useFahrenheit == true {
            retTemperature = (temperature - 32) * 5 / 9
        }
        
        return retTemperature
    }
    
    func getTemperatureString(withUnit: Bool) -> String {
        let displayTemperature = String(format: "%.1f", getTemperatureDouble())
        
        let unitStr = ConfigManager.isUseFahrenheit() ? "°F" : "°C"
        
        if withUnit {
            return displayTemperature + unitStr
        } else {
            return displayTemperature
        }
    }
    
    func getTemperatureNSAttributedString() -> NSAttributedString {
        // 摂氏38.0度、華氏100.0度以上なら赤字にする
        var attr = [NSForegroundColorAttributeName: UIColor.black]
        if (useFahrenheit == false && temperature >= 38.0) ||
            (useFahrenheit == true && temperature >= 100.0){
            attr = [NSForegroundColorAttributeName: UIColor.red]
        }
        return NSAttributedString(string: getTemperatureString(withUnit: true), attributes: attr)
    }
        
    func getConditionString() -> String {
        return Temperature.getConditionString(conditionList: conditionList)
    }

    static func getTemperatureDateString(date: Date) -> String {
        let dateFormatter = DateFormatter()
        if(Utility.isJapaneseLocale()){
            dateFormatter.dateFormat = "M月d日(E) H:mm" // 日付フォーマットの設定
        } else {
            dateFormatter.dateFormat = "E, MMM d h:mm a" // 日付フォーマットの設定
        }
        return dateFormatter.string(from: date)
    }
    
    static func getConditionString(conditionList: List<TemperatureCondition>) -> String {
        var conditionStr = ""
        for (index, condition) in conditionList.enumerated() {
            if index != 0 {
                conditionStr.append(", ")
            }
            conditionStr.append(condition.condition)
        }
        return conditionStr
    }
    
}
