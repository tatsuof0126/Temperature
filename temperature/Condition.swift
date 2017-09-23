//
//  Condition.swift
//  temperature
//
//  Created by 藤原 達郎 on 2017/08/24.
//  Copyright © 2017年 Tatsuo Fujiwara. All rights reserved.
//

import Foundation
import RealmSwift

class Condition: Object {
    
    dynamic var id : Int = 0
    dynamic var langage : Int = 0
    dynamic var condition : String = ""
    
    convenience init(id: Int, langage: Int, condition: String) {
        self.init()
        self.id = id
        self.langage = langage
        self.condition = condition
    }
    
    static func checkConditionList() -> Bool {
        let realm = try! Realm()
        
        let retList = realm.objects(Condition.self)
        
        if retList.count > 0 {
            return true
        } else {
            return false
        }
    }
    
    static func makeDefaultConditionList() {
        let conditionList = [
            // 日本語
            Condition(id: 1, langage: 0, condition: "鼻水"),
            Condition(id: 2, langage: 0, condition: "鼻づまり"),
            Condition(id: 3, langage: 0, condition: "せき"),
            Condition(id: 4, langage: 0, condition: "たんが出る"),
            Condition(id: 5, langage: 0, condition: "くしゃみ"),
            Condition(id: 6, langage: 0, condition: "のどが痛い"),
            Condition(id: 7, langage: 0, condition: "頭が痛い"),
            Condition(id: 8, langage: 0, condition: "体がだるい"),
            Condition(id: 9, langage: 0, condition: "体が痛い"),
            Condition(id: 10, langage: 0, condition: "寒気がする"),
            Condition(id: 11, langage: 0, condition: "お腹が痛い"),
            Condition(id: 12, langage: 0, condition: "下痢"),
            Condition(id: 13, langage: 0, condition: "嘔吐"),
            Condition(id: 14, langage: 0, condition: "吐き気"),
            Condition(id: 15, langage: 0, condition: "食欲がない"),
            Condition(id: 16, langage: 0, condition: "ゼーゼーする"),
            Condition(id: 17, langage: 0, condition: "呼吸が苦しい"),
            // 英語
            Condition(id: 1, langage: 1, condition: "Runny nose"), // 鼻水
            Condition(id: 2, langage: 1, condition: "鼻づまり"),
            Condition(id: 3, langage: 1, condition: "せき"),
            Condition(id: 4, langage: 1, condition: "たんが出る"),
            Condition(id: 5, langage: 1, condition: "くしゃみ"),
            Condition(id: 6, langage: 1, condition: "のどが痛い"),
            Condition(id: 7, langage: 1, condition: "頭が痛い"),
            Condition(id: 8, langage: 1, condition: "体がだるい"),
            Condition(id: 9, langage: 1, condition: "体が痛い"),
            Condition(id: 10, langage: 1, condition: "寒気がする"),
            Condition(id: 11, langage: 1, condition: "お腹が痛い"),
            Condition(id: 12, langage: 1, condition: "Diarrhea"), // 下痢
            Condition(id: 13, langage: 1, condition: "嘔吐"),
            Condition(id: 14, langage: 1, condition: "吐き気"),
            Condition(id: 15, langage: 1, condition: "食欲がない"),
            Condition(id: 16, langage: 1, condition: "ゼーゼーする"),
            Condition(id: 17, langage: 1, condition: "呼吸が苦しい")
        ]
    
        let realm = try! Realm()
        
        try! realm.write {
            // 全件削除
            realm.deleteAll()
            
            // 登録
            conditionList.forEach {
                realm.add($0)
            }
        }
    }
    
    static func getConditionList() -> Results<Condition> {
        let realm = try! Realm()
        
        var langage: Int = 0
        if Utility.isJapaneseLocale() == true {
            langage = 0
        } else {
            langage = 1
        }
        
        let retList = realm.objects(Condition.self).filter("langage = \(langage)").sorted(byKeyPath: "id", ascending: true)
        
        return retList
    }
    
    
}
