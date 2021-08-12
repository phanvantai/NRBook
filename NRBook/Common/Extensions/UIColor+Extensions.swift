//
//  UIColor+Extensions.swift
//  UIColor+Extensions
//
//  Created by Tai Phan Van on 13/08/2021.
//  Copyright © 2021 november-rain. All rights reserved.
//

import UIKit

public extension UIColor {
    
    class func randomColor() -> UIColor {
        
        let red = CGFloat(arc4random() % 255) / 255.0
        let green = CGFloat(arc4random() % 255) / 255.0
        let blue = CGFloat(arc4random() % 255) / 255.0
        
        return self.init(red: red, green: green, blue: blue, alpha: 1)
    }
    
    class func rgba(_ red: CGFloat, _ green: CGFloat, _ blue: CGFloat, _ alpha: CGFloat) -> UIColor {
        return self.init(red: red/255.0, green: green/255.0, blue: blue/255.0, alpha: alpha)
    }
    
    /// Default count limit: 100
    class var cacheCountLimit: Int {
        set {
            hexColorCache.countLimit = newValue
        }
        get {
            return hexColorCache.countLimit
        }
    }
    
    private class func hexToUInt64(_ hexString: String) -> UInt64 {
        var result: UInt64 = 0
        guard Scanner(string: hexString).scanHexInt64(&result) else {
            return 1
        }
        return result
    }
    
    private static var hexColorCache: NSCache<NSString, UIColor> = {
        let cache = NSCache<NSString, UIColor>()
        cache.countLimit = 100;
        return cache
    }()
    
    class func hexColor(_ hexString: String) -> UIColor {
        return self.hexColor(hexString: hexString, alpha: 1.0)
    }
    
    /// Creat real color by hex string
    /// - Parameters:
    ///   - hexString: Hex string like "FFFFFF". Support RGB and ARGB hex string
    ///   - alpha: The opacity value of the color object, specified as a value from 0.0 to 1.0.
    /// - Returns: IRColor. (Return clear color when hex format is error)
    class func hexColor(hexString: String, alpha: CGFloat) -> UIColor {
        
        var resultHex = hexString
        
        if hexString.hasPrefix("#") {
            resultHex.removeFirst(1)
        }
        
        var resultAlpha: CGFloat = alpha
        if resultHex.count == 8 {
            resultAlpha = CGFloat(self.hexToUInt64("0x\(resultHex.prefix(2))")) / 255.0
            resultHex.removeFirst(2)
        }
        
        if resultHex.count != 6 {
#if DEBUG
            assert(false, "Hex: [\(hexString)] format is error!")
#endif
            return self.clear
        }
        
        // hex color from cache
        if let cacheColor = self.hexColorCache.object(forKey: resultHex as NSString) {
            return cacheColor.withAlphaComponent(resultAlpha)
        }
        
        // get green hex index
        let greenBegin = resultHex.index(resultHex.startIndex, offsetBy: 2)
        let greenEnd = resultHex.index(resultHex.startIndex, offsetBy: 3)
        
        let red = CGFloat(self.hexToUInt64("0x\(resultHex.prefix(2))")) / 255.0
        let green = CGFloat(self.hexToUInt64("0x\(resultHex[greenBegin...greenEnd])")) / 255.0
        let blue = CGFloat(self.hexToUInt64("0x\(resultHex.suffix(2))")) / 255.0
        
        var resultColor: UIColor
        
        #if os(iOS) || os(watchOS) || os(tvOS)
          resultColor = self.init(red:red, green:green, blue:blue, alpha:resultAlpha)
        #else
          resultColor = self.init(calibratedRed:red, green:green, blue:blue, alpha:resultAlpha)
        #endif
        
        self.hexColorCache.setObject(resultColor, forKey: hexString as NSString)
        
        return resultColor
    }
}
