//
//  UIViewExtension.swift
//  temperature
//
//  Created by 藤原 達郎 on 2017/10/15.
//  Copyright © 2017年 Tatsuo Fujiwara. All rights reserved.
//

import UIKit

extension UIView {
    
    func getScreenShot() -> UIImage{
        let rect = self.bounds
        return getScreenShot(rect : rect)
    }
    
    func getScreenShot(rect : CGRect) -> UIImage{
        // ビットマップ画像のcontextを作成.
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        let context: CGContext = UIGraphicsGetCurrentContext()!
        
        // 対象のview内の描画をcontextに複写する.
        self.layer.render(in: context)
        
        // 現在のcontextのビットマップをUIImageとして取得.
        let capturedImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        
        // contextを閉じる.
        UIGraphicsEndImageContext()
        
        return capturedImage
    }

    
    
    
}
