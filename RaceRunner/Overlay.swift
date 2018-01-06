//
//  Overlay.swift
//  RaceRunner
//
//  Created by Joshua Adams on 1/27/16.
//  Copyright © 2016 Josh Adams. All rights reserved.
//

import Foundation

enum Overlay: String {
  case both = "Both"
  case pace = "Pace"
  case altitude = "Altitude"
  
  init() {
    self = .both
  }
  
  func radioButtonPosition() -> Int {
    switch self {
    case .both:
      return 0
    case .pace:
      return 1
    case .altitude:
      return 2
    }
  }
  
  static func stringToOVerlay(_ overlay: String) -> Overlay {
    switch overlay {
    case "Both":
      return .both
    case "Pace":
      return .pace
    case "Altitude":
      return .altitude
    default:
      return .both
    }
  }
}
