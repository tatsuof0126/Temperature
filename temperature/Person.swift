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
        var name = "You"
        if Utility.isJapaneseLocale() == true {
            name = "あなた"
        }
        
        let person = Person(id: 1, name: name, order: 1)

        let realm = try! Realm()
        try! realm.write {
            realm.add(person, update: true)
        }
    }
    
    static func getPersonList2() -> Results<Person> {
        let realm = try! Realm()
        
        let retList = realm.objects(Person.self).sorted(byKeyPath: "order", ascending: true)
        
        return retList
    }
    
    static func getPersonList() -> [Person] {
        let realm = try! Realm()
        
        let resultList = realm.objects(Person.self).sorted(byKeyPath: "order", ascending: true)
        
        return Array(resultList)
    }
    
}
