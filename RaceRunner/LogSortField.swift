//
//  LogSortField.swift
//  RaceRunner
//
//  Created by Joshua Adams on 1/12/16.
//  Copyright © 2016 Josh Adams. All rights reserved.
//

import Foundation

enum LogSortField: String {
  case date = "Date"
  case name = "Name"
  case pace = "Pace"
  case distance = "Distance"
  case duration = "Duration"
  
  init() {
    self = .date
  }
  
  static func all() -> [String] {
    return [LogSortField.date.asString(), LogSortField.name.asString(), LogSortField.pace.asString(), LogSortField.distance.asString(), LogSortField.duration.asString()]
  }
  
  static func sortFieldForPosition(_ position: Int) -> LogSortField {
    switch position {
    case 0:
      return .date
    case 1:
      return .name
    case 2:
      return .pace
    case 3:
      return .distance
    case 4:
      return .duration
    default:
      return .date
    }
  }
  
  // This method exists in case I internationalize at some point.
  func asString() -> String {
    switch self {
    case .date:
      return self.rawValue
    case .name:
      return self.rawValue
    case .pace:
      return self.rawValue
    case .distance:
      return self.rawValue
    case .duration:
      return self.rawValue
    }
  }
  
  func pickerPosition() -> Int {
    switch self {
    case .date:
      return 0
    case .name:
      return 1
    case .pace:
      return 2
    case .distance:
      return 3
    case .duration:
      return 4
    }
  }
  
  static func compare(_ run1: Run, run2: Run) -> Bool {
    let sortType = SettingsManager.getSortType()
    let sortField = SettingsManager.getLogSortField()
    var ordering: ComparisonResult
    switch sortType {
    case .normal:
      ordering = .orderedDescending
    case .reverse:
      ordering = .orderedAscending
    }
    switch sortField {
    case .date:
      return run1.timestamp.compare(run2.timestamp as Date) == ordering
    case .name:
      let name1: String = run1.displayName()
      let name2: String = run2.displayName()
      return name1.localizedCaseInsensitiveCompare(name2) == ordering
    case .pace:
      let pace1 = run1.duration.doubleValue / run1.distance.doubleValue
      let pace2 = run2.duration.doubleValue / run2.distance.doubleValue
      var result = pace1 < pace2
      if ordering == .orderedDescending {
        result = !result
      }
      return result
    case .distance:
      var result = run1.distance.doubleValue < run2.distance.doubleValue
      if ordering == .orderedDescending {
        result = !result
      }
      return result
    case .duration:
      var result = run1.duration.int32Value < run2.duration.int32Value
      if ordering == .orderedDescending {
        result = !result
      }
      return result
    }
  }
}


