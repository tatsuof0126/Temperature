//
//  TemperatureCondition.swift
//  temperature
//
//  Created by 藤原 達郎 on 2017/09/04.
//  Copyright © 2017年 Tatsuo Fujiwara. All rights reserved.
//

import Foundation
import RealmSwift

class TemperatureCondition : Object {
    
    @objc dynamic var id : Int = 0
    @objc dynamic var langage : Int = 0
    @objc dynamic var condition : String = ""
    
    
    
}
