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
  class func colorForValue(_ value: Double, sortedArray: [Double], index: Int) -> UIColor {
    let minimumCountOfValuesWorthComputingValueFor = 2
    if (sortedArray.count < minimumCountOfValuesWorthComputingValueFor) {
      return UiConstants.intermediate2ColorDarkened
    }

    let rRed = computeColorComponent(baseColor: UiConstants.intermediate1Color, index: 0)
    let rGreen = computeColorComponent(baseColor: UiConstants.intermediate1Color, index: 1)
    let rBlue = computeColorComponent(baseColor: UiConstants.intermediate1Color, index: 2)
    let yRed = computeColorComponent(baseColor: UiConstants.intermediate2Color, index: 0)
    let yGreen = computeColorComponent(baseColor: UiConstants.intermediate2Color, index: 1)
    let yBlue = computeColorComponent(baseColor: UiConstants.intermediate2Color, index: 2)
    let gRed = computeColorComponent(baseColor: UiConstants.intermediate3Color, index: 0)
    let gGreen = computeColorComponent(baseColor: UiConstants.intermediate3Color, index: 1)
    let gBlue = computeColorComponent(baseColor: UiConstants.intermediate3Color, index: 2)

    let medianValue = sortedArray[sortedArray.count / 2]

    if value < medianValue {
      let ratio = CGFloat(index) / (CGFloat(sortedArray.count) / 2.0)
      let red = rRed + ratio * (yRed - rRed)
      let green = rGreen + ratio * (yGreen - rGreen)
      let blue = rBlue + ratio * (yBlue - rBlue)
      return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    } else {
      let ratio = (CGFloat(index) - CGFloat(sortedArray.count / 2)) / CGFloat(sortedArray.count / 2)
      let red = yRed + ratio * (gRed - yRed)
      let green = yGreen + ratio * (gGreen - yGreen)
      let blue = yBlue + ratio * (gBlue - yBlue)
      return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }
  }

  private class func computeColorComponent(baseColor: UIColor, index: Int) -> CGFloat {
    return ((baseColor.cgColor.components?[index]) ?? 0.0) * UiConstants.darkening
  }

  class func letterPressedText(_ plainText: String) -> NSAttributedString {
    return NSAttributedString(string: plainText, attributes: [NSAttributedStringKey.textEffect: NSAttributedString.TextEffectStyle.letterpressStyle])
  }

  class func styleText(_ text: String) -> NSAttributedString {
    let matText = NSMutableAttributedString(string: text)
    let bodyFont = UIFont(name: UiConstants.globalFont, size: UiConstants.bodyFontSize) ?? UIFont.systemFont(ofSize: UiConstants.bodyFontSize)
    matText.addAttributes([NSAttributedStringKey.foregroundColor: UiConstants.lightColor, NSAttributedStringKey.font: bodyFont], range: NSMakeRange(0, matText.length))
    let centeredStyle = NSMutableParagraphStyle()
    centeredStyle.alignment = .center
    let headerAttributes = [NSAttributedStringKey.foregroundColor: UiConstants.intermediate1Color, NSAttributedStringKey.textEffect: NSAttributedString.TextEffectStyle.letterpressStyle] as [NSAttributedStringKey: Any]
    let textAsNsString = text as NSString
    var i = 0
    var insideHeading = false
    var insideBold = false
    var startIndex = 0
    let headerDelimiter = "^"
    let boldDelimiter = "​" // http://www.fileformat.info/info/unicode/char/200B/browsertest.htm

    while i < textAsNsString.length {
      if textAsNsString.substring(with: NSMakeRange(i, 1)) == headerDelimiter {
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
        } else {
          insideHeading = true
          startIndex = i
        }
      } else if textAsNsString.substring(with: NSMakeRange(i, 1)) == boldDelimiter {
        if insideBold {
          let boldRange = NSMakeRange(startIndex, i - startIndex)
          let boldFont = UIFont(name: UiConstants.globalFontBold, size: UiConstants.bodyFontSize) ?? UIFont.systemFont(ofSize: UiConstants.bodyFontSize)
          matText.addAttribute(NSAttributedStringKey.font, value: boldFont, range: boldRange)
          insideBold = false
        } else {
          insideBold = true
          startIndex = i + 1
        }
      }
      i += 1
    }
    return matText
  }
}
