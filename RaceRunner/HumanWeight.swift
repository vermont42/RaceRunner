//
//  HumanWeight.swift
//  RaceRunner
//
//  Created by Josh Adams on 11/29/15.
//  Copyright © 2015 Josh Adams. All rights reserved.
//

import Foundation

enum HumanWeight {
  static let maxMetric = 454.0
  static let minMetric = 1.0
  static let maxImperial = 999.0
  static let minImperial = 2.0
  static let defaultWeight = 68.0

  static func weightAsString() -> String {
    return weightAsString(SettingsManager.getWeight(), unitType: SettingsManager.getUnitType())
  }

  static func weightAsString(_ weight: Double, unitType: UnitType) -> String {
    switch unitType {
    case .metric:
      return String(format: "%.0f kg", weight)
    case .imperial:
      return String(format: "%.0f lb", weight * Converter.poundsPerKilogram)
    }
  }
}
