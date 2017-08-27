//
//  Utility.swift
//  temperature
//
//  Created by 藤原 達郎 on 2017/08/24.
//  Copyright © 2017年 Tatsuo Fujiwara. All rights reserved.
//

import Foundation

class Utility {
    
    static func isJapaneseLocale() -> Bool {
        if let prefLang = Locale.preferredLanguages.first {
            if (prefLang.hasPrefix("ja")){
                return true
            } else {
                return false
            }
        } else {
            return false
        }
    }
    
}

