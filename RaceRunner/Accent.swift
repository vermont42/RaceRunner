//
//  Accent.swift
//  RaceRunner
//
//  Created by Josh Adams on 11/27/15.
//  Copyright © 2015 Josh Adams. All rights reserved.
//

import Foundation

enum Accent: String {
  case 🇺🇸
  case 🇮🇪
  case 🇬🇧
  case 🇦🇺

  init() {
    self = .🇺🇸
  }

  var languageCode: String {
    switch self {
    case .🇺🇸:
      return "US"
    case .🇮🇪:
      return "IE"
    case .🇬🇧:
      return "GB"
    case .🇦🇺:
      return "AU"
    }
  }

  static func stringToAccent(_ accent: String) -> Accent {
    if let accentEnum = Accent(rawValue: accent) {
      return accentEnum
    } else {
      return .🇺🇸
    }
  }

  var radioButtonPosition: Int {
    switch self {
    case .🇺🇸:
      return 0
    case .🇮🇪:
      return 1
    case .🇬🇧:
      return 2
    case .🇦🇺:
      return 3
    }
  }

  static func positionToAccent(_ position: Int) -> Accent {
    switch position {
    case 0:
      return .🇺🇸
    case 1:
      return .🇮🇪
    case 2:
      return .🇬🇧
    case 3:
      return .🇦🇺
    default:
      return .🇺🇸
    }
  }
}
