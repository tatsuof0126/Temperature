//
//  ConfigManager.swift
//  temperature
//
//  Created by 藤原 達郎 on 2017/09/01.
//  Copyright © 2017年 Tatsuo Fujiwara. All rights reserved.
//

import Foundation

class ConfigManager {
        
    static func isShowAds() -> Bool {
        if AppDelegate.SHOW_ADS == false {
            return false
        }
        
        let userDefaults = UserDefaults.standard
        if (userDefaults.object(forKey: "SHOWADS") != nil) {
            return userDefaults.bool(forKey: "SHOWADS")
        }
        return true
    }
    
    static func setShowAds(showAds: Bool) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(showAds, forKey: "SHOWADS")
    }
    
    static func isUseFahrenheit() -> Bool {
        let userDefaults = UserDefaults.standard
        
        // 摂氏か華氏かの設定がなければ初期値を設定（アメリカだけ華氏、それ以外は摂氏）
        if (userDefaults.object(forKey: "USEFAHRENHEIT") == nil) {
            if Utility.isInUSA() {
                setUseFahrenheit(useFahrenheit: true)
            } else {
                setUseFahrenheit(useFahrenheit: false)
            }
        }
        
        return userDefaults.bool(forKey: "USEFAHRENHEIT")
    }
    
    static func setUseFahrenheit(useFahrenheit: Bool) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(useFahrenheit, forKey: "USEFAHRENHEIT")
    }
    
    static func getRecordListType() -> Int {
        let userDefaults = UserDefaults.standard
        if (userDefaults.object(forKey: "RECORDLISTTYPE") == nil) {
            setRecordListType(recordListType: 0)
        }
        return userDefaults.integer(forKey: "RECORDLISTTYPE")
    }
    
    static func setRecordListType(recordListType: Int) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(recordListType, forKey: "RECORDLISTTYPE")
    }
    
    static func getGraphRangeType() -> Int {
        let userDefaults = UserDefaults.standard
        if (userDefaults.object(forKey: "GRAPHRANGETYPE") == nil) {
            setRecordListType(recordListType: 0)
        }
        return userDefaults.integer(forKey: "GRAPHRANGETYPE")
    }
    
    static func setGraphRangeType(graphRangeType: Int) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(graphRangeType, forKey: "GRAPHRANGETYPE")
    }
    
    static func getToAddress() -> String {
        let userDefaults = UserDefaults.standard
        if (userDefaults.object(forKey: "TOADDRESS") == nil) {
            setToAddress(toAddress: "")
        }
        return userDefaults.string(forKey: "TOADDRESS")!
    }
    
    static func setToAddress(toAddress: String) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(toAddress, forKey: "TOADDRESS")
    }
    
}
