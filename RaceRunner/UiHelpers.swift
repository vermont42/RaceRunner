//
//  UiHelpers.swift
//  RaceRunner
//
//  Created by Josh Adams on 8/29/15.
//  Copyright (c) 2015 Josh Adams. All rights reserved.
//

import UIKit

enum UiHelpers {
  static func colorForValue(_ value: Double, sortedArray: [Double], index: Int) -> UIColor {
    let minimumCountOfValuesWorthComputingValueFor = 2
    if sortedArray.count < minimumCountOfValuesWorthComputingValueFor {
      return UIConstants.intermediate2ColorDarkened
    }

    let rRed = computeColorComponent(baseColor: UIConstants.intermediate1Color, index: 0)
    let rGreen = computeColorComponent(baseColor: UIConstants.intermediate1Color, index: 1)
    let rBlue = computeColorComponent(baseColor: UIConstants.intermediate1Color, index: 2)
    let yRed = computeColorComponent(baseColor: UIConstants.intermediate2Color, index: 0)
    let yGreen = computeColorComponent(baseColor: UIConstants.intermediate2Color, index: 1)
    let yBlue = computeColorComponent(baseColor: UIConstants.intermediate2Color, index: 2)
    let gRed = computeColorComponent(baseColor: UIConstants.intermediate3Color, index: 0)
    let gGreen = computeColorComponent(baseColor: UIConstants.intermediate3Color, index: 1)
    let gBlue = computeColorComponent(baseColor: UIConstants.intermediate3Color, index: 2)

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

  private static func computeColorComponent(baseColor: UIColor, index: Int) -> CGFloat {
    ((baseColor.cgColor.components?[index]) ?? 0.0) * UIConstants.darkening
  }

  static func letterPressedText(_ plainText: String) -> NSAttributedString {
    NSAttributedString(string: plainText, attributes: [NSAttributedString.Key.textEffect: NSAttributedString.TextEffectStyle.letterpressStyle])
  }

  static func styleText(_ text: String) -> NSAttributedString {
    let matText = NSMutableAttributedString(string: text)
    let bodyFont = UIFont(name: UIConstants.globalFont, size: UIConstants.bodyFontSize) ?? UIFont.systemFont(ofSize: UIConstants.bodyFontSize)
    matText.addAttributes([NSAttributedString.Key.foregroundColor: UIConstants.lightColor, NSAttributedString.Key.font: bodyFont], range: NSMakeRange(0, matText.length))
    let centeredStyle = NSMutableParagraphStyle()
    centeredStyle.alignment = .center
    let headerAttributes = [NSAttributedString.Key.foregroundColor: UIConstants.intermediate1Color, NSAttributedString.Key.textEffect: NSAttributedString.TextEffectStyle.letterpressStyle] as [NSAttributedString.Key: Any]
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
          matText.addAttribute(NSAttributedString.Key.paragraphStyle, value: centeredStyle, range: headerWithDelimitersRange)
          let headerRange = NSMakeRange(startIndex + 1, (i - startIndex) - 1)
          matText.addAttributes(headerAttributes, range: headerRange)
          let leadingRange = NSMakeRange(startIndex, 1)
          matText.addAttribute(NSAttributedString.Key.foregroundColor, value: UIConstants.darkColor, range: leadingRange)
          let trailingRange = NSMakeRange(i, 1)
          matText.addAttribute(NSAttributedString.Key.foregroundColor, value: UIConstants.darkColor, range: trailingRange)
          insideHeading = false
        } else {
          insideHeading = true
          startIndex = i
        }
      } else if textAsNsString.substring(with: NSMakeRange(i, 1)) == boldDelimiter {
        if insideBold {
          let boldRange = NSMakeRange(startIndex, i - startIndex)
          let boldFont = UIFont(name: UIConstants.globalFontBold, size: UIConstants.bodyFontSize) ?? UIFont.systemFont(ofSize: UIConstants.bodyFontSize)
          matText.addAttribute(NSAttributedString.Key.font, value: boldFont, range: boldRange)
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
