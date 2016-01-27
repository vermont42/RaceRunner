//
//  ShoesSortField.swift
//  RaceRunner
//
//  Created by Joshua Adams on 1/12/16.
//  Copyright © 2016 Josh Adams. All rights reserved.
//

enum ShoesSortField: String {
  case Name = "Name"
  case Kilometers = "Kilometers"
  case MaxKilometers = "MaxKilometers"
  
  init() {
    self = .Name
  }
  
  static func all() -> [String] {
    return [ShoesSortField.Name.asString(), ShoesSortField.Kilometers.asString(), ShoesSortField.MaxKilometers.asString()]
  }
  
  static func sortFieldForPosition(position: Int) -> ShoesSortField {
    switch position {
    case 0:
      return .Name
    case 1:
      return .Kilometers
    case 2:
      return .MaxKilometers
    default:
      return .Name
    }
  }
  
  func asString() -> String {
    switch self {
    case .Name:
      return self.rawValue
    case .Kilometers:
      if SettingsManager.getUnitType() == .Metric {
        return "Current Kilometers"
      }
      else {
        return "Current Miles"
      }
    case .MaxKilometers:
      if SettingsManager.getUnitType() == .Metric {
        return "Maximum Kilometers"
      }
      else {
        return "Maximum Miles"
      }
    }
  }
  
  func pickerPosition() -> Int {
    switch self {
    case .Name:
      return 0
    case .Kilometers:
      return 1
    case .MaxKilometers:
      return 2
    }
  }
  
  static func compare(shoes1: Shoes, shoes2: Shoes) -> Bool {
    let sortType = SettingsManager.getSortType()
    let sortField = SettingsManager.getShoesSortField()
    var ordering: NSComparisonResult
    switch sortType {
    case .Normal:
      ordering = .OrderedDescending
    case .Reverse:
      ordering = .OrderedAscending
    }
    switch sortField {
    case .Name:
      let name1: String = shoes1.name
      let name2: String = shoes2.name
      return name1.localizedCaseInsensitiveCompare(name2) == ordering
    case .Kilometers:
      var result = shoes1.kilometers.floatValue < shoes2.kilometers.floatValue
      if ordering == .OrderedDescending {
        result = !result
      }
      return result
    case .MaxKilometers:
      var result = shoes1.maxKilometers.floatValue < shoes2.maxKilometers.floatValue
      if ordering == .OrderedDescending {
        result = !result
      }
      return result
    }
  }
}


