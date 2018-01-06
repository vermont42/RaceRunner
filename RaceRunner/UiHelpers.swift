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
  
  class func maskedImageNamed(_ name:String, color:UIColor) -> UIImage {
    let image = UIImage(named: name)
    let rect:CGRect = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: image!.size.width, height: image!.size.height))
    UIGraphicsBeginImageContextWithOptions(rect.size, false, image!.scale)
    let c:CGContext = UIGraphicsGetCurrentContext()!
    image?.draw(in: rect)
    c.setFillColor(color.cgColor)
    c.setBlendMode(CGBlendMode.sourceAtop)
    c.fill(rect)
    let result:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
    UIGraphicsEndImageContext()
    return result
  }
  
  class func letterPressedText(_ plainText: String) -> NSAttributedString {
    return NSAttributedString(string: plainText, attributes: [NSAttributedStringKey.textEffect: NSAttributedString.TextEffectStyle.letterpressStyle])
  }

  class func colorForValue(_ value: Double, sortedArray: [Double], index: Int) -> UIColor {
    if (sortedArray.count < 2) {
      return UiConstants.intermediate2ColorDarkened
    }
    let rRed = (UiConstants.intermediate1Color.cgColor.components?[0])! * UiConstants.darkening
    let rGreen = (UiConstants.intermediate1Color.cgColor.components?[1])! * UiConstants.darkening
    let rBlue = (UiConstants.intermediate1Color.cgColor.components?[2])! * UiConstants.darkening
    let yRed = (UiConstants.intermediate2Color.cgColor.components?[0])! * UiConstants.darkening
    let yGreen = (UiConstants.intermediate2Color.cgColor.components?[1])! * UiConstants.darkening
    let yBlue = (UiConstants.intermediate2Color.cgColor.components?[2])! * UiConstants.darkening
    let gRed = (UiConstants.intermediate3Color.cgColor.components?[0])! * UiConstants.darkening
    let gGreen = (UiConstants.intermediate3Color.cgColor.components?[1])! * UiConstants.darkening
    let gBlue = (UiConstants.intermediate3Color.cgColor.components?[2])! * UiConstants.darkening
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
  
  class func styleText(_ text: String) -> NSAttributedString {
    let matText = NSMutableAttributedString(string: text)
    matText.addAttributes([NSAttributedStringKey.foregroundColor: UiConstants.lightColor, NSAttributedStringKey.font: UIFont(name: UiConstants.globalFont, size: UiConstants.bodyFontSize)!], range: NSMakeRange(0, matText.length))
    let centeredStyle = NSMutableParagraphStyle()
    centeredStyle.alignment = .center
    let headerAttributes = [NSAttributedStringKey.foregroundColor: UiConstants.intermediate1Color, NSAttributedStringKey.textEffect: NSAttributedString.TextEffectStyle.letterpressStyle] as [NSAttributedStringKey : Any]
    let textAsNsString = text as NSString
    var i = 0
    var insideHeading = false
    var insideBold = false
    var startIndex = 0
    while i < textAsNsString.length {
      if textAsNsString.substring(with: NSMakeRange(i, 1)) == UiHelpers.headerDelimiter {
        if insideHeading {
          let headerWithDelimitersRange = NSMakeRange(startIndex, (i - startIndex) + 1)
          matText.addAttribute(NSAttributedStringKey.paragraphStyle, value: centeredStyle, range: headerWithDelimitersRange)
          let headerRange = NSMakeRange(startIndex + 1, (i - startIndex) - 1)
          matText.addAttributes(headerAttributes, range: headerRange)
          let leadingRange = NSMakeRange(startIndex, 1)
          matText.addAttribute(NSAttributedStringKey.foregroundColor, value: UiConstants.darkColor, range: leadingRange)
          let trailingRange = NSMakeRange(i, 1)
          matText.addAttribute(NSAttributedStringKey.foregroundColor, value: UiConstants.darkColor, range: trailingRange)
          insideHeading = false
        }
        else {
          insideHeading = true
          startIndex = i
        }
      }
      else if textAsNsString.substring(with: NSMakeRange(i, 1)) == UiHelpers.boldDelimiter {
        if insideBold {
          let boldRange = NSMakeRange(startIndex, i - startIndex)
          matText.addAttribute(NSAttributedStringKey.font, value: UIFont(name: UiConstants.globalFontBold, size: UiConstants.bodyFontSize)!, range: boldRange)
          insideBold = false
        }
        else {
          insideBold = true
          startIndex = i + 1
        }
      }
      i += 1
    }
    return matText
  }
}
