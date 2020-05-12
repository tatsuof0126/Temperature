//
//  TemperatureGraphView.swift
//  temperature
//
//  Created by 藤原 達郎 on 2017/09/14.
//  Copyright © 2017年 Tatsuo Fujiwara. All rights reserved.
//

import UIKit
import RealmSwift

class TemperatureGraphView: UIView {
    
    var endDate:Date = Date()
    var rangeType = 0
    var range = 3
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        backgroundColor = UIColor.white
        
        // 枠線を描画
        drawFrame()
        
        // 体温グラフを描画
        drawTemperature()
    }
    
    func drawFrame(){
        UIColor.black.setStroke()
        
        let displayFahrenheit = ConfigManager.isUseFahrenheit()
        
        let baselineX = UIBezierPath();
        let baselineXPointY = displayFahrenheit ? 225 : 250
        baselineX.lineWidth = 1
        baselineX.move(to: CGPoint(x: 0, y: baselineXPointY));
        baselineX.addLine(to: CGPoint(x: 320, y: baselineXPointY));
        baselineX.stroke();
        
        let baselineY = UIBezierPath();
        baselineY.lineWidth = 1
        baselineY.move(to: CGPoint(x: 35, y: 0));
        baselineY.addLine(to: CGPoint(x: 35, y: 320));
        baselineY.stroke();
        
        // Y軸の目盛とラベル
        let memoriYInfo = displayFahrenheit ?
            [
                (pointY: 30, string: "104.0"),
                (pointY: 95, string: "102.0"),
                (pointY: 160, string: "100.0"),
                (pointY: 225, string: " 98.0"),
                (pointY: 290, string: " 96.0")
            ] : [
                (pointY: 30, string: "40.0"),
                (pointY: 85, string: "39.0"),
                (pointY: 140, string: "38.0"),
                (pointY: 195, string: "37.0"),
                (pointY: 250, string: "36.0"),
                (pointY: 305, string: "35.0")
            ]
        let tempAttr = [
            NSAttributedStringKey.foregroundColor : UIColor.black,
            NSAttributedStringKey.font : UIFont.systemFont(ofSize: 12),
        ]
        
        for (pointY, string) in memoriYInfo {
            if pointY != baselineXPointY {
                UIColor.black.setStroke()
                let memoriline = UIBezierPath();
                memoriline.lineWidth = 0.5
                memoriline.move(to: CGPoint(x: 25, y: pointY));
                memoriline.addLine(to: CGPoint(x: 45, y: pointY));
                memoriline.stroke();
            
                UIColor.lightGray.setStroke()
                let memoriline2 = UIBezierPath();
                memoriline2.lineWidth = 0.5
                memoriline2.move(to: CGPoint(x: 5, y: pointY));
                memoriline2.addLine(to: CGPoint(x: 315, y: pointY));
                memoriline2.stroke();
            }
            
            let adjustX = displayFahrenheit ? 2 : 0
            string.draw(at: CGPoint(x: 5-adjustX, y: pointY-13), withAttributes: tempAttr)
        }
        
        UIColor.black.setStroke()
        
        // X軸の目盛（３日/７日/１４日/３０日表示かで分ける）
        let memoriXInfo = [[45, 132, 219, 306], [45, 83, 121, 159, 197, 235, 273, 311], [45, 64, 83, 102, 121, 140, 159, 178, 197, 216, 235, 254, 273, 292, 311], [66, 126, 186, 246, 306]]
        // let memoriXInfo = (range == 3 ? [45, 132, 219, 306] : [45, 83, 121, 159, 197, 235, 273, 311]);
        
        for x in memoriXInfo[rangeType] {
            UIColor.black.setStroke()
            let memoriline = UIBezierPath();
            memoriline.lineWidth = 0.5
            memoriline.move(to: CGPoint(x: x, y: baselineXPointY-10));
            memoriline.addLine(to: CGPoint(x: x, y: baselineXPointY+10));
            memoriline.stroke();
        }
        
        // X軸のラベル
        let dayAttr = [
            NSAttributedStringKey.foregroundColor : UIColor.black,
            NSAttributedStringKey.font : UIFont.systemFont(ofSize: 13),
        ]
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "M/d"
        
        let endDateInit = [0.0, 0.0, 0.0, -6.0]
        let dateMove = [-1.0, -1.0, -2.0, -7.0]
        let pointXInit = [245, 275, 285, 246]
        let pointXMove = [87, 38, 38, 60]
        let pointYAdjust = [0, 0, 4, 0]
        let strCount = [3, 7, 7, 4]
        
        var date = Date(timeInterval: 60*60*24*endDateInit[rangeType], since: endDate)
        var pointX = pointXInit[rangeType]
        for _ in 0 ..< strCount[rangeType] {
            let dateStr = dateFormatter.string(from: date)
            var adjustX = 0
            if dateStr.count == 3 && rangeType != 3 {
                adjustX = 6
            } else if dateStr.count == 4 && rangeType != 3 {
                adjustX = 3
            }
            
            dateStr.draw(at: CGPoint(x: pointX+adjustX, y: baselineXPointY+4+pointYAdjust[rangeType]), withAttributes: dayAttr)
            
            date = Date(timeInterval: 60*60*24*dateMove[rangeType], since: date)
            pointX = pointX - pointXMove[rangeType]
        }
        
    }
    
    func drawTemperature(){
        let displayFahrenheit = ConfigManager.isUseFahrenheit()
        
        // 表示すべき体温を取得
        let temperaturList = getTargetTemperatureList()
        
        var pointList: [(pointX: Double, pointY: Double)] = []
        
        // 表示すべき体温のX座標とY座標を計算
        for temperature in temperaturList {
            if temperature.temperature  == 0.0 {
                continue
            }
            
            let temperatureDouble = temperature.getTemperatureDouble()
            var pointY = displayFahrenheit ?
                (104 - temperatureDouble) * 65 / 2 + 30 : (40 - temperatureDouble) * 55 + 30
            if pointY < 3 {
                pointY = 3
            } else if pointY > 317 {
                pointY = 317
            }
            
            let endDateModified = Date(timeInterval: TimeInterval(60*60*24*(1)), since: endDate)
            let targetEndDate = Calendar(identifier: .gregorian).startOfDay(for: endDateModified)
            let dateSpan = temperature.date.timeIntervalSince(targetEndDate)
            
            var pointX : Double = 0.0
            if(rangeType == 0){
                pointX = 306 + (dateSpan/60/60/24) * 87
            } else if(rangeType == 1){
                pointX = 311 + (dateSpan/60/60/24) * 38
            } else if(rangeType == 2){
                pointX = 311 + (dateSpan/60/60/24) * 19
            } else if(rangeType == 3){
                pointX = 306 + ((dateSpan/60/60/24) * 60) / 7.0
            }
            
            pointList.append((pointX: pointX, pointY: pointY))
        }
        
        UIColor.orange.setStroke()
        UIColor.red.setFill()
        
        // 折れ線を描画
        let temperatureLine = UIBezierPath();
        temperatureLine.lineWidth = 1
        var firstPoint = true
        for (pointX, pointY) in pointList {
            if firstPoint == true {
                temperatureLine.move(to: CGPoint(x: pointX, y: pointY));
            } else {
                temperatureLine.addLine(to: CGPoint(x: pointX, y: pointY));
            }
            firstPoint = false
        }
        temperatureLine.stroke();
        
        // 点を描画
        for (pointX, pointY) in pointList  {
            let oval = UIBezierPath(ovalIn: CGRect(x: pointX-3, y: pointY-3, width: 6, height: 6))
            oval.fill()
        }
    }
    
    func getTargetTemperatureList() -> Results<Temperature> {
        let calendar = Calendar(identifier: .gregorian)
        let startDateModified = Date(timeInterval: TimeInterval(60*60*24*(1-range)), since: endDate)
        let endDateModified = Date(timeInterval: TimeInterval(60*60*24*(1)), since: endDate)
        
        let targetStartDate = calendar.startOfDay(for: startDateModified) as NSDate
        let targetEndDate = calendar.startOfDay(for: endDateModified) as NSDate
        
        let personId = ConfigManager.getTargetPersonId()
        let retList = Temperature.getDateFilteredTemperature(
            personId: personId, startDate: targetStartDate, endDate: targetEndDate, ascending: true)
        
        return retList
    }

}
