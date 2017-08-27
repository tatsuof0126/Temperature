//
//  Condition.swift
//  temperature
//
//  Created by 藤原 達郎 on 2017/08/24.
//  Copyright © 2017年 Tatsuo Fujiwara. All rights reserved.
//

import Foundation

class Condition {
    
    let id : Int
    let condition : String
    
    init(id: Int, condition: String) {
        self.id = id
        self.condition = condition
    }
    
    static func getConditionList() -> Array<Condition> {
        if Utility.isJapaneseLocale() == true {
            let retList = [
                Condition(id: 1, condition: "鼻水"),
                Condition(id: 2, condition: "鼻づまり"),
                Condition(id: 3, condition: "せき"),
                Condition(id: 4, condition: "たんが出る"),
                Condition(id: 5, condition: "くしゃみ"),
                Condition(id: 6, condition: "のどが痛い"),
                Condition(id: 7, condition: "頭が痛い"),
                Condition(id: 8, condition: "体がだるい"),
                Condition(id: 9, condition: "体が痛い"),
                Condition(id: 10, condition: "寒気がする"),
                Condition(id: 11, condition: "お腹が痛い"),
                Condition(id: 12, condition: "下痢"),
                Condition(id: 13, condition: "嘔吐"),
                Condition(id: 14, condition: "吐き気"),
                Condition(id: 15, condition: "食欲がない"),
                Condition(id: 16, condition: "ゼーゼーする"),
                Condition(id: 17, condition: "呼吸が苦しい")
            ]
            return retList
        } else {
            let retList = [
                Condition(id: 1, condition: "Runny nose"), // 鼻水
                Condition(id: 2, condition: "鼻づまり"),
                Condition(id: 3, condition: "せき"),
                Condition(id: 4, condition: "たんが出る"),
                Condition(id: 5, condition: "くしゃみ"),
                Condition(id: 6, condition: "のどが痛い"),
                Condition(id: 7, condition: "頭が痛い"),
                Condition(id: 8, condition: "体がだるい"),
                Condition(id: 9, condition: "体が痛い"),
                Condition(id: 10, condition: "寒気がする"),
                Condition(id: 11, condition: "お腹が痛い"),
                Condition(id: 12, condition: "Diarrhea"), // 下痢
                Condition(id: 13, condition: "嘔吐"),
                Condition(id: 14, condition: "吐き気"),
                Condition(id: 15, condition: "食欲がない"),
                Condition(id: 16, condition: "ゼーゼーする"),
                Condition(id: 17, condition: "呼吸が苦しい")
            ]
            return retList
        }
    }
    
    
}
