//
//  Utility.swift
//  temperature
//
//  Created by 藤原 達郎 on 2017/08/24.
//  Copyright © 2017年 Tatsuo Fujiwara. All rights reserved.
//

import Foundation
import UIKit

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
    
    static func isInUSA() -> Bool {
        if Locale.current.regionCode == "US" {
            return true
        } else {
            return false
        }
    }
    
    static func showAlert(controller: UIViewController, title: String, message: String) {
        let alert = UIAlertController(title:title, message:message, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("ok", comment: ""),
                                      style: UIAlertActionStyle.default, handler:nil))
        
        controller.present(alert, animated: true, completion: nil)
    }
    
    static func showConfirmDialog(controller: UIViewController,
                                  title: String, message: String, handler: ((UIAlertAction)->Void)?) {
        let alert = UIAlertController(title:title, message:message, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("ok", comment: ""),
                                      style: UIAlertActionStyle.default, handler: handler))
        alert.addAction(UIAlertAction(title: NSLocalizedString("cancel", comment: ""),
                                      style: UIAlertActionStyle.cancel))
        
        controller.present(alert, animated: true, completion: nil)
    }
}
