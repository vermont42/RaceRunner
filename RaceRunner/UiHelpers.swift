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
    if (sortedArray.count < 2) {
      return UiConstants.intermediate2ColorDarkened
    }
    let rRed = CGColorGetComponents(UiConstants.intermediate1Color.CGColor)[0] * UiConstants.darkening
    let rGreen = CGColorGetComponents(UiConstants.intermediate1Color.CGColor)[1] * UiConstants.darkening
    let rBlue = CGColorGetComponents(UiConstants.intermediate1Color.CGColor)[2] * UiConstants.darkening
    let yRed = CGColorGetComponents(UiConstants.intermediate2Color.CGColor)[0] * UiConstants.darkening
    let yGreen = CGColorGetComponents(UiConstants.intermediate2Color.CGColor)[1] * UiConstants.darkening
    let yBlue = CGColorGetComponents(UiConstants.intermediate2Color.CGColor)[2] * UiConstants.darkening
    let gRed = CGColorGetComponents(UiConstants.intermediate3Color.CGColor)[0] * UiConstants.darkening
    let gGreen = CGColorGetComponents(UiConstants.intermediate3Color.CGColor)[1] * UiConstants.darkening
    let gBlue = CGColorGetComponents(UiConstants.intermediate3Color.CGColor)[2] * UiConstants.darkening
    let medianValue = sortedArray[sortedArray.count / 2]
    if value < medianValue {
      let ratio = CGFloat(index) / (CGFloat(sortedArray.count) / 2.0)
      let red = rRed + ratio * (yRed - rRed)
      let green = rGreen + ratio * (yGreen - rGreen)
      let blue = rBlue + ratio * (yBlue - rBlue)
      return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }
    else {
      let ratio = (CGFloat(index) - CGFloat(sortedArray.count / 2)) / CGFloat(sortedArray.count / 2)
      let red = yRed + ratio * (gRed - yRed)
      let green = yGreen + ratio * (gGreen - yGreen)
      let blue = yBlue + ratio * (gBlue - yBlue)
      return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }
  }
}