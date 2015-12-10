//
//  UiHelpers.swift
//  RaceRunner
//
//  Created by Joshua Adams on 8/29/15.
//  Copyright (c) 2015 Josh Adams. All rights reserved.
//

import Foundation
import UIKit

class UiHelpers {
    class func maskedImageNamed(name:String, color:UIColor) -> UIImage {
        let image = UIImage(named: name)
        let rect:CGRect = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: image!.size.width, height: image!.size.height))
        UIGraphicsBeginImageContextWithOptions(rect.size, false, image!.scale)
        let c:CGContextRef = UIGraphicsGetCurrentContext()!
        image?.drawInRect(rect)
        CGContextSetFillColorWithColor(c, color.CGColor)
        CGContextSetBlendMode(c, CGBlendMode.SourceAtop)
        CGContextFillRect(c, rect)
        let result:UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result
    }
    
    class func letterPressedText(plainText: String) -> NSAttributedString {
        return NSAttributedString(string: plainText, attributes: [NSTextEffectAttributeName: NSTextEffectLetterpressStyle])
    }
    
    class func colorForValue(value: Double, sortedArray: [Double], index: Int) -> UIColor {
        let r_red: CGFloat = 1.0
        let r_green: CGFloat = 20.0 / 255.0
        let r_blue: CGFloat = 44.0 / 255.0
        let y_red: CGFloat = 1.0
        let y_green: CGFloat = 215.0 / 255.0
        let y_blue: CGFloat = 0.0
        let g_red: CGFloat = 0.0
        let g_green: CGFloat = 146.0 / 255.0
        let g_blue: CGFloat = 78.0 / 255.0
        let medianValue = sortedArray[sortedArray.count / 2]
        if value < medianValue {
            let ratio = CGFloat(index) / (CGFloat(sortedArray.count) / 2.0)
            let red = r_red + ratio * (y_red - r_red)
            let green = r_green + ratio * (y_green - r_green)
            let blue = r_blue + ratio * (y_blue - r_blue)
            return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
        }
        else {
            let ratio = (CGFloat(index) - CGFloat(sortedArray.count / 2)) / CGFloat(sortedArray.count / 2)
            let red = y_red + ratio * (g_red - y_red)
            let green = y_green + ratio * (g_green - y_green)
            let blue = y_blue + ratio * (g_blue - y_blue)
            return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
        }
    }
}