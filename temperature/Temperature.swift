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
    
    dynamic var personId: Int = 1
    
    dynamic var date: Date = Date()
    
    dynamic var temperature: Double = 0.0
    
    dynamic var useAntipyretic: Bool = false
    
    dynamic var useFahrenheit: Bool = false
    
    var conditionList = List<TemperatureCondition>()
    
    dynamic var memo: String = ""
    
    static func makeTestData(){
        let temperatureList = Temperature.getAllTemperature(ascending: false)
        if temperatureList.count >= 9 {
            // すでにデータが９件以上ある場合はテストデータ作成済みと見なして作成しない
            return
        }
        
        let condition1 = TemperatureCondition()
        condition1.id = 1
        condition1.langage = 0
        condition1.condition = "鼻水"
        
        let condition2 = TemperatureCondition()
        condition2.id = 5
        condition2.langage = 0
        condition2.condition = "くしゃみ"
        
        let condition3 = TemperatureCondition()
        condition3.id = 6
        condition3.langage = 0
        condition3.condition = "のどが痛い"
        
        var dateInt = 1511967600
        
        let temperature1 = Temperature()
        temperature1.setId()
        dateInt = 1511967600 + (60*60*24)*5 + (60*60)*9 + (60)*20
        temperature1.date = Date(timeIntervalSince1970:TimeInterval(dateInt))
        temperature1.temperature = 36.7
        
        let temperature2 = Temperature()
        temperature2.setId()
        dateInt = 1511967600 + (60*60*24)*5 + (60*60)*19 + (60)*00
        temperature2.date = Date(timeIntervalSince1970:TimeInterval(dateInt))
        temperature2.temperature = 37.0
        
        let temperature3 = Temperature()
        temperature3.setId()
        dateInt = 1511967600 + (60*60*24)*6 + (60*60)*7 + (60)*30
        temperature3.date = Date(timeIntervalSince1970:TimeInterval(dateInt))
        temperature3.temperature = 37.9
        temperature3.conditionList.append(condition2)
        temperature3.memo = "メモメモ"
        
        let temperature4 = Temperature()
        temperature4.setId()
        dateInt = 1511967600 + (60*60*24)*6 + (60*60)*14 + (60)*00
        temperature4.date = Date(timeIntervalSince1970:TimeInterval(dateInt))
        temperature4.temperature = 38.6
        
        let temperature5 = Temperature()
        temperature5.setId()
        dateInt = 1511967600 + (60*60*24)*6 + (60*60)*20 + (60)*10
        temperature5.date = Date(timeIntervalSince1970:TimeInterval(dateInt))
        temperature5.temperature = 39.3
        temperature5.conditionList.append(condition1)
        
        let temperature6 = Temperature()
        temperature6.setId()
        dateInt = 1511967600 + (60*60*24)*7 + (60*60)*7 + (60)*40
        temperature6.date = Date(timeIntervalSince1970:TimeInterval(dateInt))
        temperature6.temperature = 39.1
        temperature6.conditionList.append(condition1)
        temperature6.conditionList.append(condition3)
        temperature6.memo = "朝食はおかゆのみ"
        
        let temperature7 = Temperature()
        temperature7.setId()
        dateInt = 1511967600 + (60*60*24)*7 + (60*60)*11 + (60)*15
        temperature7.date = Date(timeIntervalSince1970:TimeInterval(dateInt))
        temperature7.temperature = 39.2
        temperature7.conditionList.append(condition3)
        
        let temperature8 = Temperature()
        temperature8.setId()
        dateInt = 1511967600 + (60*60*24)*7 + (60*60)*15 + (60)*00
        temperature8.date = Date(timeIntervalSince1970:TimeInterval(dateInt))
        temperature8.temperature = 38.9
        temperature8.conditionList.append(condition1)
        
        let temperature9 = Temperature()
        temperature9.setId()
        dateInt = 1511967600 + (60*60*24)*7 + (60*60)*20 + (60)*30
        temperature9.date = Date(timeIntervalSince1970:TimeInterval(dateInt))
        temperature9.temperature = 38.8
        
        /*
        let temperature10 = Temperature()
        temperature10.setId()
        dateInt = 1511967600 + (60*60*24)*5 + (60*60)*19 + (60)*00  // 12/5 19:00
        temperature10.date = Date(timeIntervalSince1970:TimeInterval(dateInt))
        temperature10.temperature = 38.5
        temperature10.conditionList.append(condition1)
        temperature10.conditionList.append(condition2)
        
        let temperature11 = Temperature()
        temperature11.setId()
        dateInt = 1511967600 + (60*60*24)*5 + (60*60)*19 + (60)*00  // 12/5 19:00
        temperature11.date = Date(timeIntervalSince1970:TimeInterval(dateInt))
        temperature11.temperature = 38.5
        temperature11.conditionList.append(condition1)
        temperature11.conditionList.append(condition2)
        
        let temperature12 = Temperature()
        temperature12.setId()
        dateInt = 1511967600 + (60*60*24)*5 + (60*60)*19 + (60)*00  // 12/5 19:00
        temperature12.date = Date(timeIntervalSince1970:TimeInterval(dateInt))
        temperature12.temperature = 38.5
        temperature12.conditionList.append(condition1)
        temperature12.conditionList.append(condition2)
        */
        
        let realm = try! Realm()
        try! realm.write {
            realm.add(temperature1, update: true)
            realm.add(temperature2, update: true)
            realm.add(temperature3, update: true)
            realm.add(temperature4, update: true)
            realm.add(temperature5, update: true)
            realm.add(temperature6, update: true)
            realm.add(temperature7, update: true)
            realm.add(temperature8, update: true)
            realm.add(temperature9, update: true)
            // realm.add(temperature10, update: true)
            // realm.add(temperature11, update: true)
            // realm.add(temperature12, update: true)
        }
        
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    static func getAllTemperature(ascending: Bool) -> Results<Temperature> {
        let realm = try! Realm()
        
        let retList = realm.objects(Temperature.self).sorted(byKeyPath: "date", ascending: ascending)
        
        return retList
    }
    
    static func getDateFilteredTemperature(date: NSDate, ascending: Bool) -> Results<Temperature> {
        // print("StartDate : \(date.description)")
        
        let realm = try! Realm()
        
        let retList = realm.objects(Temperature.self)
            .filter("date >= %@", date)
            .sorted(byKeyPath: "date", ascending: ascending)
        
        return retList
    }
    
    static func getDateFilteredTemperature(startDate: NSDate, endDate: NSDate,
                                           ascending: Bool) -> Results<Temperature> {
        // print("StartDate : \(startDate.description)")
        // print("EndDate : \(endDate.description)")
        
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
    }
    
    func getTemperatureDateNSAttributedString() -> NSAttributedString {
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
            dateFormatter.dateFormat = "E, MMM d  h:mm a" // 日付フォーマットの設定
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
