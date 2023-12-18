//
//  DeviceUtilityExtension.swift
//  RaceRunner
//
//  Created by Josh Adams on 2/16/19.
//  Copyright © 2019 Josh Adams. All rights reserved.
//

import UIKit

public extension UIDevice {
  var modelName: String {
    if ProcessInfo.processInfo.isiOSAppOnMac {
      return "iOS on Mac"
    }

    var systemInfo = utsname()
    uname(&systemInfo)
    let machineMirror = Mirror(reflecting: systemInfo.machine)
    let identifier = machineMirror.children.reduce("") { identifier, element in
      guard
        let value = element.value as? Int8,
        value != 0
      else {
        return identifier
      }
      return identifier + String(UnicodeScalar(UInt8(value)))
    }

    // https://gist.github.com/adamawolf/3048717
    // swiftlint:disable switch_case_on_newline
    switch identifier {
    case "iPod5,1":                                 return "iPod Touch 5"
    case "iPod7,1":                                 return "iPod Touch 6"
    case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
    case "iPhone4,1":                               return "iPhone 4s"
    case "iPhone5,1":                               return "iPhone 5 (GSM)"
    case "iPhone5,2":                               return "iPhone 5 (GSM+CDMA)"
    case "iPhone5,3":                               return "iPhone 5c (GSM)"
    case "iPhone5,4":                               return "iPhone 5c (Global)"
    case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
    case "iPhone7,2":                               return "iPhone 6"
    case "iPhone7,1":                               return "iPhone 6 Plus"
    case "iPhone8,1":                               return "iPhone 6s"
    case "iPhone8,2":                               return "iPhone 6s Plus"
    case "iPhone8,4":                               return "iPhone SE"
    case "iPhone9,1", "iPhone9,3":                  return "iPhone 7"
    case "iPhone9,2", "iPhone9,4":                  return "iPhone 7 Plus"
    case "iPhone10,1", "iPhone10,4":                return "iPhone 8"
    case "iPhone10,2", "iPhone10,5":                return "iPhone 8 Plus"
    case "iPhone10,3", "iPhone10,6":                return "iPhone X"
    case "iPhone11,2":                              return "iPhone XS"
    case "iPhone11,4", "iPhone11,6":                return "iPhone XS Max"
    case "iPhone11,8":                              return "iPhone XR"
    case "iPhone12,1":                              return "iPhone 11"
    case "iPhone12,3":                              return "iPhone 11 Pro"
    case "iPhone12,5":                              return "iPhone 11 Pro Max"
    case "iPhone12,8":                              return "iPhone SE 2nd Gen."
    case "iPhone13,1":                              return "iPhone 12 Mini"
    case "iPhone13,2":                              return "iPhone 12"
    case "iPhone13,3":                              return "iPhone 12 Pro"
    case "iPhone13,4":                              return "iPhone 12 Pro Max"
    case "iPhone14,2":                              return "iPhone 13 Pro"
    case "iPhone14,3":                              return "iPhone 13 Pro Max"
    case "iPhone14,4":                              return "iPhone 13 Mini"
    case "iPhone14,5":                              return "iPhone 13"
    case "iPhone14,6":                              return "iPhone SE 3rd Gen"
    case "iPhone14,7":                              return "iPhone 14"
    case "iPhone14,8":                              return "iPhone 14 Plus"
    case "iPhone15,2":                              return "iPhone 14 Pro"
    case "iPhone15,3":                              return "iPhone 14 Pro Max"
    case "iPhone15,4":                              return "iPhone 15"
    case "iPhone15,5":                              return "iPhone 15 Plus"
    case "iPhone16,1":                              return "iPhone 15 Pro"
    case "iPhone16,2":                              return "iPhone 15 Pro Max"

    // swiftlint:disable colon
    case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
    case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad Mini"
    case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad 3"
    case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad 4"
    case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
    case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad Mini 2"
    case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad Mini 3"
    case "iPad5,1", "iPad5,2":                      return "iPad Mini 4"
    case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
    case "iPad6,3", "iPad6,4":                      return "iPad Pro 9.7 Inch"
    case "iPad6,7", "iPad6,8":                      return "iPad Pro 12.9 Inch"
    case "iPad6,11", "iPad6,12":                    return "iPad 5"
    case "iPad7,1", "iPad7,2":                      return "iPad Pro 12.9 Inch 2nd Gen."
    case "iPad7,3", "iPad7,4", "iPad7,5":           return "iPad Pro 10.5 Inch"
    case "iPad7,11":                                return "iPad 10.2 Inch"
    case "iPad8,1", "iPad8,2", "iPad8,3", "iPad8,4", "iPad8,5", "iPad8,6", "iPad8,7", "iPad8,8": return "iPad Pro 12.9 Inch 3rd Gen."
    case "iPad8,9", "iPad8,10":                     return "iPad Pro 11 Inch 2nd Gen."
    case "iPad8,11", "iPad8,12":                    return "iPad Pro 12.9 Inch 4th Gen."
    case "iPad11,1", "iPad11,2":                    return "iPad Mini 5th Gen."
    case "iPad11,3", "iPad11,4":                    return "iPad Air 3rd Gen."
    case "iPad11,6", "iPad11,7":                    return "iPad 10.2 Inch 8th Gen."
    case "iPad12,1", "iPad12,2":                    return "iPad 10.2 Inch 9th Gen."
    case "iPad13,1", "iPad13,2":                    return "iPad Air 4th Gen."
    case "iPad13,4", "iPad13,5", "iPad13,6", "iPad13,7": return "iPad Pro 11 Inch 3rd Gen."
    case "iPad13,8", "iPad13,9", "iPad13,10", "iPad13,11": return "iPad Pro 12.9 Inch 5th Gen."
    case "iPad14,1", "iPad14,2":                    return "iPad Mini 6th Gen."
    case "iPad14,3", "iPad14,4":                    return "iPad Pro 11 inch 4th Gen"
    case "iPad14,5", "iPad14,6":                    return "iPad Pro 12.9 inch 6th Gen"

    case "AppleTV5,3":                              return "Apple TV"
    case "AppleTV6,2":                              return "Apple TV 4K"
    case "AudioAccessory1,1":                       return "HomePod"
    case "i386", "x86_64":                          return "Simulator"
    default:                                        return identifier
    }
  }
}
