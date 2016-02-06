//
//  Overlay.swift
//  RaceRunner
//
//  Created by Joshua Adams on 1/27/16.
//  Copyright © 2016 Josh Adams. All rights reserved.
//

import Foundation

enum Overlay: String {
  case Both = "Both"
  case Pace = "Pace"
  case Altitude = "Altitude"
  
  init() {
    self = .Both
  }
  
  func radioButtonPosition() -> Int {
    switch self {
    case .Both:
      return 0
    case .Pace:
      return 1
    case .Altitude:
      return 2
    }
  }
  
  static func stringToOVerlay(overlay: String) -> Overlay {
    switch overlay {
    case "Both":
      return .Both
    case "Pace":
      return .Pace
    case "Altitude":
      return .Altitude
    default:
      return .Both
    }
  }
}
