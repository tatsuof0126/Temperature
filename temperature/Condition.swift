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
    
    @objc dynamic var id: Int = 0
    @objc dynamic var langage: Int = 0
    @objc dynamic var condition: String = ""
    @objc dynamic var order: Int = 0
    
    convenience init(id: Int, langage: Int, condition: String, order: Int) {
        self.init()
        self.id = id
        self.langage = langage
        self.condition = condition
        self.order = order
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
            Condition(id: 1, langage: 0, condition: "鼻水", order: 10),
            Condition(id: 2, langage: 0, condition: "鼻づまり", order: 20),
            Condition(id: 3, langage: 0, condition: "せき", order: 30),
            Condition(id: 4, langage: 0, condition: "たんが出る", order: 40),
            Condition(id: 5, langage: 0, condition: "くしゃみ", order: 50),
            Condition(id: 6, langage: 0, condition: "のどが痛い", order: 60),
            Condition(id: 7, langage: 0, condition: "頭が痛い", order: 70),
            Condition(id: 8, langage: 0, condition: "体がだるい", order: 80),
            Condition(id: 9, langage: 0, condition: "体が痛い", order: 90),
            Condition(id: 10, langage: 0, condition: "寒気がする", order: 100),
            Condition(id: 11, langage: 0, condition: "お腹が痛い", order: 110),
            Condition(id: 12, langage: 0, condition: "下痢", order: 120),
            Condition(id: 13, langage: 0, condition: "嘔吐", order: 130),
            Condition(id: 14, langage: 0, condition: "吐き気", order: 140),
            Condition(id: 15, langage: 0, condition: "食欲がない", order: 150),
            Condition(id: 16, langage: 0, condition: "ゼーゼーする", order: 160),
            Condition(id: 17, langage: 0, condition: "呼吸が苦しい", order: 170),
            // 英語
            Condition(id: 1, langage: 1, condition: "Runny nose", order: 10), // 鼻水
            Condition(id: 2, langage: 1, condition: "Stuffy nose", order: 20), // 鼻づまり
            Condition(id: 3, langage: 1, condition: "Cough", order: 30), // せき
            Condition(id: 4, langage: 1, condition: "Sputum", order: 40), // たんが出る
            Condition(id: 5, langage: 1, condition: "Sneeze", order: 50), // くしゃみ
            Condition(id: 6, langage: 1, condition: "Sore throat", order: 60), // のどが痛い
            Condition(id: 7, langage: 1, condition: "Headache", order: 70), // 頭が痛い
            Condition(id: 8, langage: 1, condition: "Feel heavy", order: 80), // 体がだるい
            Condition(id: 9, langage: 1, condition: "Body pain", order: 90), // 体が痛い
            Condition(id: 10, langage: 1, condition: "Feel chills", order: 100), // 寒気がする
            Condition(id: 11, langage: 1, condition: "Stomach ache", order: 110), // お腹が痛い
            Condition(id: 12, langage: 1, condition: "Diarrhea", order: 120), // 下痢
            Condition(id: 13, langage: 1, condition: "Vomiting", order: 130), // 嘔吐
            Condition(id: 14, langage: 1, condition: "Feel nauseate", order: 140), // 吐き気
            Condition(id: 15, langage: 1, condition: "No appetite", order: 150), // 食欲がない
            Condition(id: 16, langage: 1, condition: "Wheezing", order: 160), // ゼーゼーする
            Condition(id: 17, langage: 1, condition: "Difficulty Breathing", order: 170) // 呼吸が苦しい
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
        
        let retList = realm.objects(Condition.self).filter("langage = \(langage)").sorted(byKeyPath: "order", ascending: true)
        
        return retList
    }
    
    
}
