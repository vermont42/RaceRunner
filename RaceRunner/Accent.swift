//
//  Accent.swift
//  RaceRunner
//
//  Created by Joshua Adams on 11/27/15.
//  Copyright © 2015 Josh Adams. All rights reserved.
//

import Foundation

enum Accent: String {
  case 🇺🇸 = "🇺🇸"
  case 🇮🇪 = "🇮🇪"
  case 🇬🇧 = "🇬🇧"
  case 🇦🇺 = "🇦🇺"
    
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
}
