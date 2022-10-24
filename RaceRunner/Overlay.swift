//
//  Overlay.swift
//  RaceRunner
//
//  Created by Josh Adams on 1/27/16.
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

  var radioButtonPosition: Int {
    switch self {
    case .both:
      return 0
    case .pace:
      return 1
    case .altitude:
      return 2
    }
  }

  static func positionToOverlay(_ position: Int) -> Overlay {
    switch position {
    case 0:
      return .both
    case 1:
      return .pace
    case 2:
      return .altitude
    default:
      return .both
    }
  }
}
