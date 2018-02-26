//
//  Person.swift
//  temperature
//
//  Created by 藤原 達郎 on 2018/02/18.
//  Copyright © 2018年 Tatsuo Fujiwara. All rights reserved.
//

import Foundation
import RealmSwift

class Person: Object {
    
    @objc dynamic var id: Int = 0
    @objc dynamic var name: String = ""
    @objc dynamic var order: Int = 0
    
    static let DEFAULT_NAME_GLOBAL = "You"
    static let DEFAULT_NAME_JAPAN  = "あなた"
    
    convenience init(id: Int, name: String, order: Int) {
        self.init()
        self.id = id
        self.name = name
        self.order = order
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    static func makeDefaultPerson() {
        var name = DEFAULT_NAME_GLOBAL
        if Utility.isJapaneseLocale() == true {
            name = DEFAULT_NAME_JAPAN
        }
        
        let person = Person(id: 1, name: name, order: 1)

        let realm = try! Realm()
        try! realm.write {
            realm.add(person, update: true)
        }
    }
    
    static func getPerson(personId: Int) -> Person {
        let realm = try! Realm()
        
        let retList = realm.objects(Person.self)
            .filter("id = %d", personId)
        
        if retList.count >= 1 {
            return retList.first!
        } else {
            return Person()
        }
    }
    
    static func getPersonList() -> [Person] {
        let realm = try! Realm()
        
        let resultList = realm.objects(Person.self).sorted(byKeyPath: "order", ascending: true)
        
        return Array(resultList)
    }
    
}
