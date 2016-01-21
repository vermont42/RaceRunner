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
    
    func languageCode() -> String {
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
    
    func radioButtonPosition() -> Int {
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
    
    static func stringToAccent(accent: String) -> Accent {
        switch accent {
        case "🇺🇸":
            return .🇺🇸
        case "🇮🇪":
            return .🇮🇪
        case "🇬🇧":
            return .🇬🇧
        case "🇦🇺":
            return .🇦🇺
        default:
            return .🇺🇸
        }
    }
}
