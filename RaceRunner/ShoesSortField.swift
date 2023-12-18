//
//  ShoesSortField.swift
//  RaceRunner
//
//  Created by Josh Adams on 1/12/16.
//  Copyright © 2016 Josh Adams. All rights reserved.
//

import Foundation

enum ShoesSortField: String {
  case name = "Name"
  case kilometers = "Kilometers"
  case maxKilometers = "MaxKilometers"

  init() {
    self = .name
  }

  static func all() -> [String] {
    [ShoesSortField.name.asString(), ShoesSortField.kilometers.asString(), ShoesSortField.maxKilometers.asString()]
  }

  static func sortFieldForPosition(_ position: Int) -> ShoesSortField {
    switch position {
    case 0:
      return .name
    case 1:
      return .kilometers
    case 2:
      return .maxKilometers
    default:
      return .name
    }
  }

  func asString() -> String {
    switch self {
    case .name:
      return self.rawValue
    case .kilometers:
      if SettingsManager.getUnitType() == .metric {
        return "Current Kilometers"
      } else {
        return "Current Miles"
      }
    case .maxKilometers:
      if SettingsManager.getUnitType() == .metric {
        return "Maximum Kilometers"
      } else {
        return "Maximum Miles"
      }
    }
  }

  func pickerPosition() -> Int {
    switch self {
    case .name:
      return 0
    case .kilometers:
      return 1
    case .maxKilometers:
      return 2
    }
  }

  static func compare(_ shoes1: Shoes, shoes2: Shoes) -> Bool {
    let sortType = SettingsManager.getSortType()
    let sortField = SettingsManager.getShoesSortField()
    var ordering: ComparisonResult
    switch sortType {
    case .normal:
      ordering = .orderedDescending
    case .reverse:
      ordering = .orderedAscending
    }
    switch sortField {
    case .name:
      let name1: String = shoes1.name
      let name2: String = shoes2.name
      return name1.localizedCaseInsensitiveCompare(name2) == ordering
    case .kilometers:
      var result = shoes1.kilometers.floatValue < shoes2.kilometers.floatValue
      if ordering == .orderedDescending {
        result.toggle()
      }
      return result
    case .maxKilometers:
      var result = shoes1.maxKilometers.floatValue < shoes2.maxKilometers.floatValue
      if ordering == .orderedDescending {
        result.toggle()
      }
      return result
    }
  }
}
