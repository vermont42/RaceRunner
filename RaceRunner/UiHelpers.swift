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
  private static let headerDelimiter = "^"
  private static let boldDelimiter = "​" // http://www.fileformat.info/info/unicode/char/200B/browsertest.htm
  
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
  
  //    let fontFamilyNames = UIFont.familyNames()
  //    for familyName in fontFamilyNames {
  //      print("------------------------------")
  //      print("Font Family Name = [\(familyName)]")
  //      let names = UIFont.fontNamesForFamilyName(familyName as String)
  //      print("Font Names = [\(names)]")
  //    }
  
  class func styleText(text: String) -> NSAttributedString {
    let matText = NSMutableAttributedString(string: text)
    matText.addAttributes([NSForegroundColorAttributeName: UiConstants.lightColor, NSFontAttributeName: UIFont(name: UiConstants.globalFont, size: UiConstants.bodyFontSize)!], range: NSMakeRange(0, matText.length))
    let centeredStyle = NSMutableParagraphStyle()
    centeredStyle.alignment = .Center
    let headerAttributes = [NSForegroundColorAttributeName: UiConstants.intermediate1Color, NSTextEffectAttributeName: NSTextEffectLetterpressStyle]
    let textAsNsString = text as NSString
    var i: Int = 0
    var insideHeading = false
    var insideBold = false
    var startIndex = 0
    while i < textAsNsString.length {
      if textAsNsString.substringWithRange(NSMakeRange(i, 1)) == UiHelpers.headerDelimiter {
        if insideHeading {
          let headerWithDelimitersRange = NSMakeRange(startIndex, (i - startIndex) + 1)
          matText.addAttribute(NSParagraphStyleAttributeName, value: centeredStyle, range: headerWithDelimitersRange)
          let headerRange = NSMakeRange(startIndex + 1, (i - startIndex) - 1)
          matText.addAttributes(headerAttributes, range: headerRange)
          let leadingRange = NSMakeRange(startIndex, 1)
          matText.addAttribute(NSForegroundColorAttributeName, value: UiConstants.darkColor, range: leadingRange)
          let trailingRange = NSMakeRange(i, 1)
          matText.addAttribute(NSForegroundColorAttributeName, value: UiConstants.darkColor, range: trailingRange)
          insideHeading = false
        }
        else {
          insideHeading = true
          startIndex = i
        }
      }
      else if textAsNsString.substringWithRange(NSMakeRange(i, 1)) == UiHelpers.boldDelimiter {
        if insideBold {
          let boldRange = NSMakeRange(startIndex, i - startIndex)
          matText.addAttribute(NSFontAttributeName, value: UIFont(name: UiConstants.globalFontBold, size: UiConstants.bodyFontSize)!, range: boldRange)
          insideBold = false
        }
        else {
          insideBold = true
          startIndex = i + 1
        }
      }
      i++
    }
    return matText
  }
}